/*
* @author naveen
* @date 01/09/18 
* @description 
* @Change History
*
*   Tag         Author              Date         Incident No.   Requested-BY      Description     
* *****************************************************************************************************************              
*   1.0.0       naveen            01/09/18                                        Initial Version 
* *****************************************************************************************************************/
@isTest
public with sharing class LabRequestProductsAuraControllerTest {
    @isTest
    public static void test1() {
        Sample_Lab_Request__c slr = new Sample_Lab_Request__c();
        insert slr;
        Sample_Lab_Request_Products__c slrp = new Sample_Lab_Request_Products__c();
        slrp.Sample_Lab_Request__c = slr.Id;
        insert slrp;
        Sample_Lab_Request_Products__c slrp2 = new Sample_Lab_Request_Products__c();
        slrp2.Sample_Lab_Request__c = slr.Id;
        insert slrp2;
        List<Sample_Lab_Request_Products__c> lineItems = LabRequestProductsAuraController.getLineItems(slr.Id);
        String lineItemsString = JSON.serialize(lineItems);
        LabRequestProductsAuraController.save(lineItemsString);
        LabRequestProductsAuraController.add(slr.Id,lineItemsString);
        LabRequestProductsAuraController.remove(JSON.serialize(slrp),lineItemsString);
    }
}