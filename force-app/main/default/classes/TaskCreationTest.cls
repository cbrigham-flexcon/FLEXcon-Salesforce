@IsTest
public with sharing class TaskCreationTest {
    @IsTest
    private static void createTask(){       
        Test.startTest();
        Task t = new Task();
        TaskCreation.createEmailForTaskWithQueue(new List<Task>{t});
        Test.stopTest();
        System.assertEquals(1, [SELECT Count() FROM Task]);
    }
}