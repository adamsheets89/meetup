import getMeetup from '@salesforce/apex/RegistrationPageController.getMeetup'
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, track, wire } from 'lwc';

const HEADER = 'Meetup Registration';
const SEARCH_LABEL = 'Provide the registration code for the meetup you wish to attend';
const FIELDS = ['FirstName__c', 'LastName__c', 'Email__c'];

const INVALID_CODE_ERROR_MESSAGE = 'The provided registration code is invalid.';

export default class RegistrationPage extends NavigationMixin(LightningElement) {
  @track registrationCode;
  @track meetup;
  @track registrationFields;
  @track isRegistering = false;

  currentPageReference;

  get header() {
    return HEADER;
  }

  get searchLabel() {
    return SEARCH_LABEL;
  }

  get disableSearch() {
    return !this.registrationCode;
  }

  get showForm() {
    return this.meetup && this.registrationFields;
  }

  connectedCallback() {
    window.addEventListener("popstate", () => {
      this.resetState();
    });
  }

  @wire(CurrentPageReference)
  setCurrentPageReference(currentPageReference) {
    this.currentPageReference = currentPageReference;
    if (this.currentPageReference.state.c__code) {
      this.initializeData();
    };
  }

  goToForm() {
    this.isRegistering = true;
    const updatedPageReference = this.getUpdatedPageReference({ c__code: this.registrationCode });
    this[NavigationMixin.Navigate](updatedPageReference, true);      
  }

  async initializeData() {
    try {
      this.meetup = await getMeetup({ registrationCode: this.currentPageReference.state.c__code });
      if (!this.meetup){
        return this.showToast(INVALID_CODE_ERROR_MESSAGE, 'error');
      }
      this.registrationFields = FIELDS.map(f => ({name: f, value: undefined}));
      this.registrationFields.unshift({name: 'Meetup__c', value: this.meetup.Id});
    } catch (error) {
      this.showToast(error, 'error');
    } finally {
      this.isRegistering = false;
    }
  }

  getUpdatedPageReference(stateChanges) {
    return Object.assign({}, this.currentPageReference, {
        state: Object.assign({}, this.currentPageReference.state, stateChanges)
    });
  }

  handleChange(event){
    const input = event.target.value;
    if (input.length === 8) {
      this.registrationCode = input;
    }
  } 

  handleSubmit() {
    this.isRegistering = true;
  }

  handleSuccess() {
    this.isRegistering = false;
    this.showToast('Successfully registered', 'success');
    this.returnToMeetup();
    this.resetState();
  }

  handleError(event) {
    this.isRegistering = false;
    this.showToast(event.detail, 'error')
  }

  returnToMeetup() {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: this.meetup.Id,
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

  resetState() {
    this.registrationCode = undefined;
    this.meetup = undefined;
    this.registrationFields = undefined;
  }
}