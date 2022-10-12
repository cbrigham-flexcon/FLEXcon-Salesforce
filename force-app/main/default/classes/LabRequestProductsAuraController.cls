/*
* @author naveen
* @date 31/08/18 
* @description 
* @Change History
*
*   Tag         Author              Date         Incident No.   Requested-BY      Description     
* *****************************************************************************************************************              
*   1.0.0       naveen            31/08/18                                        Initial Version 
* *****************************************************************************************************************/
public with sharing class LabRequestProductsAuraController {

    @AuraEnabled
    public static List<Sample_Lab_Request_Products__c> getLineItems(String parentId) {
        List<Sample_Lab_Request_Products__c> lineItems = new List<Sample_Lab_Request_Products__c> ();
        lineItems.addAll([
                SELECT Id, S_No__c, Product_Text__c, Coat_Weight__c, Quantity__c, Size__c, Special_Instructions__c
                FROM Sample_Lab_Request_Products__c
                WHERE Sample_Lab_Request__c = :parentId
                ORDER BY S_No__c ASC
        ]);
        integer i = 0;
        for(Sample_Lab_Request_Products__c slrp : lineItems) {
            slrp.S_No__c = i;
            i++;
        }
        return lineItems;
    }
    @AuraEnabled
    public static void save(String lineItemsString) {
        List<Sample_Lab_Request_Products__c> lineItems = (List<Sample_Lab_Request_Products__c>) JSON.deserialize(lineItemsString, List<Sample_Lab_Request_Products__c>.class);
        upsert lineItems;
    }
    @AuraEnabled
    public static List<Sample_Lab_Request_Products__c> add(String parentId, String lineItemsString) {
        List<Sample_Lab_Request_Products__c> lineItems = (List<Sample_Lab_Request_Products__c>) JSON.deserialize(lineItemsString, List<Sample_Lab_Request_Products__c>.class);
        lineItems.add(new Sample_Lab_Request_Products__c(S_No__c = lineItems.size(), Sample_Lab_Request__c = parentId));
        return lineItems;
    }
    @AuraEnabled
    public static List<Sample_Lab_Request_Products__c> remove(String removeLIString, String lineItemsString) {
        System.debug(removeLIString);
        Sample_Lab_Request_Products__c removeli = (Sample_Lab_Request_Products__c) JSON.deserialize(removeLIString, Sample_Lab_Request_Products__c.class);
        List<Sample_Lab_Request_Products__c> lineItems = (List<Sample_Lab_Request_Products__c>) JSON.deserialize(lineItemsString, List<Sample_Lab_Request_Products__c>.class);
        List<Sample_Lab_Request_Products__c> newLineItems = new List<Sample_Lab_Request_Products__c> ();
        List<Sample_Lab_Request_Products__c> delLineItems = new List<Sample_Lab_Request_Products__c> ();
        if (lineItems.size() > 1) {
            for (Sample_Lab_Request_Products__c slrp : lineItems) {
                if ((slrp.Id != NULL && slrp.Id == removeli.Id) || slrp.S_No__c == removeli.S_No__c) {
                    if (slrp.Id != NULL)
                        delLineItems.add(slrp);
                } else {
                    newLineItems.add(slrp);
                }
            }
            if (delLineItems.size() > 0)
                delete delLineItems;
            return newLineItems;
        } else {
            return lineItems;
        }

    }
}