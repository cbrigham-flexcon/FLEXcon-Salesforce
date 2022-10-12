/**
 * Created by naveen on 05/09/18.
 */
({
    deleteAction : function(component, event, helper) {
        var action = component.get("c.remove");
        action.setParams({
            removeLIString : JSON.stringify(component.get('v.li'))
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                helper.fireEvent(component, event, helper);
            } else if (a.getState() === "ERROR") {
                console.log("oof");
            }
        });
        $A.enqueueAction(action);
    },
    updateAction : function(component, event, helper) {

        var action = component.get("c.updateLI");
        action.setParams({
            removeLIString :  JSON.stringify(component.get('v.li'))
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {

            } else if (a.getState() === "ERROR") {
                console.log("oof");
            }
        });
        $A.enqueueAction(action);
    }
})