import { LightningElement, track } from 'lwc';
import createGatePass from '@salesforce/apex/VisitorPassController.createGatePass';
import LOGO from '@salesforce/resourceUrl/companyLogo';

export default class VisitorPassGenerator extends LightningElement {

    @track companyName = '';
    @track visitorName = '';
    @track mobile = '';
    @track purpose = '';
    @track photoData = '';       // data URL: "data:image/png;base64,AAAA..."
    @track showPass = false;
    @track gatePassId = '';

    logo = LOGO;

    // -----------------------
    // Input handlers
    // -----------------------
    handleInput(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;
    }

    handlePhoto(event) {
        const file = event.target.files && event.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = (e) => {
            // e.target.result is a data URL: "data:image/jpeg;base64,AAAA..."
            this.photoData = e.target.result;
        };
        reader.readAsDataURL(file);
    }

    // If you also use lightning-file-upload in your HTML
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        if (uploadedFiles?.length) {
            // You can replace alert with a toast if desired
            // eslint-disable-next-line no-alert
            alert(`Photo uploaded: ${uploadedFiles[0].name}`);
        }
    }

    // -----------------------
    // Main action
    // -----------------------
    async generatePass() {
        try {
            // Build PhotoWrapper from data URL (if present)
            const photoWrapper = this.photoData
                ? this.parseDataUrlToPhotoWrapper(
                    this.photoData,
                    this.visitorName || 'visitor_photo'
                  )
                : null;

            const result = await createGatePass({
                companyName: this.companyName,
                visitorName: this.visitorName,
                mobile: this.mobile,
                purpose: this.purpose,
                photo: photoWrapper // <-- will attach to Files in Apex using FirstPublishLocationId
            });

            this.gatePassId = result.Id;
            this.showPass = true;

            if (photoWrapper) {
                // eslint-disable-next-line no-alert
                alert('Gate pass created and visitor photo attached to Files.');
            } else {
                // eslint-disable-next-line no-alert
                alert('Gate pass created (no photo attached).');
            }
        } catch (error) {
            console.error('Error creating gate pass:', error);
            // eslint-disable-next-line no-alert
            alert('Error: ' + (error?.body?.message || error.message));
        }
    }

    // -----------------------
    // Helpers
    // -----------------------
    /**
     * Converts a data URL (e.g., "data:image/png;base64,AAAA...")
     * into the PhotoWrapper expected by Apex:
     * { fileName, contentType, base64Data }
     */
    parseDataUrlToPhotoWrapper(dataUrl, baseName) {
        const match = /^data:([^;]+);base64,(.+)$/.exec(dataUrl || '');
        if (!match) {
            throw new Error('Invalid image data.');
        }
        const contentType = match[1]; // e.g., image/png
        const base64Data  = match[2];

        // Determine extension
        let ext = 'png';
        if (contentType === 'image/jpeg' || contentType === 'image/jpg') ext = 'jpg';
        else if (contentType === 'image/png') ext = 'png';

        const safeBase = (baseName || 'visitor_photo').replace(/[^\w\-]+/g, '_');
        const fileName = `${safeBase}.${ext}`;

        return { fileName, contentType, base64Data };
    }

    // -----------------------
    // Print
    // -----------------------
    printPass() {
        if (!this.gatePassId) {
            // eslint-disable-next-line no-alert
            alert('Please generate pass first!');
            return;
        }
        const vfUrl = `/apex/VisitorPassPDF?id=${this.gatePassId}`;
        window.open(vfUrl, '_blank');
    }
}