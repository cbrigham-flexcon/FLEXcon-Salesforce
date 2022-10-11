/*
* @author naveen
* @date 06/09/18 
* @description 
* @Change History
*
*   Tag         Author              Date         Incident No.   Requested-BY      Description     
* *****************************************************************************************************************              
*   1.0.0       naveen            06/09/18                                        Initial Version 
* *****************************************************************************************************************/
trigger CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(Trigger.isInsert) {
        if(Trigger.isBefore) {

        }
        if(Trigger.isAfter) {
            CaseTriggerHelper.assignCase(Trigger.New);
        }
    }
}