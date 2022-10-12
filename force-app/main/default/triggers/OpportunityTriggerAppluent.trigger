/**
 *  About
 *  -----
 *  Author: Appluent
 *  Create date: 11th Jan 2021
 *  
 *  Details
 *  -----

 *  Update History
 *  -----
 *  
 *  Issues / TODOs
 *  ----- 
 *
**/
trigger OpportunityTriggerAppluent on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    Trigger_Activation__mdt activationCheck = Trigger_Activation__mdt.getinstance('OpportunityTriggerAppluent');
    System.debug(activationCheck);
    if(activationCheck.active__c){
        //Appluent 20210111
        if(Trigger.isUpdate) {
            if(Trigger.isBefore) {
                OpportunityTriggerHandler.contactRoleValidation(Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
        }
    }
}