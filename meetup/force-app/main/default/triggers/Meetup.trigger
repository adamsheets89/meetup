trigger Meetup on Meetup__c (before insert) {
    if (Trigger.isBefore && Trigger.isInsert){
        new Meetups(Trigger.new).onBeforeInsert();
    }
}