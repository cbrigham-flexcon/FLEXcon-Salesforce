/**
 *  About
 *  -----
 *  Author: Appluent
 *  Create date: Jane 2021
 *  
 *  Details
 *  -----
 *  One of the class that is the handler class of trigger 'OpportunityTrigger'.
 *  Update History
 *  -----
 *  
 *  Issues / TODOs
 *  ----- 
 *
**/

public with sharing class OpportunityTriggerHandler {

    //validate  contactRole
    public static void contactRoleValidation(List<Opportunity> newOppList, Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        
        List<OpportunityContactRole> oppContactRoleList = [SELECT 
                                                            Id, OpportunityId
                                                            FROM OpportunityContactRole
                                                            WHERE OpportunityId IN :newMap.keyset() ];
        //keeping the count though not neccessary
        Map<Id,Integer> mapOppIdToContactRoleCount = new Map<Id,Integer>();
        if(!oppContactRoleList.isEmpty()){
            for(OpportunityContactRole oneContRole : oppContactRoleList){
                if(mapOppIdToContactRoleCount.get(oneContRole.OpportunityId) != null){
                    Integer contCount = mapOppIdToContactRoleCount.get(oneContRole.OpportunityId) + 1;
                    mapOppIdToContactRoleCount.put(oneContRole.OpportunityId,contCount);
                }else{
                    mapOppIdToContactRoleCount.put(oneContRole.OpportunityId,1);
                }
            }
        }

        System.debug(mapOppIdToContactRoleCount);

        //check if Status changed to Qualification)
        for(Opportunity oneOpp : newOppList){
            if(oneOpp.StageName != oldMap.get(oneOpp.Id).StageName){
                if(oneOpp.StageName != 'New' && oneOpp.StageName != 'Closed Lost'){ 
                    //check if contact Roles Exist
                    if( !(mapOppIdToContactRoleCount.get(oneOpp.Id) != null) ){
                        //contact role does not exists
                        oneOpp.addError('Contact Role Required to Update the Status.');
                    }
                }
            }
        }

    }
    

}