import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import TYPE_FIELD from '@salesforce/schema/Warehouse_Inventory__c.Type__c';

// Static resources
import paidIcon from '@salesforce/resourceUrl/svgg';
import dueIcon from '@salesforce/resourceUrl/due';

export default class InventoryIcon extends LightningElement {
    @api recordId;
    @track typeValue;
    @track showConfetti = false;

    @wire(getRecord, { recordId: '$recordId', fields: [TYPE_FIELD] })
    wiredRecord({ error, data }) {
        if (data) {
            const previousType = this.typeValue;
            this.typeValue = data.fields.Type__c.value;

            // Trigger celebration only if it changed to paid
            if (this.typeValue === 'paid' && previousType !== 'paid') {
                this.fireConfetti();
            }
        } else if (error) {
            console.error(error);
        }
    }

    get iconUrl() {
        return this.typeValue === 'paid' ? paidIcon : dueIcon;
    }

    fireConfetti() {
        this.showConfetti = true;

        // Simple confetti using canvas
        const canvas = this.template.querySelector('.confetti-canvas');
        if (!canvas) return;
        const ctx = canvas.getContext('2d');
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;

        const confettiCount = 150;
        const confetti = [];
        for (let i = 0; i < confettiCount; i++) {
            confetti.push({
                x: Math.random() * canvas.width,
                y: Math.random() * canvas.height - canvas.height,
                r: Math.random() * 6 + 4,
                d: Math.random() * confettiCount,
                color: `hsl(${Math.random() * 360}, 100%, 50%)`,
                tilt: Math.random() * 10 - 10,
                tiltAngleIncremental: Math.random() * 0.07 + 0.05,
                tiltAngle: 0
            });
        }

        let animationFrame;
        const draw = () => {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            confetti.forEach(c => {
                ctx.beginPath();
                ctx.lineWidth = c.r / 2;
                ctx.strokeStyle = c.color;
                ctx.moveTo(c.x + c.tilt + c.r / 4, c.y);
                ctx.lineTo(c.x + c.tilt, c.y + c.tilt + c.r / 4);
                ctx.stroke();
                c.tiltAngle += c.tiltAngleIncremental;
                c.y += (Math.cos(c.d) + 3 + c.r / 2) / 2;
                c.tilt = Math.sin(c.tiltAngle) * 15;

                if (c.y > canvas.height) {
                    c.y = -10;
                    c.x = Math.random() * canvas.width;
                }
            });
            animationFrame = requestAnimationFrame(draw);
        };
        draw();

        // Stop after 3 seconds
        setTimeout(() => {
            cancelAnimationFrame(animationFrame);
            this.showConfetti = false;
        }, 3000);
    }
}