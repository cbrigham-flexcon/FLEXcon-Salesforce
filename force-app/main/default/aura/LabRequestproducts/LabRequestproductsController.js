/**
 * Created by naveen on 31/08/18.
 */
({
    init : function(component, event, helper) {
        var action = component.get("c.getLineItems");
        action.setParams({
            parentId : component.get("v.recordId")
        });

        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var data = a.getReturnValue();
                component.set("v.data", data);
            } else if (a.getState() === "ERROR") {
                console.log("oof");
            }
        });
        $A.enqueueAction(action);
    },
    saveAction : function(component, event, helper) {
        component.set('v.showSpinner',true);
        var action = component.get("c.save");
        action.setParams({
            lineItemsString : JSON.stringify(component.get("v.data"))
        });

        action.setCallback(this, function(a) {
            component.set('v.showSpinner',false);
            if (a.getState() === "SUCCESS") {
                console.log('saved');
                $A.get("e.force:closeQuickAction").fire();
            } else if (a.getState() === "ERROR") {
                console.log("oof");
            }
        });
        $A.enqueueAction(action);
    },
    addAction : function(component, event, helper) {
        var action = component.get("c.add");
        action.setParams({
            lineItemsString : JSON.stringify(component.get("v.data")),
            parentId : component.get("v.recordId")
        });

        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var data = a.getReturnValue();
                component.set("v.data", data);
            } else if (a.getState() === "ERROR") {
                console.log("oof");
            }
        });
        $A.enqueueAction(action);
    },
    delAction : function(component, event, helper) {
        var li = event.getParam("li");
        var action = component.get("c.remove");
        action.setParams({
            lineItemsString : JSON.stringify(component.get("v.data")),
            removeLIString : JSON.stringify(li)
        });

        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var data = a.getReturnValue();
                component.set("v.data", data);
            } else if (a.getState() === "ERROR") {
                console.log("oof");
            }
        });
        $A.enqueueAction(action);
    }
})