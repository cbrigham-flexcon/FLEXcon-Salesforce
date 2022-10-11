public class SampleLabRequestTriggerHelper {
    public static void sendShippedNotification(List<Sample_Lab_Request__c> newList, Map<Id, Sample_Lab_Request__c> oldMap) {
        List<Id> accountsList = new List<Id>();
        List<Sample_Lab_Request__c> eligibleList = new List<Sample_Lab_Request__c> ();
        Map<String, List<String>> accToTeamMap = new Map<String, List<String>>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage> ();
        for (Sample_Lab_Request__c s : newList) {
            if (s.Status__c == 'Shipped' && oldMap.get(s.Id).Status__c != s.Status__c) {
                eligibleList.add(s);
                accountsList.add(s.Account__c);
            }
        }
        if(eligibleList.size() == 0)
            return;

        for (AccountTeamMember aTM : [
                SELECT Id, AccountId, User.Email
                FROM AccountTeamMember
                WHERE AccountId IN :accountsList
        ]) {
            if(!accToTeamMap.containsKey(aTM.AccountId)) {
                accToTeamMap.put(aTM.AccountId, new List<String> ());
            }
            accToTeamMap.get(aTM.AccountId).add(aTM.User.Email);
        }

        for (Sample_Lab_Request__c s : eligibleList) {
            if(accToTeamMap.get(s.Account__c) != NULL) {
                List<String> atms = accToTeamMap.get(s.Account__c);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(atms);
                mail.setSenderDisplayName('Flexcon');
                mail.setSubject(s.Name + 'status changed to shipped');
                String body = 'The Lab Request ,\n';
                body += s.Name;
                body += 'status changed to shipped. \n Below are the details: \n Tracking Info :' +s.Tracking_Info__c;
                body += '\n Click here for more details \n'; 
                body += System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + s.Id;
                mail.setHtmlBody(body);
                mails.add(mail);
            }
        }
        if(!Test.isRunningTest())
            Messaging.sendEmail(mails);
    } 
    
    public static void populateAddressFields(List<Sample_Lab_Request__c> newList) {
        Set<Id> accIds = new Set<Id>();
        Map<Id,Sample_Lab_Request__c> accIdToSLRMap = new Map<Id,Sample_Lab_Request__c>();
        for(Sample_Lab_Request__c slr : newList) {
            if(slr.Account__c != null) {
                accIds.add(slr.Account__c);
                accIdToSLRMap.put(slr.Account__c,slr);
            }
                
        }
        
        for(Account acc : [SELECT BillingStreet,BillingCity,BillingState,BillingCountry, Id
                           FROM Account WHERE Id IN :accIds])
        {
            Sample_Lab_Request__c slr = accIdToSLRMap.get(acc.Id);
            if(slr != null) {
                if(acc.BillingStreet != null)
                    slr.Street__c = acc.BillingStreet;
                if(acc.BillingCity != null)
                    slr.City__c = acc.BillingCity;
                if(acc.BillingState != null)
                    slr.State__c = acc.BillingState;
                if(acc.BillingCountry != null)
                    slr.Country__c = acc.BillingCountry;
            }
        }
    }
}