/**
 * Created by naveen on 05/09/18.
 */
({
    init : function(component, event, helper) {
        helper.getLineItems(component, event, helper);
        component.set('v.productColumns', [
                       {label: 'Product Name', fieldName: 'Name', type: 'text'},
                       {label: 'Size', fieldName: 'Size__c', type: 'text'},
                       {label: 'Location', fieldName: 'Location__c', type: 'text'}]);
    },
    Search : function(component, event, helper) {
        console.log('controller Search');

        var category = component.get("v.Category");
        var searchString = component.get("v.searchString");
        console.log(category);
        console.log(searchString);
        var action = component.get("c.getProducts");
        action.setParams({
            category : category,
            searchString : searchString
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var data = a.getReturnValue();
                console.log(data);
                component.set("v.products", JSON.parse(data));
            } else if (a.getState() === "ERROR") {
                console.log("oof");
            }
        });
        if(searchString) {
            if(category && searchString.length > 2) {
                $A.enqueueAction(action);
            }
        }
    },
    addAction : function(component, event, helper) {
        var selectedProducts = component.get('v.selectedProducts');
        var action = component.get("c.add");
        action.setParams({
            parentId : component.get("v.recordId"),
            lineItemsString : JSON.stringify(selectedProducts)
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                helper.getLineItems(component, event, helper);
            } else if (a.getState() === "ERROR") {
                console.log("oof");
            }
        });
        $A.enqueueAction(action);
    },
    UpdateSelectedRows : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        var setRows = [];
        for (var i = 0; i < selectedRows.length; i++){
            setRows.push(selectedRows[i].Id);
        }
        component.set("v.selectedProducts", setRows);
    },
    handleSave : function(component, event, helper) {
        var lineitems = component.get('v.lineItems');
        var action = component.get("c.save");
        action.setParams({
            lineItemsString : JSON.stringify(lineitems)
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var data = a.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "The record has been saved successfully."
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            } else if (a.getState() === "ERROR") {
                console.log("oof");
            }
        });
        $A.enqueueAction(action);
    },
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})