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
public class CaseTriggerHelper {
    public static void assignCase (List<Case> newList) {
        List<String> caseIds = new List<String> ();
        for(Case cs : newList) {
            if(cs.Case_Type__c !=  NULL) {
                caseIds.add(cs.Id);
            }
        }
        if(caseIds.size() > 0) {
            assignCase (caseIds);
        }
    }
    @future
    public static void assignCase (List<String> caseIds) {

        List<Case> newList = [SELECT Id, Case_Type__c, AccountId, OwnerId FROM Case WHERE Id IN :caseIds];
        List<Case> updateCaseList = new List<Case> ();
        List<Case> eligibleList = new List<Case> ();

        Map<Id,Map<String, AccountTeamMember>> accMap = new Map<Id, Map<String, AccountTeamMember>> ();
        for(Case cs : newList) {
            if(cs.Case_Type__c !=  NULL && cs.AccountId != NULL) {
                eligibleList.add(cs);
                accMap.put(cs.AccountId, new Map<String, AccountTeamMember> ());
            }
        }
        for(AccountTeamMember atm: [SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMember WHERE AccountId IN :accMap.keySet()]) {
            accMap.get(atm.AccountId).put(atm.TeamMemberRole, atm);
        }
        for(Case cs : eligibleList) {
            if(accMap.get(cs.AccountId).size() > 0) {
                if (cs.Case_Type__c == 'Service Related Issue/Inquiry') {
                    if(accMap.get(cs.AccountId).get('Customer Service Rep') != NULL) {
                        cs.OwnerId = accMap.get(cs.AccountId).get('Customer Service Rep').UserId;
                        updateCaseList.add(cs);
                    }
                } else if (cs.Case_Type__c == 'Product Problem/Technical Guidance') {
                    if(accMap.get(cs.AccountId).get('Technical Service Rep') != NULL) {
                        cs.OwnerId = accMap.get(cs.AccountId).get('Technical Service Rep').UserId;
                        updateCaseList.add(cs);
                    }
                }
            }
        }
        update updateCaseList;
    }
}