/////***** Test class for SLRAddressAuraController ****////

@isTest
public class SLRAddressAuraControllerTest 
{
    static testMethod void getTest() {
        test.startTest();
        
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
        
        Sample_Lab_Request__c testSLR = new Sample_Lab_Request__c();
        testSLR.Account__c = Acc.Id;
        testSLR.Status__c = 'New';
        testSLR.Ship_Via__c = 'FedEx - Ground';
        testSLR.Custom_Letter__c = 'No';
        insert testSLR;
        
        List<Sample_Lab_Request__c> newList = new List<Sample_Lab_Request__c>();
        newList.add(testSLR);
        SampleLabRequestTriggerHelper.populateAddressFields(newList);
        
        System.assert(SLRAddressAuraController.getSLRRecord(testSLR.Id) != null);
        testSLR = SLRAddressAuraController.updateSLR(testSLR.Id, 'updatedstreet', 'updatedcity', 'updatedstate', 'updatedcountry');
        System.assert(testSLR.Street__c == 'updatedstreet');
        test.stopTest();
    }
}