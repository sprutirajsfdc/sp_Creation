/**
 * @description       : Account edit form LWC for record pages
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @last modified on  : 11-16-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 */
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';

export default class AccountEditForm extends NavigationMixin(LightningElement) {
    @api recordId;
    @track isSaving = false;
    @track isLoaded = false;

    handleLoad() {
        this.isLoaded = true;
    }

    handleCancel() {
        // Try to close quick action if used there, otherwise just reset fields
        try {
            this.dispatchEvent(new CloseActionScreenEvent());
        } catch (e) {
            // No-op if not in quick action context
        }
        const form = this.template.querySelector('lightning-record-edit-form');
        if (form) {
            // Lightning base components handle cancel automatically on nav; nothing to reset explicitly
        }
    }

    handleError(event) {
        this.isSaving = false;
        const detail = event?.detail;
        const message =
            (detail && (detail.message || detail.detail || detail.output?.errors?.[0]?.message)) ||
            'An error occurred while saving the Account.';
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message,
                variant: 'error',
                mode: 'sticky'
            })
        );
    }

    handleSubmit(evt) {
        this.isSaving = true;
        // Optional: place to add client-side validation before submit
    }

    handleSuccess(event) {
        this.isSaving = false;
        const recId = event?.detail?.id || this.recordId;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Account updated successfully.',
                variant: 'success'
            })
        );
        // Stay on the record page (as requested). If used in a different context, we could navigate.
        // Example navigation kept for reference (not executed):
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: recId,
        //         objectApiName: 'Account',
        //         actionName: 'view'
        //     }
        // });
    }
}