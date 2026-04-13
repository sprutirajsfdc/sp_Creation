import { LightningElement, track,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getListingLocations from '@salesforce/apex/ListingMapController.getListingLocations';

// const FIELDS = ['Listing__c.Street__c', 'Listing__c.City__c', 'Listing__c.State__c'];

export default class ListingMap extends LightningElement {
   
 @track mapMarkers = [];
    @track error;
    @track isLoading = true;

    // Optional filters
    cityFilter = '';       
    limitSize = 500; 

    connectedCallback() {
        this.loadMarkers();
    }

    async loadMarkers() {
        this.isLoading = true;
        this.error = undefined;

        try {
            const data = await getListingLocations({ cityFilter: this.cityFilter, limitSize: this.limitSize });

            this.mapMarkers = (data || []).map(item => ({
                location: {
                    Street: item.street || '',
                    City: item.city || '',
                    State: item.state || ''
                },
                title: item.name || 'Listing',
                value: item.id,
                description: `${item.street || ''}, ${item.city || ''}, ${item.state || ''}`
            }));
        } catch (err) {
            // Surface a friendly message and keep details in console
            this.error = 'We could not load listing locations.';
            // eslint-disable-next-line no-console
            console.error(err);
        } finally {
            this.isLoading = false;
        }
    }
}