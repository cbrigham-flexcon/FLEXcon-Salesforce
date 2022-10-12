/*
* @author naveen
* @date 06/09/18 
* @description 
* @Change History
*
*   Tag         Author              Date         Incident No.   Requested-BY      Description     
* *****************************************************************************************************************              
*   1.0.0       naveen            06/09/18                                        Initial Version 
* *****************************************************************************************************************/
@isTest
public with sharing class CaseTriggerHelperTest {
    @isTest
    public static void caseAssignmentTest () {
        Account acc = new Account ();
        acc.Name = 'Test';
        acc.CUSNO__c = '12312';
        acc.BillingCity = 'LA';
        acc.BillingCountry = 'United States';
        //acc.BillingCountryCode = '94203';
        acc.BillingState = 'Alaska';
        acc.BillingStreet = '1st Ave';
        acc.BillingPostalCode = '1234';
        insert acc;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.UserId = userInfo.getUserId();
        atm.AccountId = acc.Id;
        atm.TeamMemberRole = 'Technical Service Rep';
        insert atm;
        
        Case cs = new Case();
        cs.AccountId = acc.Id;
        cs.Case_Type__c = 'Service Related Issue/Inquiry';
        insert cs;
        
        
    }
    @isTest
    public static void caseAssignmentTest2 () {
        Account acc = new Account ();
        acc.Name = 'Test';
        acc.CUSNO__c = '12312';
        acc.BillingCity = 'NY';
        acc.BillingCountry = 'United States';
        //acc.BillingCountryCode = '94203';
        acc.BillingState = 'Alaska';
        acc.BillingStreet = '1st Ave';
        acc.BillingPostalCode = '1234';
        insert acc;
        
        AccountTeamMember atm2 = new AccountTeamMember();
        atm2.UserId = userInfo.getUserId();
        atm2.AccountId = acc.Id;
        atm2.TeamMemberRole = 'Customer Service Rep';
        insert atm2;
        
        Case cs = new Case();
        cs.AccountId = acc.Id;
        cs.Case_Type__c = 'Product Problem/Technical Guidance';
        insert cs;
    }
}