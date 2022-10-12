/*
* @author naveen
* @date 05/09/18 
* @description 
* @Change History
*
*   Tag         Author              Date         Incident No.   Requested-BY      Description     
* *****************************************************************************************************************              
*   1.0.0       naveen            05/09/18                                        Initial Version 
* *****************************************************************************************************************/
public with sharing class SampleRequestProductsAuraController {
    @AuraEnabled
    public static String getLineItems(String parentId) {
        SampleRequestMainWrapper srm = new SampleRequestMainWrapper();

        for (Sample_Lab_Request_Products__c slrp : [
                SELECT Id, S_No__c, Product_Text__c, Sample_Product__c, Sample_Product__r.Name, Unit_Price__c, UOM__c,
                        Sample_Product__r.Category__c, Location__c, Size__c, Quantity__c, Sample_Lab_Request__c
                FROM Sample_Lab_Request_Products__c
                WHERE Sample_Lab_Request__c = :parentId
                ORDER BY S_No__c ASC
        ]) {
            if (slrp.Sample_Product__r.Category__c == 'Sample') {
                srm.SampleList.add(slrp);
            } else if (slrp.Sample_Product__r.Category__c == 'Marketing') {
                srm.MarketingList.add(slrp);
            } else if (slrp.Sample_Product__r.Category__c == 'Other') {
                srm.OtherList.add(slrp);
            }
        }
        return JSON.serialize(srm);
    }
    @AuraEnabled
    public static String getProducts(String category, String searchString) {
        searchString = '%' + searchString + '%';
        System.debug(category);
        System.debug(searchString);
        List<Sample_Products__c> sampleProducts = new List<Sample_Products__c> ();
        sampleProducts.addAll([
                SELECT Id, Name, Category__c, Location__c, Market__c, Product__c, Size__c, Type__c, UOM__c, Unit_Price__c
                FROM Sample_Products__c
                WHERE Category__c = :category
                AND Name LIKE :searchString
        ]);
        return JSON.serialize(sampleProducts);
    }
    @AuraEnabled
    public static void add(String parentId, String lineItemsString) {
        List<String> productIds = (List<String>) JSON.deserialize (lineItemsString, List<String>.class);
        List<Sample_Lab_Request_Products__c> slrps = new List<Sample_Lab_Request_Products__c> ();
        Map<Id,Sample_Products__c> sampleProducts = new Map<Id,Sample_Products__c>();
        sampleProducts.putAll([
                SELECT Id, Name, Category__c, Location__c, Market__c, Product__c, Size__c, Type__c, UOM__c, Unit_Price__c
                FROM Sample_Products__c
                WHERE Id IN :productIds
        ]);
        for(String productId : productIds) {
            Sample_Products__c sp = sampleProducts.get(productId);
            Sample_Lab_Request_Products__c slrp = new Sample_Lab_Request_Products__c();
            slrp.Sample_Product__c = productId;
            slrp.Sample_Lab_Request__c = parentId;
            slrp.Size__c = sp.Size__c;
            slrp.Product_Text__c = sp.Product__c;
            slrp.Location__c = sp.Location__c;
            slrp.Quantity__c = 0;
            slrp.Unit_Price__c = sp.Unit_Price__c;
            slrp.UOM__c = sp.UOM__c;
            slrps.add(slrp);
        }
        insert slrps;
    }
    @AuraEnabled
    public static void save(String lineItemsString) {
        SampleRequestMainWrapper srm = (SampleRequestMainWrapper) JSON.deserialize(lineItemsString, SampleRequestMainWrapper.class);
        if(srm.SampleList != null && srm.SampleList.size() > 0){
            upsert srm.SampleList;
        }
        if(srm.MarketingList != null && srm.MarketingList.size() > 0){
            upsert srm.MarketingList;
        }
        if(srm.OtherList != null && srm.OtherList.size() > 0){
            upsert srm.OtherList;
        }
    }
    @AuraEnabled
    public static void remove(String removeLIString) {
        Sample_Lab_Request_Products__c slrp = (Sample_Lab_Request_Products__c) JSON.deserialize (removeLIString, Sample_Lab_Request_Products__c.class);
        delete slrp;
    }
    @AuraEnabled
    public static void updateLI(String removeLIString) {
        Sample_Lab_Request_Products__c slrp = (Sample_Lab_Request_Products__c) JSON.deserialize (removeLIString, Sample_Lab_Request_Products__c.class);
        update slrp;
    }
}