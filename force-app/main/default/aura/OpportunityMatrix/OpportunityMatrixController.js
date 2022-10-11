({
	doInit : function(component, event, helper) {
        console.log(component.get("v.recordId"));
		console.log('init called');
        helper.getInitialMatrix(component, event, helper);
	},
    
    changeLevel : function(component, event, helper) {
        //helper.getInitialMatrix(component, event, helper);
        //This has been commented because:
        //1. now we are showing all questions
        //2. we just need to highlight questions related to current level
        helper.changeLevel(component, event, helper);
    },
    
    saveOpportunity : function(component, event, helper) {
        component.set('v.loaded', false);
		var action = component.get("c.saveMatrixToOpportunity");
        action.setParams({ 
            oppMatrix : component.get('v.matrix')
        });
        
        action.setCallback(this, function(response) {
            component.set('v.loaded', true);
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.matrix", response.getReturnValue());
                //helper.calculateProgress(component, event, helper);
                //instead of this redirect to opportunity record
                //show success message
                helper.showToastJS('Matrix Updated Successfully!', 'success');
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get('v.recordId'),
                    "slideDevName": "detail"
                });
                navEvt.fire();
            }
            else if (state === "INCOMPLETE") {
                //error handling
                helper.showToastJS('Process still in progress!', 'warning');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToastJS(errors[0].message, 'error');
                    }
                } else {
                    console.log("Unknown error");
                    helper.showToastJS('Unknown error', 'error');
                }
            }
            $A.get('e.force:refreshView').fire();
        });

        $A.enqueueAction(action);
    },
    
    calculateProgress : function(component, event, helper) {
        console.log('calculateProgress!');        
        helper.findAndMarkAsAnswered(component, event, helper);
        helper.calculateProgress(component, event, helper);
    }
})