@isTest
public class SlackOpportunityPublisherTest {
    
    static testMethod void testPost() {
        Boolean success = true;
        try {
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
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Proposal';
        opp.AccountId = acc.Id;
        opp.CloseDate = system.today()+1;
        insert opp;
	        SlackOpportunityPublisher.postToSlack(new List<Id> { opp.Id });
        } catch (Exception e) {
            success = false;
        } finally {
	        System.assert(success);
        }
    }

}