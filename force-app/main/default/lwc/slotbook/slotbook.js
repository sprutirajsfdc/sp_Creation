import { LightningElement, track } from 'lwc';

export default class BookingComponent extends LightningElement {
    @track selectedDate;
    @track timeSlots = [];

    handleDateChange(event) {
        this.selectedDate = event.target.value;

        // Simulate backend data
        const data = [
            { time: "09:00AM-10:00AM", capacity: 150, booked: 120 },
            { time: "10:00AM-11:30AM", capacity: 150, booked: 150 },
            { time: "11:30AM-12:30PM", capacity: 150, booked: 80 },
            { time: "12:30PM-01:30PM", capacity: 150, booked: 150 }
        ];

        this.timeSlots = data.map(slot => {
            const isFull = slot.booked >= slot.capacity;
            return {
                ...slot,
                isFull,
                className: isFull ? 'slot disabled' : 'slot available'
            };
        });
    }

    handleSlotClick(event) {
        const selectedTime = event.target.dataset.time;
        console.log('Selected:', selectedTime);
    }

    handleSubmit() {
        console.log('Submit clicked');
    }
}