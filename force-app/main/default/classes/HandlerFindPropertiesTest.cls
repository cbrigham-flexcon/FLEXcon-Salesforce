@isTest
public class HandlerFindPropertiesTest {
@isTest
    static void testM(){
        Property__c p = new Property__c(Name='TestProperty', Price__c=450000, City__c='Boston');
        insert p;
        List<Property__c> pList = new List<Property__c>{p};
        BotHandler handler = new HandlerFindProperties();
        Map<String, String> session = handler.handle('', null, null, null, null).session;
        session = handler.handle('Boston', null, session, null, null).session;
        session = handler.handle('Single Family', null, session, null, null).session;
        session = handler.handle('400000', null, session, null, null).session;
        BotResponse response = handler.handle('500000', null, session, null, null);
        
        HandlerFindProperties hf = new HandlerFindProperties();
        
        hf.handle('2', new String[]{'Test'}, session, 'Test', 'some key');
    }
}