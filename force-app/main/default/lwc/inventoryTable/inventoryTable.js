import { LightningElement, wire, track } from 'lwc';
import getInventoryData from '@salesforce/apex/InventoryController.getInventoryData';
import updateInventory from '@salesforce/apex/InventoryController.updateInventory';
import getProductList from '@salesforce/apex/InventoryController.getProductList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';

export default class InventoryTable extends NavigationMixin(LightningElement) {
    @track data = [];
    @track draftValues = [];
    @track productOptions = [];
    @track productMap = {};

    @track columns = [
        { label: 'Item No', fieldName: 'itemNo', type: 'number' },
        { label: 'Product Name', fieldName: 'productName', type: 'text' },
        { label: 'Qty', fieldName: 'qty', type: 'number', editable: true },
        { label: 'List Price', fieldName: 'listPrice', type: 'number' },
        { label: 'Current Stock', fieldName: 'currentStock', type: 'number', editable: true },
        { label: 'Issue Date', fieldName: 'issueDate', type: 'date', editable: true }
    ];

    wiredInventory;

    // LOAD INVENTORY
    @wire(getInventoryData)
    wiredInventoryData(result) {
        this.wiredInventory = result;
        if (result.data) {
            this.data = result.data;
        } else if (result.error) {
            console.error('Error Loading Inventory:', result.error);
        }
    }

    // LOAD PRODUCT LIST
    @wire(getProductList)
    wiredProducts({ data, error }) {
        if (data) {
            this.productOptions = data.map(item => ({
                label: item.productName,
                value: item.productId
            }));
            data.forEach(item => {
                this.productMap[item.productId] = {
                    pbeId: item.pricebookEntryId,
                    price: item.unitPrice
                };
            });
        } else if (error) {
            console.error('Error Loading Products:', error);
        }
    }

    // INLINE EDIT SAVE
    handleSave(event) {
        const updatedFields = event.detail.draftValues;
        const updates = updatedFields.map(row => ({
            Id: row.recordId,
            Quantity__c: row.qty,
            Result_Stocks__c: row.currentStock,
            issue_Date__c: row.issueDate
        }));

        updateInventory({ updates })
            .then(() => {
                this.showToast('Success', 'Inventory updated', 'success');
                this.draftValues = [];
                return refreshApex(this.wiredInventory);
            })
            .catch(error => {
                this.showToast('Error', error.body ? error.body.message : error.message, 'error');
            });
    }

    // OPEN STANDARD NEW RECORD PAGE
    handleNew() {
        // If you want to select a product first, ensure productId is selected
        const productId = this.template.querySelector('lightning-combobox')?.value;
        if (!productId) {
            this.showToast('Error', 'Please select a product from the picklist first', 'error');
            return;
        }

        const pricebookEntryId = this.productMap[productId]?.pbeId;
        if (!pricebookEntryId) {
            this.showToast('Error', 'Pricebook Entry not found for the selected product', 'error');
            return;
        }

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Warehouse_Inventory__c',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: `Products__c=${productId},Price_Book_Entry__c=${pricebookEntryId}`
            }
        });
    }

    // TOAST UTILITY
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}