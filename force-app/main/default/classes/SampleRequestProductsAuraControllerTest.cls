/////***** Test class for SampleRequestProductsAuraController ****////

@isTest
public class SampleRequestProductsAuraControllerTest 
{
    static testMethod void getTest() {
        test.startTest();
        
        Sample_Products__c sProd = new Sample_Products__c();
        sProd.Name = 'Test Sample Product';
        sProd.Category__c = 'Sample';
        sProd.Location__c = 'CANADA';
        sProd.Market__c = 'UL';
        sProd.Notes__c = 'This is test product. created for testing code coverage.';
        sProd.Type__c = 'VBS';
        insert sProd;
        
        Sample_Lab_Request__c slReq = new Sample_Lab_Request__c();
        slReq.Status__c = 'New';
        slReq.Ship_Via__c = 'UPS';
        slReq.Customer_UPS_FedEx__c = 'cust fedEx';
        slReq.Custom_Letter__c = 'Yes';
        slReq.Reason__c = 'Test record';
        slReq.Street__c = 'street';
        slReq.City__c = 'city';
        slReq.State__c = 'state';
        slReq.Country__c = 'country';
        insert slReq;
        
        Sample_Lab_Request_Products__c sLReqPrd = new Sample_Lab_Request_Products__c();
        sLReqPrd.Sample_Lab_Request__c = slReq.Id;
        sLReqPrd.Sample_Product__c = sProd.Id;
        sLReqPrd.Quantity__c = 9;
        sLReqPrd.Size__c = 'size';
        sLReqPrd.Location__c = 'CANADA';
        sLReqPrd.Special_Instructions__c = 'test record';
        insert sLReqPrd;
        
        System.assert(SampleRequestProductsAuraController.getLineItems(slReq.Id) != null);
        System.assert(SampleRequestProductsAuraController.getProducts(sProd.Category__c, sProd.Name) != null);
        List<String> jsonStr = new List<String>();
        jsonStr.add(sProd.Id);
        String lineItemsString = JSON.serialize(jsonStr);
        SampleRequestProductsAuraController.add(slReq.Id, lineItemsString);
        
        sLReqPrd.Quantity__c = 99;
        String slReqProdStr = JSON.serialize(sLReqPrd);
        SampleRequestProductsAuraController.updateLI(slReqProdStr);
        SampleRequestProductsAuraController.remove(slReqProdStr);
        
        test.stopTest();
    }
}