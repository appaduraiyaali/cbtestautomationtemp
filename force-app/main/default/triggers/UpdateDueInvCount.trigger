trigger UpdateDueInvCount on CB_Invoice__c (after update,after insert) {
    System.debug('UpdateDueInvCountUpdateDueInvCount');
    if(Trigger.isAfter){
        System.debug('isAfterisAfterisAfter');
        TriggerHelper th = new TriggerHelper();
        th.action(Trigger.new);
    }

}