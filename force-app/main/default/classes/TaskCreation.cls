public with sharing class TaskCreation {
	@InvocableMethod
    public static void createEmailForTaskWithQueue(List<Task> taskList) {
        try{
            Task t = taskList.isEmpty() ? null : taskList[0];
            Database.DMLOptions dmlOpts = new Database.DMLOPtions();
            dmlOpts.EmailHeader.TriggerUserEmail = true;
            t.setOptions(dmlOpts);
            upsert t;
        } catch (Exception e) {
            throw e;
        }
    }
}