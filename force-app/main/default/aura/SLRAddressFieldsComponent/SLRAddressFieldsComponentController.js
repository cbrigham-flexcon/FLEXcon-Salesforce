({
	doInit : function(component, event, helper) {
		var slrId = component.get("v.recordId");
        var action = component.get("c.getSLRRecord");
        action.setParams({
            slrId : slrId
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                component.set("v.street",result.getReturnValue().Street__c);
                component.set("v.city",result.getReturnValue().City__c);
                component.set("v.state",result.getReturnValue().State__c);
                component.set("v.country",result.getReturnValue().Country__c );
            }
        });
        $A.enqueueAction(action);
	},
    
    edit : function(component,event,helper){  
        // show the name edit field popup 
        component.set("v.showEditMode", true); 
        // after the 100 millisecond set focus to input field   
        setTimeout(function(){  
            component.find("streetInputId").focus();
        }, 100);
        setTimeout(function(){ 
            component.find("cityInputId").focus();
        }, 100);
    },
    
    save : function(component,event,helper){ 
        var slrId = component.get("v.recordId");
        var street = component.get("v.street");
        var city = component.get("v.city");
        var state = component.get("v.state");
        var country = component.get("v.country");
        var action = component.get("c.updateSLR");
        action.setParams({
            slrId   : slrId,
            street  : street,
            city    : city,
            state   : state,
            country : country
            
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                //alert('success ');
                component.set("v.street",result.getReturnValue().Street__c);
        		component.set("v.city",result.getReturnValue().City__c);
        		component.set("v.state", result.getReturnValue().State__c); 
                component.set("v.country", result.getReturnValue().Country__c); 
                component.set("v.showEditMode", false); 
                $A.get('e.force:refreshView').fire();
            }
            else
            {
                alert('error while updating');
            }
        });
        $A.enqueueAction(action);
    },
    
    cancel : function(component,event,helper){ 
        component.set("v.showEditMode", false); 
    }
    
})