import { LightningElement, track, wire } from 'lwc';
import getServiceCounters from '@salesforce/apex/TokenController.getServiceCounters';
import generateToken from '@salesforce/apex/TokenController.generateToken';
import getUsers from '@salesforce/apex/TokenController.getUsers';
import assignTokenToUser from '@salesforce/apex/TokenController.assignTokenToUser';

export default class TokenGenerator extends LightningElement {

    @track token;
    @track counterOptions = [];
    @track userOptions = [];

    counterId;
    assignedUserId;
    assignedUserName = '';
    currentTime;

    // Fetch counters
    @wire(getServiceCounters)
    wiredCounters({ data, error }) {
        if (data) {
            this.counterOptions = data.map(acc => ({
                label: `${acc.Counter_Number__c || ''} - ${acc.Name || ''}`,
                value: acc.Id
            }));
        } else if (error) {
            console.error(error);
        }
    }

    // Fetch users
    @wire(getUsers)
    wiredUsers({ data, error }) {
        if (data) {
            this.userOptions = data.map(u => ({
                label: u.Name || '',
                value: u.Id
            }));
        } else if (error) {
            console.error(error);
        }
    }

    handleCounterChange(event) {
        this.counterId = event.detail.value;
    }

    handleUserChange(event) {
        this.assignedUserId = event.detail.value;
        const selectedUser = this.userOptions.find(u => u.value === this.assignedUserId);
        this.assignedUserName = selectedUser ? selectedUser.label : '';
    }

    handleGenerate() {
        if (!this.counterId) {
            alert('Please select a counter');
            return;
        }

        generateToken({ counterId: this.counterId })
            .then(result => {
                // Safely check related counter fields
                this.token = {
                    ...result,
                    Counter__r: result.Counter__r || {}
                };
                this.currentTime = new Date().toLocaleString();
                this.assignedUserId = '';
                this.assignedUserName = '';
            })
            .catch(error => {
                console.error(error);
            });
    }

    handleAssignUser() {
        if (!this.assignedUserId || !this.token) {
            alert('Please select a user and generate a token first');
            return;
        }

        assignTokenToUser({ tokenId: this.token.Id, userId: this.assignedUserId })
            .then(result => {
                this.token = {
                    ...result,
                    Counter__r: result.Counter__r || {},
                    Owner: { Name: this.userOptions.find(u => u.value === this.assignedUserId)?.label || '' }
                };
                this.assignedUserName = this.token.Owner.Name || '';

                // Open VF PDF after assignment
                window.open('/apex/token?id=' + this.token.Id, '_blank');
            })
            .catch(error => console.error(error));
    }
}