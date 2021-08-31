public with sharing class Meetups {
    List<Meetup__c> meetups;

    public Meetups(List<Meetup__c> meetups) {
        this.meetups = meetups;
    }

    public void onBeforeInsert() {        
        this.setRegistrationCodes();
    }

    private void setRegistrationCodes() {
        for (Meetup__c m : this.meetups) {
            m.RegistrationCode__c = Utility.generateRandomString(8);
        }
    }
}
