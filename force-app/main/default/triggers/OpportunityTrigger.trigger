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
trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(Trigger.isInsert) {
        if(Trigger.isAfter) {
            OpportunityTriggerHelper.createOpportunityTeam(Trigger.new);
        }
    }
}