/**
 * Created by naveen on 05/09/18.
 */
({
    getLineItems : function(component, event, helper) {
        var action = component.get("c.getLineItems");
        action.setParams({
            parentId : component.get("v.recordId")
        });

        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var data = a.getReturnValue();
                console.log(data);
                component.set("v.lineItems", JSON.parse(data));
            } else if (a.getState() === "ERROR") {
                console.log("oof");
            }
        });
        $A.enqueueAction(action);
    }
})