import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import INVOICE_OBJECT from '@salesforce/schema/Invoice__c';
import STATUS_FIELD from '@salesforce/schema/Invoice__c.Status__c';
import ID_FIELD from '@salesforce/schema/Invoice__c.Id';
import PAYMENT_DATE_FIELD from '@salesforce/schema/Invoice__c.Payment_Date__c';

export default class CustomInvoicePath extends LightningElement {
    @api recordId;

    @track stages = [];
    @track currentStatus;
    @track isModalOpen = false;
    @track paymentDate;

    pendingStatus;
    recordTypeId;

    // 🔹 Get Object Info
    @wire(getObjectInfo, { objectApiName: INVOICE_OBJECT })
    objectInfo({ data }) {
        if (data) {
            this.recordTypeId = data.defaultRecordTypeId;
        }
    }

    // 🔹 Get Picklist Values
    @wire(getPicklistValues, {
        recordTypeId: '$recordTypeId',
        fieldApiName: STATUS_FIELD
    })
    picklistHandler({ data }) {
        if (data) {
            this.stages = data.values.map(item => ({
                label: item.label,
                value: item.value,
                class: 'slds-path__item'
            }));
            this.updateStageClasses();
        }
    }

    // 🔹 Get Current Record Status
    @wire(getRecord, {
        recordId: '$recordId',
        fields: [STATUS_FIELD]
    })
    wiredRecord({ data }) {
        if (data) {
            this.currentStatus = data.fields.Status__c.value;
            this.updateStageClasses();
        }
    }

    // 🔹 Handle Stage Click
    handleStageClick(event) {
        const selectedValue = event.currentTarget.dataset.value;

        // 👉 If Paid → open modal
        if (selectedValue === 'Paid') {
            this.pendingStatus = selectedValue;

            // default today's date
            this.paymentDate = new Date().toISOString().split('T')[0];
            this.isModalOpen = true;
            return;
        }

        // 👉 Otherwise update directly
        this.updateStatus(selectedValue);
    }

    // 🔹 Update Record
    updateStatus(statusValue, paymentDateValue = null) {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[STATUS_FIELD.fieldApiName] = statusValue;

        if (paymentDateValue) {
            // 👉 Convert to ISO format for DateTime field
            const isoDate = new Date(paymentDateValue).toISOString();
            fields[PAYMENT_DATE_FIELD.fieldApiName] = isoDate;
        }

        updateRecord({ fields })
            .then(() => {
                this.currentStatus = statusValue;
                this.updateStageClasses();

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Invoice updated successfully',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    // 🔹 Modal handlers
    handleDateChange(event) {
        this.paymentDate = event.target.value;
    }

    handleSavePayment() {
        if (!this.paymentDate) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select a payment date',
                    variant: 'error'
                })
            );
            return;
        }

        this.updateStatus(this.pendingStatus, this.paymentDate);
        this.closeModal();
    }

    closeModal() {
        this.isModalOpen = false;
        this.paymentDate = null;
        this.pendingStatus = null;
    }

    // 🔹 Update Stage Classes and Attach Emoji
    updateStageClasses() {
        if (!this.stages.length || !this.currentStatus) return;

        this.stages = this.stages.map(stage => {
            let css = 'slds-path__item ' + this.getStageColor(stage.value);

            if (stage.value === this.currentStatus) {
                css += ' slds-is-current slds-is-active';
            } else if (this.isCompleted(stage.value)) {
                css += ' slds-is-complete';
            }

            return { ...stage, class: css, emoji: this.getStageEmoji(stage.value) };
        });
    }

    // 🔹 Map Stage Value → Color
    getStageColor(value) {
        switch (value) {
            case 'Draft':
                return 'stage-draft';           
            case 'Sent':
                return 'stage-sent';            
            case 'Partially Paid':
                return 'stage-partiallypaid';
            case 'Paid':
                return 'stage-paid';            
            case 'Cancelled':
                return 'stage-cancelled';       
            default:
                return '';
        }
    }

    // 🔹 Map Stage Value → Emoji
    getStageEmoji(value) {
        switch (value) {
            case 'Draft':
                return '📝';
            case 'Sent':
                return '📤';
            case 'Partially Paid':
                return '💰';
            case 'Paid':
                return '🎉';
            case 'Cancelled':
                return '❌';
            default:
                return '';
        }
    }

    // 🔹 Completed logic
    isCompleted(stageValue) {
        const order = this.stages.map(s => s.value);
        return order.indexOf(stageValue) < order.indexOf(this.currentStatus);
    }
}