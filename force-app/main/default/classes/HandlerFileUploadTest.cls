@isTest
public class HandlerFileUploadTest {
    @isTest
    static void testM(){
       
        HandlerFileUpload hf = new HandlerFileUpload();
        
        hf.handle('utterance', new String[]{'Test'}, null, 'Test', 'some key');
    }
}