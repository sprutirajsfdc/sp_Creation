import { LightningElement, track } from 'lwc';
import recaptchaResource from '@salesforce/resourceUrl/recaptcha'
export default class RecaptchaComponent extends LightningElement {
 iframeUrl = recaptchaResource;
    @track isVerified = false;
    @track errorMessage = '';
    recaptchaToken;

    connectedCallback() {
        window.addEventListener('message', this.handleMessage.bind(this));
    }

    disconnectedCallback() {
        window.removeEventListener('message', this.handleMessage.bind(this));
    }

    handleIframeLoad() {
        console.log('reCAPTCHA iframe loaded');
    }

    handleMessage(event) {
        // 🔐 SECURITY: Validate origin
        if (event.origin !== window.location.origin) {
            return;
        }

        const data = event.data;

        if (data?.type === 'recaptchaToken') {
            this.recaptchaToken = data.token;
            this.verifyToken();
        }

        if (data?.type === 'recaptchaExpired') {
            this.isVerified = false;
            this.errorMessage = 'Verification expired. Please try again.';
        }
    }

    async verifyToken() {
        try {
            const result = await verifyRecaptcha({ token: this.recaptchaToken });

            if (result === true) {
                this.isVerified = true;
                this.errorMessage = '';
            } else {
                this.isVerified = false;
                this.errorMessage = 'Verification failed. Try again.';
            }

        } catch (error) {
            this.isVerified = false;
            this.errorMessage = 'Server verification error.';
            console.error(error);
        }
    }

    // Optional: reset captcha manually
    resetCaptcha() {
        const iframe = this.template.querySelector('iframe');
        iframe.contentWindow.postMessage('resetRecaptcha', window.location.origin);
        this.isVerified = false;
    }
}