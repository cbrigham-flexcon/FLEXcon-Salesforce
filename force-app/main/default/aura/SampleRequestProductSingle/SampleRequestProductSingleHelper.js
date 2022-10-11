/**
 * Created by naveen on 05/09/18.
 */
({
    fireEvent : function(component, event, helper) {
        var appEvent = $A.get("e.c:DeleteLRP");
        appEvent.setParams({"li" : component.get("v.li")});
        appEvent.fire();
    }
})