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
public with sharing class OpportunityTriggerHelper {
    public static void createOpportunityTeam(List<Opportunity> newList) {
        List<String> accountIds = new List<String> ();
        List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();
        Map<Id, List<AccountTeamMember>> atmMap = new Map<Id, List<AccountTeamMember>> ();
        Map<Id, Account> accountMap = new Map<Id, Account> ();

        for (Opportunity opp : newList) {
            accountIds.add(opp.AccountId);
        }

        accountMap.putAll([
                SELECT Id, OwnerId
                FROM Account
                WHERE Id IN :accountIds
        ]);

        for (AccountTeamMember atm : [
                SELECT Id, UserId, TeamMemberRole, AccountAccessLevel, AccountId
                FROM AccountTeamMember
                WHERE AccountId IN :accountIds
        ]) {
            if (!atmMap.containsKey(atm.AccountId)) {
                atmMap.put(atm.AccountId, new List<AccountTeamMember>());
            }
            atmMap.get(atm.AccountId).add(atm);
        }

        for(Opportunity opp: newList) {
            if(atmMap.containsKey(opp.AccountId)){
                for(AccountTeamMember atm: atmMap.get(opp.AccountId)) {
                    OpportunityTeamMember otm = new OpportunityTeamMember();
                    otm.OpportunityId = opp.Id;
                    otm.UserId = atm.UserId;
                    otm.TeamMemberRole = atm.TeamMemberRole;
                    otm.OpportunityAccessLevel = atm.AccountAccessLevel;
                    otmList.add(otm);
                }
            }
            Account acc = accountMap.get(opp.AccountId);

            OpportunityTeamMember otm = new OpportunityTeamMember();
            otm.OpportunityId = opp.Id;
            otm.UserId = acc.OwnerId;
            otm.TeamMemberRole = 'Account Owner';
            otm.OpportunityAccessLevel = 'Edit';
            otmList.add(otm);
        }

        if(otmList.size() > 0)
            insert otmList;
    }

}