public with sharing class RegistrationPageController {
    @AuraEnabled
    public static Meetup__c getMeetup(String registrationCode) {
        try {
            List<Meetup__c> meetups = [
                SELECT Id, RegistrationLimit__c, Status__c, RegistrationCode__c
                FROM Meetup__c
                WHERE RegistrationCode__c = :registrationCode AND Status__c = :Constants.MEETUP_STATUS_OPENED
            ];

            return !meetups.isEmpty() ? meetups[0] : null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
