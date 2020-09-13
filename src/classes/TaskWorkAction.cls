/**
 * Created by Elisey on 9/13/2020.
 */

global without sharing class TaskWorkAction {
    public static final String TASK_SUBJECT_TEXT =  'Negotiations with ';
    public static final Integer MAX_TASK_NUMBER_ON_ACCOUNT = 3;

    @InvocableMethod(Label = 'Create task when Account is created')
    global static void createTaskWhenAccountIsCreatedBatch(List<CreatedAccount> accounts) {
        for (CreatedAccount account : accounts) {
            createTaskWhenAccountIsCreated(account);
        }
    }

    public static void createTaskWhenAccountIsCreated(CreatedAccount account) {
        Account accountFromDB = [SELECT Id, Name FROM Account WHERE Account.Id = :account.Id];
        Task task = createTask(accountFromDB);
        insert task;
        if (checkTaskNumberOnAccount(accountFromDB)) {
            assignAllTasksToRandomUser(accountFromDB);
        }
    }

    private static void assignAllTasksToRandomUser(Account account) {
        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId =: account.Id];
        User randomUser = [SELECT Id FROM User WHERE IsActive = TRUE LIMIT 1];
        for (Task task : tasks) {
            task.OwnerId = randomUser.Id;
        }
        update tasks;
    }

    private static Task createTask(Account account) {
        return new Task(Subject = TASK_SUBJECT_TEXT + account.Name, WhatId = account.Id);
    }

    private static Boolean checkTaskNumberOnAccount(Account account) {
        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId =: account.Id];
        return tasks.size() > MAX_TASK_NUMBER_ON_ACCOUNT;
    }

    global class CreatedAccount {
        @InvocableVariable(label='Created Account ID' required=true)
        global Id Id;
    }
}