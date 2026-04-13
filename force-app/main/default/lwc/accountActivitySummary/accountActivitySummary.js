import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAccountSummary from '@salesforce/apex/AccountActivityService.getAccountSummary';

export default class AccountActivitySummary extends NavigationMixin(LightningElement) {
    @track accountData = {
        total: 0,
        upcoming: 0,
        past: 0,
        noActivity: 0
    };
    
    // Wire the Apex method to get the data
    @wire(getAccountSummary)
    wiredAccountSummary({ error, data }) {
        if (data) {
            this.accountData.total = data.totalAccounts;
            this.accountData.upcoming = data.upcomingActivity;
            this.accountData.past = data.pastActivity;
            this.accountData.noActivity = data.noActivity;
            
        } else if (error) {
            console.error('Error fetching account summary: ', error);
        }
    }

    // Handles the button click to navigate to the Account list view
    handleViewAccounts() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'list' // Opens the default Account list view
            },
            state: {
            }
        });
    }

    get strokeDasharray() {
        return 283;
    }

    get strokeDashoffset() {
        return 0; // 0 offset means the circle is complete (full red ring)
    }
}