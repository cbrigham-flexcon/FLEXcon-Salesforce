/**
 * Created by naveen on 31/08/18.
 */
({
    init : function(component, event, helper) {
        var qty = component.get("v.li.Quantity__c");
        var size = component.get("v.li.Size__c");
        if(qty == '3') {
            component.find("qtydd").set("v.value","3");
        }
        else if(qty == '6') {
            component.find("qtydd").set("v.value","6");
        }
        else if($A.util.isEmpty(qty)) {
            component.find("qtydd").set("v.value",'');
        }
        else {
            component.set("v.showQuantity",true);
            component.find("qtydd").set("v.value",'Other');
        }

        if(size == '8" x 10"') {
            component.find("sizedd").set("v.value",'8" x 10"');
        }
        else if(size == '8.5" x 11"') {
            component.find("sizedd").set("v.value",'8.5" x 11"');
        }
        else if($A.util.isEmpty(size)) {
            component.find("sizedd").set("v.value",'');
        }
        else {
            component.set("v.showSize",true);
            component.find("sizedd").set("v.value",'Other');
        }
    },
    QuantityChange : function(component, event, helper) {
    	var dd = component.find("qtydd").get("v.value");
    	if(dd == 'Other' ) {
    	    component.set("v.showQuantity",true);
    	    component.set("v.li.Quantity__c",'');
        } else {
            component.set("v.showQuantity",false);
            component.set("v.li.Quantity__c",dd);
        }
    },
    SizeChange : function(component, event, helper) {
    	var dd = component.find("sizedd").get("v.value");
    	if(dd == 'Other' ) {
    	    component.set("v.showSize",true);
    	    component.set("v.li.Size__c",'');
    	} else {
    	    component.set("v.showSize",false);
    	    component.set("v.li.Size__c",dd);
        }
    },
    deleteAction : function(component, event, helper) {
        var appEvent = $A.get("e.c:DeleteLRP");
        appEvent.setParams({"li" : component.get("v.li")});
        appEvent.fire();
    }

})