@isTest
public with sharing class SampleLabRequestTriggerHelperTest {
    @isTest
    public static void simpleTest1() {
       Account acc = new Account();
        acc.Name = 'Test';
        acc.CUSNO__c = '123';
        acc.ShippingStreet = 'test';
        acc.ShippingCity = 'new york';
        acc.ShippingCountry = 'United States';
        acc.ShippingState = 'Alaska';
        acc.BillingStreet = 'test';
        acc.BillingCity = 'new york';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'Alaska';
        acc.BillingPostalCode = '1234';
        acc.PrimaryType__c = 'Customer';
        insert acc; 
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = acc.Id;
        atm.UserId = userinfo.getUserId();
        atm.TeamMemberRole = 'Manager';
        insert atm;
        
        Sample_Lab_Request__c slr = new Sample_Lab_Request__c();
        slr.Account__c = acc.Id;
        insert slr;
        
        slr.Status__c = 'Shipped';
        update slr;
    }
}