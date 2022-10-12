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
public class SampleRequestMainWrapper {
    @AuraEnabled
    public List<Sample_Lab_Request_Products__c>  SampleList;
    @AuraEnabled
    public List<Sample_Lab_Request_Products__c>  MarketingList;
    @AuraEnabled
    public List<Sample_Lab_Request_Products__c>  OtherList;

    public SampleRequestMainWrapper() {
        SampleList = new List<Sample_Lab_Request_Products__c> ();
        MarketingList = new List<Sample_Lab_Request_Products__c> ();
        OtherList = new List<Sample_Lab_Request_Products__c> ();
    }

}