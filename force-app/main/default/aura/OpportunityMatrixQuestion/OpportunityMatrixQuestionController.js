({
	calculateProgress : function(component, event, helper) {
        console.log('this is from another component');
        var cmpEvent = component.getEvent("calculateProgress");
        cmpEvent.setParams({
            "currentQuestion" : component.get('v.question'),
            "typeOfQuestion" : component.get('v.typeOfQuestion')
        });
        cmpEvent.fire();
	}
})