import { LightningElement, track } from 'lwc';
import createGatePass from '@salesforce/apex/GatePassController.createGatePass';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class GatePass extends LightningElement {
    
    @track gatePassObj = {};

    gateTypeOptions = [
        { label: 'IN', value: 'IN' },
        { label: 'OUT', value: 'OUT' }
    ];

    handleChange(event) {
        let field = event.target.dataset.field;
        this.gatePassObj[field] = event.target.value;
    }

    handleSubmit() {
        createGatePass({ gp: this.gatePassObj })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Gate Pass Created Successfully! ID: ' + result,
                        variant: 'success'
                    })
                );
                this.gatePassObj = {}; // Reset form
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
}