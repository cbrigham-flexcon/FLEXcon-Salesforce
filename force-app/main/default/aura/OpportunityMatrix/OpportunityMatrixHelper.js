({
	getInitialMatrix : function(component, event, helper) {
        component.set('v.loaded', false);
		var action = component.get("c.getMatrixByLevel");
        action.setParams({ 
            recordId : component.get('v.recordId')
        });
        
        action.setCallback(this, function(response) {
            component.set('v.loaded', true);
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.matrix", response.getReturnValue());
                
                //this.findAndMarkAsAnswered(component, event, helper);
                this.calculateProgress(component, event, helper);
            }
            else if (state === "INCOMPLETE") {
                //error handling
                this.showToastJS('Process still in progress!', 'warning');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToastJS(errors[0].message, 'error');
                    }
                } else {
                    console.log("Unknown error");
                    this.showToastJS('Unknown error', 'error');
                }
            }
        });

        $A.enqueueAction(action);
	},
    
    findAndMarkAsAnswered : function(component, event, helper) {
        var question = JSON.parse(JSON.stringify(event.getParam("currentQuestion")));
        var typeOfQuestion = event.getParam("typeOfQuestion");
        
        console.log(question);
        if(question.fieldType == 'BOOLEAN') {
            if(question.selectedAnswerBoolean) {
                question.isAnswered = true;
            }
            else {
                question.isAnswered = false;
            }
        }
        else {
            if(question.selectedAnswer !== '') {
                question.isAnswered = true;
            }
            else {
                question.isAnswered = false;
            }
        }
        
        //find the question
        var matrix = component.get('v.matrix');
        var questions = matrix.matrixQuestions;
        for(var i = 0; i < questions.length; i++) {
            if(questions[i].questionType == typeOfQuestion) {
                if(typeOfQuestion == 'individual') {
                    if(questions[i].question.questionId == question.questionId) {
                        questions[i].question = question;
                        questions[i].isAnswered = question.isAnswered;
                    }
                }
                else if(typeOfQuestion == 'parent-child') {
                    if(questions[i].parentQuestion.questionId == question.questionId) {
                        questions[i].parentQuestion = question;
                    }
                    else {
                        for(var j = 0; j < questions[i].childQuestions.length; j++) {
                            if(questions[i].childQuestions[j].questionId == question.questionId) {
                                questions[i].childQuestions[j] = question;
                            }
                        }
                    }
                }
                else if(typeOfQuestion == 'group') {
                    for(var j = 0; j < questions[i].childQuestions.length; j++) {
                        if(questions[i].childQuestions[j].questionId == question.questionId) {
                            questions[i].childQuestions[j] = question;
                        }
                    }
                }
            }
        }
        
        //check if all questions are marked
        for(var i = 0; i < questions.length; i++) {
            if(questions[i].questionType == 'parent-child'
               || questions[i].questionType == 'group') {
                var areAllAnswered = true;
                if(questions[i].questionType == 'parent-child'
                   && questions[i].parentQuestion.isAnswered) {
                    //areAllAnswered = false;
                    questions[i].isAnswered = true;
                }
                for(var j = 0; j < questions[i].childQuestions.length; j++) {
                    if(questions[i].childQuestions[j].isAnswered) {
                        //areAllAnswered = false;
                        questions[i].isAnswered = true;
                        break;
                    }
                }
                //questions[i].isAnswered = areAllAnswered;
            }
        }
        
        matrix.matrixQuestions = questions;
        component.set('v.matrix', matrix);
        console.log(component.get('v.matrix'));
    },
    
    calculateProgress : function(component, event, helper) {
        var matrix = component.get('v.matrix');
        var questions = matrix.matrixQuestions;
        
        var selectedLevel = matrix.currentLevel;
        var totalQuestionsCount = 0;
        var answeredQuestionsCount = 0;
        //calculate if level is not selected
        if(selectedLevel == 'Undecided') {
            totalQuestionsCount = matrix.overallQuestionCount;
            for(var i = 0; i < questions.length; i++) {
                if(questions[i].isAnswered) {
                    answeredQuestionsCount++;
                }
            }
        }
        //calculate if level is selected
        else {
            totalQuestionsCount = matrix.currentLevelQuestionCount;
            for(var i = 0; i < questions.length; i++) {
                if(questions[i].isAnswered
                   && questions[i].isApplicableForCurrentLevel) {
                    answeredQuestionsCount++;
                }
            }
        }
        
        var percentOfQuestionsAnswered = (answeredQuestionsCount * 100)/totalQuestionsCount;
        component.set('v.progressIndicator', percentOfQuestionsAnswered.toFixed(2));
    	
        this.suggestAppropriateLevel(component, event, helper);
    },

    suggestAppropriateLevel : function(component, event, helper) {
        var matrix = component.get('v.matrix');
        var questions = matrix.matrixQuestions;
        var level1Label = 'Level 1: Standard Product (Inventoried Product)';
        var level2Label = 'Level 2: Standard Product (BOM Exists)';
        var level3Label = 'Level 3: Simple BOM Modification';
        var level4Label = 'Level 4: Complex BOM Modification';
        var level5Label = 'Level 5: New Product Development';
        var level6Label = 'Level 6: Contract Manufacturing';
        var totalLevel1Questions = 0;
        var totalLevel2Questions = 0;
        var totalLevel3Questions = 0;
        var totalLevel4Questions = 0;
        var totalLevel5Questions = 0;
        var totalLevel6Questions = 0;
        var totalLevel1QuestionsAnswered = 0;
        var totalLevel2QuestionsAnswered = 0;
        var totalLevel3QuestionsAnswered = 0;
        var totalLevel4QuestionsAnswered = 0;
        var totalLevel5QuestionsAnswered = 0;
        var totalLevel6QuestionsAnswered = 0;
        
        for(var i=0; i<questions.length; i++) {
            if(questions[i].applicableLevels.includes(level1Label)) {
                totalLevel1Questions++;
                if(questions[i].isAnswered) {
                    totalLevel1QuestionsAnswered++;
                }
            }
            if(questions[i].applicableLevels.includes(level2Label)) {
                totalLevel2Questions++;
                if(questions[i].isAnswered) {
                    totalLevel2QuestionsAnswered++;
                }
            }
            if(questions[i].applicableLevels.includes(level3Label)) {
                totalLevel3Questions++;
                if(questions[i].isAnswered) {
                    totalLevel3QuestionsAnswered++;
                }
            }
            if(questions[i].applicableLevels.includes(level4Label)) {
                totalLevel4Questions++;
                if(questions[i].isAnswered) {
                    totalLevel4QuestionsAnswered++;
                }
            }
            if(questions[i].applicableLevels.includes(level5Label)) {
                totalLevel5Questions++;
                if(questions[i].isAnswered) {
                    totalLevel5QuestionsAnswered++;
                }
            }
            if(questions[i].applicableLevels.includes(level6Label)) {
                totalLevel6Questions++;
                if(questions[i].isAnswered) {
                    totalLevel6QuestionsAnswered++;
                }
            }
        }
        var prompt = '';
        if(totalLevel6QuestionsAnswered > 0) {
            prompt = 'This looks like a Level 6 Opportunity';
        }
        else if(totalLevel5QuestionsAnswered > 0) {
            prompt = 'This looks like a Level 5 Opportunity';
        }
        else if(totalLevel4QuestionsAnswered > 0) {
            prompt = 'This looks like a Level 4 Opportunity';
        }
        else if(totalLevel3QuestionsAnswered > 0) {
            prompt = 'This looks like a Level 3 Opportunity';
        }
        else if(totalLevel2QuestionsAnswered > 0) {
            prompt = 'This looks like a Level 2 Opportunity';
        }
        else if(totalLevel1QuestionsAnswered > 0) {
            prompt = 'This looks like a Level 1 Opportunity';
        }
        component.set('v.promptLevel', prompt);
        
        //set assistiveText
        var assistiveText = '';
        var allQuestionsAnswered = false;
        var selectedLevel = matrix.currentLevel;
        switch(selectedLevel) {
            case level1Label:
                if(totalLevel1QuestionsAnswered == totalLevel1Questions) {
                    assistiveText = 'All of the recommended information has been shared, please proceed with your product recommendation';
                	allQuestionsAnswered = true;
                }
                else {
                    assistiveText = 'In order to make the best product recommendation it is suggested that you answer the highlighted questions above.'
                }
                break;
            case level2Label:
                if(totalLevel2QuestionsAnswered == totalLevel2Questions) {
                    assistiveText = 'All of the recommended information has been shared, please proceed with your product recommendation';
                    allQuestionsAnswered = true;
                }
                else {
                    assistiveText = 'In order to make the best product recommendation it is suggested that you answer the highlighted questions above.'
                }
                break;
            case level3Label:
                if(totalLevel3QuestionsAnswered == totalLevel3Questions) {
                    assistiveText = 'All of the recommended information has been shared, please proceed with your product recommendation';
                	allQuestionsAnswered = true;
                }
                else {
                    assistiveText = 'In order to make the best product recommendation it is suggested that you answer the highlighted questions above.'
                }
                break;
            case level4Label:
                if(totalLevel4QuestionsAnswered == totalLevel4Questions) {
                    assistiveText = 'All of the recommended information has been shared, please proceed with your product recommendation';
                	allQuestionsAnswered = true;
                }
                else {
                    assistiveText = 'In order to make the best product recommendation it is suggested that you answer the highlighted questions above.'
                }
                break;
            case level5Label:
                if(totalLevel5QuestionsAnswered == totalLevel5Questions) {
                    assistiveText = 'All of the recommended information has been shared, please proceed with the NPD process';
                	allQuestionsAnswered = true;
                }
                else {
                    assistiveText = 'Please answer the highlighted questions above before proceeding with the NPD process.'
                }
                break;
            case level6Label:
                if(totalLevel6QuestionsAnswered == totalLevel6Questions) {
                    assistiveText = 'All of the recommended information has been shared, please proceed with the contract manufacturing process';
                	allQuestionsAnswered = true;
                }
                else {
                    assistiveText = 'Please answer the highlighted questions above before proceeding with the contract manufacturing process.'
                }
                break;
        }
        
        component.set('v.assistiveText', assistiveText);
        component.set('v.assistiveTextSuccess', allQuestionsAnswered);
    },
    
    changeLevel : function(component, event, helper) {
    	var matrix = component.get('v.matrix');
        var questions = matrix.matrixQuestions;
        var selectedLevel = matrix.currentLevel;
        var currentLevelQuestionCount = 0;
        
        for(var i=0; i<questions.length; i++) {
            if(questions[i].applicableLevels.includes(selectedLevel)) {
                questions[i].isApplicableForCurrentLevel = true;
                currentLevelQuestionCount++;
            }
            else {
                questions[i].isApplicableForCurrentLevel = false;
            }
        }
        
        matrix.currentLevelQuestionCount = currentLevelQuestionCount;
        matrix.matrixQuestions = questions;
        component.set('v.matrix', matrix);
        this.calculateProgress(component, event, helper);
    },
    
    showToastJS : function(messageStr, typeStr) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Opportunity Matrix',
            message: messageStr,
            duration:'5000',
            key: 'info_alt',
            type: typeStr,
            mode: 'pester'
        });
        toastEvent.fire();
    },
})