@isTest
public class OpportunityMatrixControllerTest {

    @testSetup
    static void createTestData() {
        Account account = TestDataFactory.getAccount('TestAccount');
        insert account;
        
        Opportunity opp = TestDataFactory.getOpportunity(account.Id, 'Test Opp', 'Existing Business', 'New');
        insert opp;
        
    }
    
    @isTest
    static void test_getMatrixByLevel() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];
        
        Test.startTest();
        OpportunityMatrixController.Matrix matrix = OpportunityMatrixController.getMatrixByLevel(opp.Id);
        Test.stopTest();
        
        System.assertEquals('Undecided', matrix.currentLevel);
    }
    
    @isTest
    static void test_saveMatrixToOpportunity_Level1() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];
        OpportunityMatrixController.Matrix matrix = OpportunityMatrixController.getMatrixByLevel(opp.Id);
        
        Test.startTest();
        matrix.matrixQuestions[0].isAnswered = true;
        matrix.currentLevel = 'Level 1: Standard Product (Inventoried Product)';
        matrix = OpportunityMatrixController.saveMatrixToOpportunity(matrix);
        Test.stopTest();
        
        Id commercialBusinessRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Business_as_Usual').getRecordTypeId();
        opp = [SELECT Id, RecordTypeId FROM Opportunity WHERE ID = :opp.Id];
        System.assertEquals(commercialBusinessRtId, opp.RecordTypeId);
    }
    
    @isTest
    static void test_saveMatrixToOpportunity_Level2() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];
        OpportunityMatrixController.Matrix matrix = OpportunityMatrixController.getMatrixByLevel(opp.Id);
        
        Test.startTest();
        matrix.matrixQuestions[0].isAnswered = true;
        matrix.currentLevel = 'Level 2: Standard Product (BOM Exists)';
        matrix = OpportunityMatrixController.saveMatrixToOpportunity(matrix);
        Test.stopTest();
        
        Id commercialBusinessRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Business_as_Usual').getRecordTypeId();
        opp = [SELECT Id, RecordTypeId FROM Opportunity WHERE ID = :opp.Id];
        System.assertEquals(commercialBusinessRtId, opp.RecordTypeId);
    }
    
    @isTest
    static void test_saveMatrixToOpportunity_Level3() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];
        OpportunityMatrixController.Matrix matrix = OpportunityMatrixController.getMatrixByLevel(opp.Id);
        
        Test.startTest();
        matrix.matrixQuestions[0].isAnswered = true;
        matrix.currentLevel = 'Level 3: Simple BOM Modification';
        matrix = OpportunityMatrixController.saveMatrixToOpportunity(matrix);
        Test.stopTest();
        
        Id commercialBusinessRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Business_as_Usual').getRecordTypeId();
        opp = [SELECT Id, RecordTypeId FROM Opportunity WHERE ID = :opp.Id];
        System.assertEquals(commercialBusinessRtId, opp.RecordTypeId);
    }
    
    @isTest
    static void test_saveMatrixToOpportunity_Level4() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];
        OpportunityMatrixController.Matrix matrix = OpportunityMatrixController.getMatrixByLevel(opp.Id);
        
        Test.startTest();
        matrix.matrixQuestions[0].isAnswered = true;
        matrix.currentLevel = 'Level 4: Complex BOM Modification';
        matrix = OpportunityMatrixController.saveMatrixToOpportunity(matrix);
        Test.stopTest();
        
        Id commercialBusinessRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Business_as_Usual').getRecordTypeId();
        opp = [SELECT Id, RecordTypeId FROM Opportunity WHERE ID = :opp.Id];
        System.assertEquals(commercialBusinessRtId, opp.RecordTypeId);
    }
    
    @isTest
    static void test_saveMatrixToOpportunity_Level5() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];
        OpportunityMatrixController.Matrix matrix = OpportunityMatrixController.getMatrixByLevel(opp.Id);
        
        Test.startTest();
        matrix.matrixQuestions[0].isAnswered = true;
        matrix.currentLevel = 'Level 5: New Product Development';
        matrix = OpportunityMatrixController.saveMatrixToOpportunity(matrix);
        Test.stopTest();
        
        Id npdRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Product_Development').getRecordTypeId();
        opp = [SELECT Id, RecordTypeId FROM Opportunity WHERE ID = :opp.Id];
        System.assertEquals(npdRtId, opp.RecordTypeId);
    }
    
    @isTest
    static void test_saveMatrixToOpportunity_Level6() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];
        OpportunityMatrixController.Matrix matrix = OpportunityMatrixController.getMatrixByLevel(opp.Id);
        
        Test.startTest();
        matrix.matrixQuestions[0].isAnswered = true;
        matrix.currentLevel = 'Level 6: Contract Manufacturing';
        matrix = OpportunityMatrixController.saveMatrixToOpportunity(matrix);
        Test.stopTest();
        
        Id npdRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Product_Development').getRecordTypeId();
        opp = [SELECT Id, RecordTypeId FROM Opportunity WHERE ID = :opp.Id];
        System.assertEquals(npdRtId, opp.RecordTypeId);
    }
}