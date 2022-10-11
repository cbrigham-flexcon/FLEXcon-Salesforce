trigger SampleLabRequestTrigger on Sample_Lab_Request__c (before insert, after Update) {
    
    if(Trigger.isBefore && Trigger.isInsert) {
        SampleLabRequestTriggerHelper.populateAddressFields(Trigger.New); 
    }
    
    if(Trigger.isUpdate) {
        if(Trigger.isAfter) {
            SampleLabRequestTriggerHelper.sendShippedNotification (Trigger.New, Trigger.oldMap);
        }
    }
}