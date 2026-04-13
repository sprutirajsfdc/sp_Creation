import { LightningElement, api, wire } from 'lwc';
import JsBarcodeLib from '@salesforce/resourceUrl/JsBarcode';
import { loadScript } from 'lightning/platformResourceLoader';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Asset.Code__c' // formula field
];

export default class BarcodeGenerator extends LightningElement {
    @api recordId;
    assetCode;
    libLoaded = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    assetHandler({ data, error }) {
        if (data) {
            this.assetCode = data.fields.Code__c.value?.trim();
            if (this.libLoaded && this.assetCode) {
                this.generateBarcode();
            }
        } else if (error) {
            console.error('Error loading asset:', error);
        }
    }

    renderedCallback() {
        if (this.libLoaded) return;

        loadScript(this, JsBarcodeLib)
            .then(() => {
                if (!window.JsBarcode) {
                    console.error("JsBarcode NOT loaded");
                } else {
                    this.libLoaded = true;
                    if (this.assetCode) {
                        this.generateBarcode();
                    }
                }
            })
            .catch(error => console.error("Error loading JsBarcode:", error));
    }

    generateBarcode() {
        const canvas = this.template.querySelector("canvas.barcode");
        if (!canvas || !this.assetCode) return;

        window.JsBarcode(canvas, this.assetCode, {
            format: "CODE128",
            width: 2,         // scanner-friendly width
            height: 100,      // scanner-friendly height
            displayValue: false,
            margin: 10,
            background: "#ffffff"
        });
    }
}