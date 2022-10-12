/*
* @author naveen
* @date 25/10/18 
* @description 
* @Change History
*
*   Tag         Author              Date         Incident No.   Requested-BY      Description     
* *****************************************************************************************************************              
*   1.0.0       naveen            25/10/18                                        Initial Version 
* *****************************************************************************************************************/
@isTest
public with sharing class OpportunityTriggerHelperTest {
    @isTest
    public static void createOpportunityTeamTest() {
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
        accountteammember atm = new accountteammember();
        atm.userId = userinfo.getUserId();
        atm.AccountId = acc.Id;
        atm.AccountAccessLevel = 'edit';
        atm.TeamMemberRole = 'Account Manager';
        insert atm;
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Proposal';
        opp.AccountId = acc.Id;
        opp.CloseDate = system.today()+1;
        insert opp;
    }
}