public with sharing class MeetupRegistrations {
    List<MeetupRegistration__c> registrations;

    public MeetupRegistrations(List<MeetupRegistration__c> registrations) {
        this.registrations = registrations;
    }

    public void onAfterInsert() {        
        this.checkMeetupLimits();
    }

    public void onBeforeInsert() {        
        this.validateMeetupStatus();
        this.validateEmailAddress();

    }

    private void checkMeetupLimits() {
        Set<Id> meetupIds = new Set<Id>();
        for (MeetupRegistration__c mr : this.registrations) {
            meetupIds.add(mr.Meetup__c);
        }

        List<Meetup__c> meetupsToClose = new List<Meetup__c>();
        for (Meetup__c m : this.getMeetupsWithRegistrations(meetupIds)) {
            if (this.meetupShouldBeClosed(m)) {
                m.Status__c = Constants.MEETUP_STATUS_CLOSED;
                meetupsToClose.add(m);
            }
        }

        if (!meetupsToClose.isEmpty()) {
            update meetupsToClose;
        }
    }

    private void validateMeetupStatus() {
        Map<Id, List<MeetupRegistration__c>> registrationsByMeetupId = new Map<Id, List<MeetupRegistration__c>>();
        for (MeetupRegistration__c mr : this.registrations) {
            if (!registrationsByMeetupId.containsKey(mr.Meetup__c)) {
                registrationsByMeetupId.put(mr.Meetup__c, new List<MeetupRegistration__c>());
            }
            registrationsByMeetupId.get(mr.Meetup__c).add(mr);
        }

        List<Meetup__c> meetups = [SELECT Id, Status__c FROM Meetup__c WHERE Id IN:registrationsByMeetupId.keySet()];
        for (Meetup__c m : meetups) {
            if (m.Status__c == Constants.MEETUP_STATUS_CLOSED) {
                List<MeetupRegistration__c> registrations = registrationsByMeetupId.get(m.Id);
                for (MeetupRegistration__c mr : registrations) {
                    mr.addError(Constants.MEETUP_CLOSED_ERROR);
                }
            }
        }
    }

    private void validateEmailAddress() {
        Map<Id, List<MeetupRegistration__c>> registrationsByMeetupId = new Map<Id, List<MeetupRegistration__c>>();
        for (MeetupRegistration__c mr : this.registrations) {
            if (!registrationsByMeetupId.containsKey(mr.Meetup__c)) {
                registrationsByMeetupId.put(mr.Meetup__c, new List<MeetupRegistration__c>());
            }
            registrationsByMeetupId.get(mr.Meetup__c).add(mr);
        }

        Map<Id, List<String>> emails = new Map<Id, List<String>>();
        List<MeetupRegistration__c> invalidEmailRegistrations = new List<MeetupRegistration__c>();
        for (Meetup__c m : this.getMeetupsWithRegistrations(registrationsByMeetupId.keySet())) {
            for (MeetupRegistration__c mr : m.Meetup_Registrations__r) {
                if (!emails.containsKey(mr.Meetup__c)) {
                    emails.put(mr.Meetup__c, new List<String>());
                }
                emails.get(mr.Meetup__c).add(mr.Email__c);
            }
        }

        for (MeetupRegistration__c mr : this.registrations) {
            List<String> relatedEmails = emails.get(mr.Meetup__c);
            if (relatedEmails.contains(mr.Email__c)) {
                mr.addError(Constants.MEETUP_EMAIL_ERROR);
            }
        }
    }

    private List<Meetup__c> getMeetupsWithRegistrations(Set<Id> meetupIds) {
        return [SELECT Id, RegistrationLimit__c, Status__c, (SELECT Id, Email__c, Meetup__c FROM Meetup_Registrations__r) FROM Meetup__c WHERE Id IN :meetupIds];
    }

    private Boolean meetupShouldBeClosed(Meetup__c m) {
        return m.Meetup_Registrations__r.size() == m.RegistrationLimit__c && m.Status__c == Constants.MEETUP_STATUS_OPENED;
    }
}
