@isTest
public class TestDataFactory {

    public static Account getAccount(String name) {
        return new Account(
            Name = name,
            BillingStreet = '1301 North Palm Avenue',
            BillingCity = 'Pembroke Pines',
            BillingState = 'Florida',
            BillingCountry = 'United States',
            BillingPostalCode = '33026',
            ShippingStreet = '1301 North Palm Avenue',
            ShippingCity = 'Pembroke Pines',
            ShippingState = 'Florida',
            ShippingCountry = 'United States',
            ShippingPostalCode = '33026',
            PrimaryType__c = 'Lead'
        ); 
    }
    
    public static Opportunity getOpportunity(Id actId, String name, String type, String stage) {
        return new Opportunity(
            AccountId = actId,
            Name = name, 
            Type = type,
            StageName = stage,
            CloseDate = date.today()
        );
    }
    
}