@isTest
public class HandlerImageBasedSearchTest {
    @isTest
    static void testM(){
        insert new Dreamhouse_Settings__c(Einstein_Vision_Email__c = 'user@host.com');
        Boolean success = true;
       
            ContentVersion cv = new ContentVersion(Title='einstein_platform', PathOnClient='/', VersionData=Blob.valueof('some key'));
            insert cv;
	        EinsteinVisionController.predict('victorian.jpg', '', 'theModelId');
	        EinsteinVisionController.predict('victorian_01.jpg', '', '');
        insert new Property__c(Name = 'victorian',tags__c = 'victorian_10.jpg',price__c = 12);

        HandlerImageBasedSearch hf = new HandlerImageBasedSearch();
        hf.modelId=null;
        hf.handle('1', new String[]{'Test'}, null, 'victorian_10.jpg', 'image');
        
    }
}