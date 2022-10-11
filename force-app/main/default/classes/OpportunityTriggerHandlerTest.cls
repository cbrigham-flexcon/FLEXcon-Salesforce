/**
 *  About
 *  -----
 *  Author: Appluent
 *  Create date: Jane 2021
 *  
 *  Details
 *  -----
 * Test Class
 *  Update History
 *  -----
 *  
 *  Issues / TODOs
 *  ----- 
 *
**/
@isTest
public class OpportunityTriggerHandlerTest {

    @isTest
    public static void validationTest() {
        Account testAccount = new Account();
        testAccount.name = 'TestAccountName';
        testAccount.phone = '1234';
        testAccount.website = 'tejender@appluent.net';
        testAccount.BillingCity ='Delhi';
        testAccount.BillingCountry = 'India';
        testAccount.BillingState ='Delhi';
        testAccount.BillingStreet ='ABC';
        testAccount.BillingPostalCode ='1234';
        Insert testAccount;

        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = testAccount.Id;
        testOpp.Name = 'TestOpps';
        testOpp.StageName = 'New';
        testOpp.CloseDate = Date.Today();
        

        Test.startTest();
            Insert testOpp;
            System.assertEquals(1, [SELECT count() FROM opportunity]);
            testOpp.StageName = 'Qualification';
            try{
                update testOpp;
            }catch(Exception e){
                system.debug('ERROR 01');
            }
                
        Test.stopTest();
    
    }

    @isTest
    public static void withContactRoleValidationTest() {
        Account testAccount = new Account();
        testAccount.name = 'TestAccountName';
        testAccount.phone = '1234';
        testAccount.website = 'tejender@appluent.net';
        testAccount.BillingCity ='Delhi';
        testAccount.BillingCountry = 'India';
        testAccount.BillingState ='Delhi';
        testAccount.BillingStreet ='ABC';
        testAccount.BillingPostalCode ='1234';
        Insert testAccount;

        Contact testContact = new Contact();
        testContact.LastName = 'testLastName';
        testContact.AccountId = testAccount.Id;
        testContact.email = 'test@appluent.net';
        testContact.Contacts_Department__c = 'Finance';
        insert testContact;


        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = testAccount.Id;
        testOpp.Name = 'TestOpps';
        //Closed Won Check 
        testOpp.StageName = 'Close Won';
        testOpp.CloseDate = Date.Today();

        Insert testOpp;

        //create ContactRole Plan OpportunityContactRole
        OpportunityContactRole newOppConRole = new OpportunityContactRole();
        newOppConRole.OpportunityId = testOpp.Id;
        newOppConRole.ContactId = testContact.Id;

        OpportunityContactRole newOppConRole02 = new OpportunityContactRole();
        newOppConRole02.OpportunityId = testOpp.Id;
        newOppConRole02.ContactId = testContact.Id;

        List<OpportunityContactRole> listConRole = new List<OpportunityContactRole>();
        listConRole.add(newOppConRole02);
        listConRole.add(newOppConRole);

        insert listConRole;

        Test.startTest();
            testOpp.StageName = 'Qualification';
            update testOpp;
        Test.stopTest();

    }

  


}