public class SLRAddressAuraController {
    
    @AuraEnabled
    public static Sample_Lab_Request__c getSLRRecord(String slrId) {
        Sample_Lab_Request__c slr = [SELECT Id, City__c,street__c, State__c, Country__c
                                     FROM Sample_Lab_Request__c where Id = :slrId LIMIT 1];
        return slr;
    }
    
    @AuraEnabled
    public static Sample_Lab_Request__c updateSLR(String slrId,String street,String city,String state,String country) {
        Sample_Lab_Request__c slr = new Sample_Lab_Request__c(Id=slrId,street__c=street,City__c=city,
                                                              State__c=state,Country__c=country);
        update slr;
        return slr;
    }

}