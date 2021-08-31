trigger MeetupRegistration on MeetupRegistration__c (after insert, before insert) {
    if (Trigger.isInsert){
        if (Trigger.isAfter) {
            new MeetupRegistrations(Trigger.new).onAfterInsert();
        } else if (Trigger.isBefore) {
            new MeetupRegistrations(Trigger.new).onBeforeInsert();
        }
    }
}