global class OpportunityMatrixController {

    public static Set<String> bauLevels = new Set<String> {'Level 1: Standard Product (Inventoried Product)', 'Level 2: Standard Product (BOM Exists)', 'Level 3: Simple BOM Modification', 'Level 4: Complex BOM Modification'};
        public static Set<String> npdLevels = new Set<String> {'Level 5: New Product Development', 'Level 6: Contract Manufacturing'};
            public static Id BAU_RT_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Business_as_Usual').getRecordTypeId();
    public static Id NPD_RT_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Product_Development').getRecordTypeId();
    public static Id FO_RT_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Flexcon_Opportunity').getRecordTypeId();

    @AuraEnabled
    public static Matrix getMatrixByLevel(Id recordId) {
        String level = 'Undecided';
        Map<String, Schema.SObjectField> opportunityFieldMap = Schema.SObjectType.Opportunity.fields.getMap();
        Map<String, String> opportunityFieldNameTypeMap = new Map<String, String>();
        Map<String, List<PicklistOption>> fieldSelectOptionMap = new Map<String, List<PicklistOption>>();
        
        for(String fieldAPIName : opportunityFieldMap.keySet()) {
            Schema.SObjectField field = opportunityFieldMap.get(fieldAPIName);
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            opportunityFieldNameTypeMap.put(fieldAPIName, String.valueOf(fieldResult.getType()));
            if(String.valueOf(fieldResult.getType()).equalsIgnoreCase('Picklist')) {
                List<PicklistOption> options = new List<PicklistOption>();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                options.add( new PicklistOption('--None--', ''));
                for( Schema.PicklistEntry pickListVal : ple){
                    options.add( new PicklistOption(pickListVal.getLabel(), pickListVal.getValue()));
                } 
                fieldSelectOptionMap.put(fieldAPIName, options);
            }
        }
        System.debug(fieldSelectOptionMap.get('Expected_Lifetime_for_label__c'.toLowerCase()));
        List<MatrixQuestion> matrixQuestions = new List<MatrixQuestion>();
        
        String query = buildMatrixQuery();
        List<Opportunity_Matrix__mdt> metadata = Database.query(query);
        
        String oppQuery = buildOpportunityQuery(opportunityFieldNameTypeMap.keySet(), recordId);
        Opportunity opp = Database.query(oppQuery);
        
        level = String.isNotBlank(opp.Opportunity_Level__c) ? opp.Opportunity_Level__c : 'Undecided';
        
        Map<String, Opportunity_Matrix__mdt> individualMap = new Map<String, Opportunity_Matrix__mdt>();
        Map<String, MatrixQuestion> groupByMap = new Map<String, MatrixQuestion>();
        Map<String, MatrixQuestion> parentChildMap = new Map<String, MatrixQuestion>();
        
        //placeholders
        List<Opportunity_Matrix__mdt> groupByList = new List<Opportunity_Matrix__mdt>();
        List<Opportunity_Matrix__mdt> parentChildList = new List<Opportunity_Matrix__mdt>();
        
        for(Opportunity_Matrix__mdt mtdt : metadata) {
            if(String.isBlank(mtdt.Group_By__c)
               && String.isBlank(mtdt.Parent_Question__c)
               && mtdt.Is_Parent__c) {
                   individualMap.put(mtdt.Field_API_Name__c, mtdt);
               }
        }
        
        //placeholder
        MatrixQuestion mtrx;
        Question que;
        List<Question> childQuestions;
        Integer overallQuestionCount = 0;
        Integer applicableQuestionCount = 0;
        
        for(Opportunity_Matrix__mdt mtdt : metadata) {
            
            mtrx = new MatrixQuestion();
            mtrx.isApplicableForCurrentLevel = isThisQuestionApplicableForGivenLevel(mtdt, level);
            mtrx.applicableLevels = getApplicableLevelsForThisQuestion(mtdt);
            mtrx.isLevel6Question = mtrx.applicableLevels.contains('Level 6: Contract Manufacturing');
            //INDIVIDUAL QUESTION
            if(String.isBlank(mtdt.Group_By__c)
               && String.isBlank(mtdt.Parent_Question__c)
               && !mtdt.Is_Parent__c) {
                   mtrx.questionType = 'individual';
                   que = new Question();
                   que.questionId = mtdt.Id;
                   que.questionLabel = String.isNotBlank(mtdt.Question__c) ? mtdt.Question__c : 'Details/Other';
                   que.helpText = String.isNotBlank(mtdt.Help_Text__c) ? mtdt.Help_Text__c : '';
                   que.fieldApiName = mtdt.Field_API_Name__c;
                   que.selectedAnswer = '';
                   que.options = new List<PicklistOption>();
                   if(opportunityFieldNameTypeMap.containsKey(mtdt.Field_API_Name__c.toLowerCase())) {
                       que.fieldType = opportunityFieldNameTypeMap.get(mtdt.Field_API_Name__c.toLowerCase());
                       if(opp.get(mtdt.Field_API_Name__c) != null) {
                           setSelectedAnswer(que, opp);
                       }
                   }
                   if(fieldSelectOptionMap.containsKey(mtdt.Field_API_Name__c.toLowerCase())) {
                       que.options = fieldSelectOptionMap.get(mtdt.Field_API_Name__c.toLowerCase());
                   }
                   
                   mtrx.question = que;
                   matrixQuestions.add(mtrx);
                    
                   //populate the question count
                   overallQuestionCount++;
                   if(mtrx.isApplicableForCurrentLevel) {
                       applicableQuestionCount++;
                   }
                   
                   mtrx = setLevelScores(mtrx, mtdt);
               }
            
            //GROUP QUESTION
            if(String.isNotBlank(mtdt.Group_By__c)) {
                Integer indexOf;
                childQuestions = new List<Question>();
                if(groupByMap.containsKey(mtdt.Group_By__c)) {
                    mtrx = groupByMap.get(mtdt.Group_By__c);
                    childQuestions = mtrx.childQuestions;
                    indexOf = matrixQuestions.indexOf(mtrx);
                }
                else {
                    //populate the question count
                    overallQuestionCount++;
                    if(mtrx.isApplicableForCurrentLevel) {
                        applicableQuestionCount++;
                    }
                }
                
                mtrx.questionType = 'group';
                mtrx.groupName = mtdt.Group_By__c;
                
                que = new Question();
                que.questionId = mtdt.Id;
                que.questionLabel = String.isNotBlank(mtdt.Question__c) ? mtdt.Question__c : 'Details/Other';
                que.helpText = String.isNotBlank(mtdt.Help_Text__c) ? mtdt.Help_Text__c : '';
                que.fieldApiName = mtdt.Field_API_Name__c;
                que.selectedAnswer = '';
                que.options = new List<PicklistOption>();
                if(opportunityFieldNameTypeMap.containsKey(mtdt.Field_API_Name__c.toLowerCase())) {
                    que.fieldType = opportunityFieldNameTypeMap.get(mtdt.Field_API_Name__c.toLowerCase());
                    if(opp.get(mtdt.Field_API_Name__c) != null) {
                        setSelectedAnswer(que, opp);
                    }
                }
                if(fieldSelectOptionMap.containsKey(mtdt.Field_API_Name__c.toLowerCase())) {
                    que.options = fieldSelectOptionMap.get(mtdt.Field_API_Name__c.toLowerCase());
                }
                childQuestions.add(que);
                
                mtrx.childQuestions = childQuestions;
                
                mtrx = setLevelScores(mtrx, mtdt);
                
                if(indexOf != null
                   && indexOf >= 0) {
                    matrixQuestions.set(indexOf, mtrx);
                }
                else {
                    matrixQuestions.add(mtrx);
                }
                groupByMap.put(mtdt.Group_By__c, mtrx);
            }
            
            //PARENT-CHILD QUESTION
            else if(String.isNotBlank(mtdt.Parent_Question__c)) {
                Integer indexOf;
                childQuestions = new List<Question>();
                
                if(parentChildMap.containsKey(mtdt.Parent_Question__c)) {
                    mtrx = parentChildMap.get(mtdt.Parent_Question__c);
                    childQuestions = mtrx.childQuestions;
                    indexOf = matrixQuestions.indexOf(mtrx);
                }
                else {
                    //populate the question count
                    overallQuestionCount++;
                    if(mtrx.isApplicableForCurrentLevel) {
                        applicableQuestionCount++;
                    }
                }
                                
                mtrx.questionType = 'parent-child';
                
                //build parent question
                if(individualMap.containsKey(mtdt.Parent_Question__c)) {
                    Opportunity_Matrix__mdt mtdtParent = individualMap.get(mtdt.Parent_Question__c);
                    que = new Question();
                    que.questionId = mtdtParent.Id;
                    que.questionLabel = String.isNotBlank(mtdtParent.Question__c) ? mtdtParent.Question__c : 'Details/Other';
                    que.helpText = String.isNotBlank(mtdtParent.Help_Text__c) ? mtdtParent.Help_Text__c : '';
                    que.fieldApiName = mtdtParent.Field_API_Name__c;
                    que.selectedAnswer = '';
                    que.options = new List<PicklistOption>();
                    if(opportunityFieldNameTypeMap.containsKey(mtdtParent.Field_API_Name__c.toLowerCase())) {
                        que.fieldType = opportunityFieldNameTypeMap.get(mtdtParent.Field_API_Name__c.toLowerCase());
                        if(opp.get(mtdtParent.Field_API_Name__c) != null) {
                            setSelectedAnswer(que, opp);
                        }
                    }
                    if(fieldSelectOptionMap.containsKey(mtdtParent.Field_API_Name__c.toLowerCase())) {
                        que.options = fieldSelectOptionMap.get(mtdtParent.Field_API_Name__c.toLowerCase());
                    }
                    mtrx.parentQuestion = que;
                    mtrx = setLevelScores(mtrx, mtdtParent);
                }
                
                que = new Question();
                que.questionId = mtdt.Id;
                que.questionLabel = String.isNotBlank(mtdt.Question__c) ? mtdt.Question__c : 'Details/Other';
                que.helpText = String.isNotBlank(mtdt.Help_Text__c) ? mtdt.Help_Text__c : '';
                que.fieldApiName = mtdt.Field_API_Name__c;
                que.selectedAnswer = '';
                que.options = new List<PicklistOption>();
                if(opportunityFieldNameTypeMap.containsKey(mtdt.Field_API_Name__c.toLowerCase())) {
                    que.fieldType = opportunityFieldNameTypeMap.get(mtdt.Field_API_Name__c.toLowerCase());
                    if(opp.get(mtdt.Field_API_Name__c) != null) {
                        setSelectedAnswer(que, opp);
                    }
                }
                if(fieldSelectOptionMap.containsKey(mtdt.Field_API_Name__c.toLowerCase())) {
                    que.options = fieldSelectOptionMap.get(mtdt.Field_API_Name__c.toLowerCase());
                }
                childQuestions.add(que);
                
                mtrx.childQuestions = childQuestions;
                if(indexOf != null
                   && indexOf >= 0) {
                       matrixQuestions.set(indexOf, mtrx);
                   }
                else {
                    matrixQuestions.add(mtrx);
                }
                
                parentChildMap.put(mtdt.Parent_Question__c, mtrx); 
            }
        }
        
        //check if all questions are marked
        for(MatrixQuestion question: matrixQuestions) {
            if(question.questionType == 'parent-child'
               || question.questionType == 'group') {
                   Boolean areAllAnswered = true;
                   if(question.questionType == 'parent-child'
                      && question.parentQuestion.isAnswered) {
                          //areAllAnswered = false;
                          question.isAnswered = true;
                      }
                   for(Question childQuestion : question.childQuestions) {
                       if(childQuestion.isAnswered) {
                           //areAllAnswered = false;
                           question.isAnswered = true;
                           break;
                       }
                   }
                   //question.isAnswered = areAllAnswered;
               }
            else if(question.questionType == 'individual') {
                question.isAnswered = question.question.isAnswered;
            }
        }
        
        Matrix matrixToReturn = new Matrix();
        matrixToReturn.matrixQuestions = matrixQuestions;
        matrixToReturn.oppName = opp.Name;
        matrixToReturn.oppStageName = 'New';
        matrixToReturn.oppRecordTypeName = '';
        matrixToReturn.oppCloseDate = Date.today();
        matrixToReturn.oppId = opp.Id;
        matrixToReturn.currentLevel = level;
        if(fieldSelectOptionMap.containsKey('Opportunity_Level__c'.toLowerCase())) {
            matrixToReturn.availableLevels = fieldSelectOptionMap.get('Opportunity_Level__c'.toLowerCase());
        }
        matrixToReturn.overallQuestionCount = overallQuestionCount;
        matrixToReturn.currentLevelQuestionCount = applicableQuestionCount;
        return matrixToReturn;
    }
    
    @AuraEnabled
    public static Matrix saveMatrixToOpportunity(Matrix oppMatrix) {
        Opportunity opp = new Opportunity(Id = oppMatrix.oppId);
        
        opp.Opportunity_Level__c = oppMatrix.currentLevel;

        opp.Opportunity_Priority_Score__c = 0;
        //set the answers of matrix
        for(MatrixQuestion matQue : oppMatrix.matrixQuestions) {
            if(matQue.questionType.equals('individual')) {
                if(matQue.question.fieldType.equalsIgnoreCase('BOOLEAN')) {
                    opp.put(matQue.question.fieldApiName, matQue.question.selectedAnswerBoolean);
                }
                else {
                    opp.put(matQue.question.fieldApiName, matQue.question.selectedAnswer);
                }
            }
            else if(matQue.questionType.equals('group')) {
                for(Question childQue : matQue.childQuestions) {
                    if(childQue.fieldType.equalsIgnoreCase('BOOLEAN')) {
                        opp.put(childQue.fieldApiName, childQue.selectedAnswerBoolean);
                    }
                    else {
                        opp.put(childQue.fieldApiName, childQue.selectedAnswer);
                    }
                }
            }
            else if(matQue.questionType.equals('parent-child')) {
                if(matQue.parentQuestion.fieldType.equalsIgnoreCase('BOOLEAN')) {
                    opp.put(matQue.parentQuestion.fieldApiName, matQue.parentQuestion.selectedAnswerBoolean);
                }
                else {
                    opp.put(matQue.parentQuestion.fieldApiName, matQue.parentQuestion.selectedAnswer);
                }
                for(Question childQue : matQue.childQuestions) {
                    //this needs to be investigated : check the API names on custom metadata
                    if(String.isNotBlank(childQue.fieldType)) {
                        if(childQue.fieldType.equalsIgnoreCase('BOOLEAN')) {
                            opp.put(childQue.fieldApiName, childQue.selectedAnswerBoolean);
                        }
                        else {
                            opp.put(childQue.fieldApiName, childQue.selectedAnswer);
                        }
                    }
                }
            }
            if(matQue.isAnswered) {
                opp.Opportunity_Priority_Score__c += getCurrentLevelScore(matQue, oppMatrix.currentLevel);
            }
        }
        
        //calculate record type for opportunity
        if(bauLevels.contains(oppMatrix.currentLevel)) {
            opp.RecordTypeId = BAU_RT_ID;
        }
        else if(npdLevels.contains(oppMatrix.currentLevel)) {
            opp.RecordTypeId = NPD_RT_ID;
        }
        else {
            opp.RecordTypeId = BAU_RT_ID;
        }
        
        update opp;
        
        oppMatrix = getMatrixByLevel(opp.Id);
        return oppMatrix;
    }
    
    public static Decimal getCurrentLevelScore(MatrixQuestion matQue, String currentLevel) {
        if(String.isNotBlank(currentLevel)) {
            switch on currentLevel {
                when 'Level 1: Standard Product (Inventoried Product)' {
                    return matQue.level1Score;
                }
                when 'Level 2: Standard Product (BOM Exists)' {
                    return matQue.level2Score;
                }
                when 'Level 3: Simple BOM Modification' {
                    return matQue.level3Score;
                }
                when 'Level 4: Complex BOM Modification' {
                    return matQue.level4Score;
                }
                when 'Level 5: New Product Development' {
                    return matQue.level5Score;
                }
                when 'Level 6: Contract Manufacturing' {
                    return matQue.level6Score;
                }
            }
        }
        return 0;
    }
    
    public static MatrixQuestion setLevelScores(MatrixQuestion matrixQue, Opportunity_Matrix__mdt mtdt) {
        if((matrixQue.level1Score == null || matrixQue.level1Score == 0)
           && (mtdt.Level_1_Priority_Score__c != null && mtdt.Level_1_Priority_Score__c > 0)) {
               matrixQue.level1Score = mtdt.Level_1_Priority_Score__c;
           }
        
        if((matrixQue.level2Score == null || matrixQue.level2Score == 0)
           && (mtdt.Level_2_Priority_Score__c != null && mtdt.Level_2_Priority_Score__c > 0)) {
               matrixQue.level2Score = mtdt.Level_2_Priority_Score__c;
           }
        
        if((matrixQue.level3Score == null || matrixQue.level3Score == 0)
           && (mtdt.Level_3_Priority_Score__c != null && mtdt.Level_3_Priority_Score__c > 0)) {
               matrixQue.level3Score = mtdt.Level_3_Priority_Score__c;
           }
        
        if((matrixQue.level4Score == null || matrixQue.level4Score == 0)
           && (mtdt.Level_4_Priority_Score__c != null && mtdt.Level_4_Priority_Score__c > 0)) {
               matrixQue.level4Score = mtdt.Level_4_Priority_Score__c;
           }
        
        if((matrixQue.level5Score == null || matrixQue.level5Score == 0)
           && (mtdt.Level_5_Priority_Score__c != null && mtdt.Level_5_Priority_Score__c > 0)) {
               matrixQue.level5Score = mtdt.Level_5_Priority_Score__c;
           }
        
        if((matrixQue.level6Score == null || matrixQue.level6Score == 0)
           && (mtdt.Level_6_Priority_Score__c != null && mtdt.Level_6_Priority_Score__c > 0)) {
               matrixQue.level6Score = mtdt.Level_6_Priority_Score__c;
           }
        return matrixQue;
    }
    
    public static String buildOpportunityQuery(Set<String> fields, Id recordId) {
        String query = 'SELECT ';
        query += String.join(new List<String>(fields), ',');
        query += ' FROM Opportunity ';
        if(String.isNotBlank(recordId)) {
            query += ' WHERE Id = \''+recordId+'\'';
        }
        return query;
    }
   
    public static Question setSelectedAnswer(Question que, Opportunity opp) {
        if(que.fieldType.equalsIgnoreCase('String')
           || que.fieldType.equalsIgnoreCase('TEXTAREA')
           || que.fieldType.equalsIgnoreCase('PICKLIST')) {
               que.selectedAnswer = (String)opp.get(que.fieldApiName);
               que.isAnswered = true;
        }
        else if(que.fieldType.equalsIgnoreCase('Boolean')) {
            que.selectedAnswerBoolean = (Boolean)opp.get(que.fieldApiName);
            que.isAnswered = que.selectedAnswerBoolean;
        }
        else if(que.fieldType.equalsIgnoreCase('Date')) {
            //que.selectedAnswer = (Date)opp.get(que.fieldApiName);
        }
        else if(que.fieldType.equalsIgnoreCase('DateTime')) {
            //que.selectedAnswer = (DateTime)opp.get(que.fieldApiName);
        }
        
        return que;
    }
    
    public static List<String> getApplicableLevelsForThisQuestion(Opportunity_Matrix__mdt mtdt) {
        List<String> applicableLevels = new List<String>();
        if(mtdt.Level_1__c) {
            applicableLevels.add('Level 1: Standard Product (Inventoried Product)');
        }
        if(mtdt.Level_2__c) {
            applicableLevels.add('Level 2: Standard Product (BOM Exists)');
        }
        if(mtdt.Level_3__c) {
            applicableLevels.add('Level 3: Simple BOM Modification');
        }
        if(mtdt.Level_4__c) {
            applicableLevels.add('Level 4: Complex BOM Modification');
        }
        if(mtdt.Level_5__c) {
            applicableLevels.add('Level 5: New Product Development');
        }
        if(mtdt.Level_6__c) {
            applicableLevels.add('Level 6: Contract Manufacturing');
        }
        return applicableLevels;
    }
    
    public static Boolean isThisQuestionApplicableForGivenLevel(Opportunity_Matrix__mdt mtdt, String currentLevel) {
        if(String.isNotBlank(currentLevel)) {
            switch on currentLevel {
                when 'Level 1: Standard Product (Inventoried Product)' {
                    if(mtdt.Level_1__c)
                        return true;
                }
                when 'Level 2: Standard Product (BOM Exists)' {
                    if(mtdt.Level_2__c)
                        return true;
                }
                when 'Level 3: Simple BOM Modification' {
                    if(mtdt.Level_3__c)
                        return true;
                }
                when 'Level 4: Complex BOM Modification' {
                    if(mtdt.Level_4__c)
                        return true;
                }
                when 'Level 5: New Product Development' {
                    if(mtdt.Level_5__c)
                        return true;
                }
                when 'Level 6: Contract Manufacturing' {
                    if(mtdt.Level_6__c)
                        return true;
                }
            }
        }
        return false;
    }
    
    public static String buildMatrixQuery() {
        String query = 'SELECT ';
        List<String> fieldsToQuery = new List<String>();
        fieldsToQuery.add('Id');
        fieldsToQuery.add('DeveloperName');
        fieldsToQuery.add('Question__c');
        fieldsToQuery.add('Field_API_Name__c');
        fieldsToQuery.add('Parent_Question__c');
        fieldsToQuery.add('Group_By__c'); 
        fieldsToQuery.add('Is_Parent__c');
        fieldsToQuery.add('Help_Text__c');
        fieldsToQuery.add('Order__c');
        fieldsToQuery.add('Level_1__c');
        fieldsToQuery.add('Level_2__c');
        fieldsToQuery.add('Level_3__c');
        fieldsToQuery.add('Level_4__c');
        fieldsToQuery.add('Level_5__c');
        fieldsToQuery.add('Level_6__c');
        fieldsToQuery.add('Level_1_Priority_Score__c');
        fieldsToQuery.add('Level_2_Priority_Score__c');
        fieldsToQuery.add('Level_3_Priority_Score__c');
        fieldsToQuery.add('Level_4_Priority_Score__c');
        fieldsToQuery.add('Level_5_Priority_Score__c');
        fieldsToQuery.add('Level_6_Priority_Score__c');
        
        query += String.join(fieldsToQuery, ',');
        query += ' FROM Opportunity_Matrix__mdt ';
        //query += 'WHERE Order__c = 7.0';
        query += ' ORDER BY Order__c ASC';
        return query;
    }
    
    global class Matrix {
        @AuraEnabled public String oppId { get; set; }
        @AuraEnabled public String oppName { get; set; }
        @AuraEnabled public String oppStageName { get; set; }
        @AuraEnabled public String currentLevel { get; set; }
        @AuraEnabled public String oppRecordTypeName { get; set; }
        @AuraEnabled public Date oppCloseDate { get; set; }
        @AuraEnabled public Integer overallQuestionCount { get; set; }
        @AuraEnabled public Integer currentLevelQuestionCount { get; set; }
        @AuraEnabled public List<PicklistOption> availableLevels { get; set; }
        @AuraEnabled public List<MatrixQuestion> matrixQuestions { get; set; }
        
        public Matrix() {
            overallQuestionCount = 0;
            currentLevelQuestionCount = 0;
            matrixQuestions = new List<MatrixQuestion>();
            availableLevels = new List<PicklistOption>();
        }
    }
    
    global class MatrixQuestion {
        @AuraEnabled public String questionType { get; set; }
        @AuraEnabled public Boolean isAnswered { get; set; }
        @AuraEnabled public Boolean isLevel6Question { get; set; }
        @AuraEnabled public Boolean isApplicableForCurrentLevel { get; set; }
        @AuraEnabled public List<String> applicableLevels { get; set; }
        //possible question types : group, parent-child, individual
        //for group : groupName, List<Question> childQuestions
        //for parent-child : parentQuestion, List<Question> childQuestions
        //for individual : question
        
        @AuraEnabled public String groupName { get; set; }
        
        @AuraEnabled public Decimal level1Score { get; set; }
        @AuraEnabled public Decimal level2Score { get; set; }
        @AuraEnabled public Decimal level3Score { get; set; }
        @AuraEnabled public Decimal level4Score { get; set; }
        @AuraEnabled public Decimal level5Score { get; set; }
        @AuraEnabled public Decimal level6Score { get; set; }
        
        @AuraEnabled public Question question { get; set; }
        @AuraEnabled public Question parentQuestion { get; set; }
        @AuraEnabled public List<Question> childQuestions { get; set; }
        
        public MatrixQuestion() {
            isAnswered = false;
            applicableLevels = new List<String>();
            level1Score = 0;
            level2Score = 0;
            level3Score = 0;
            level4Score = 0;
            level5Score = 0;
            level6Score = 0;
        }
    }
    
    global class Question {
        @AuraEnabled public String questionId { get; set; }
        @AuraEnabled public String questionLabel { get; set; }
        @AuraEnabled public String fieldApiName { get; set; }
        @AuraEnabled public String fieldType { get; set; }
        @AuraEnabled public String helpText { get; set; }
        @AuraEnabled public List<PicklistOption> options { get; set; }
        @AuraEnabled public String selectedAnswer { get; set; }
        @AuraEnabled public Boolean selectedAnswerBoolean { get; set; }
        @AuraEnabled public Boolean isAnswered { get; set; }
        
        public Question() {
            fieldType = '';
            questionLabel = '';
            helpText = '';
            selectedAnswerBoolean = false;
            isAnswered = false;
        }
    }
    
    global class PicklistOption {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
        
        public PicklistOption() {
            
        }
        public PicklistOption(String l, String v) {
            label = l;
            value = v;
        }
    }
}