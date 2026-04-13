import { LightningElement, api, track, wire } from 'lwc';
import getInvoiceSummary from '@salesforce/apex/InvoiceLineItemController.getInvoiceSummary';
import { refreshApex } from '@salesforce/apex';

export default class InvoiceGrandTotal extends LightningElement {
    @api recordId;
    @track grandTotal = 0;
    @track isPaid = false;
    @track error;

    paidIconUrl = 'https://spcreation2-dev-ed--c.develop.vf.force.com/resource/1775558296000/pass';

    wiredSummaryResult;
    refreshInterval;

    get showGrandTotal() {
        return !this.isPaid && this.grandTotal > 0;
    }

    @wire(getInvoiceSummary, { invoiceId: '$recordId' })
    wiredSummary(result) {
        this.wiredSummaryResult = result;
        const { data, error } = result;
        if (data) {
            // If status changes to Paid, update immediately
            if (!this.isPaid && data.status === 'Paid') {
                this.isPaid = true;
            }
            this.grandTotal = data.grandTotal;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.grandTotal = 0;
            this.isPaid = false;
        }
    }

    connectedCallback() {
        // Poll every 5 seconds for immediate status update
        this.refreshInterval = setInterval(() => {
            if (this.wiredSummaryResult) {
                refreshApex(this.wiredSummaryResult);
            }
        }, 5000); // 5000 ms = 5 seconds
    }

    disconnectedCallback() {
        clearInterval(this.refreshInterval);
    }
}