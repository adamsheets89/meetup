import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { api, LightningElement, track } from 'lwc';

const HEADER = 'Meetup Registration';
const FIELDS = [
  {name: 'FirstName__c', value: null},
  {name: 'LastName__c', value: null},
  {name: 'Email__c', value: null}
];

export default class RegistrationPage extends NavigationMixin(LightningElement) {
  @api code;
  @track meetupId;
  @track isRegistering = false;

  @api
  set recordId(recordId) {
    this.meetupId = recordId;
    FIELDS.unshift({name: 'Meetup__c', value: recordId});
  }

  get recordId() {
    return this.meetupId;
  }

  get header() {
    return HEADER;
  }

  get fields() {
    return FIELDS;
  }

  handleSubmit() {
    this.isRegistering = true;
  }

  handleSuccess() {
    this.isRegistering = false;
    this.showToast('Successfully registered', 'success');
    this.returnToMeetup();
  }

  handleError(event) {
    this.isRegistering = false;
    this.showToast(event.detail, 'error')
  }

  returnToMeetup() {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: this.recordId,
        actionName: 'view',
      },
    });
  }

  showToast(message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        message,
        variant
      })
    );
  }
}