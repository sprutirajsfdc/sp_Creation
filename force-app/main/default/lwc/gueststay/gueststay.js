import { LightningElement, track, wire } from 'lwc';
import getAvailableRooms from '@salesforce/apex/HotelRoomController.getAvailableRooms';
import processCheckIn from '@salesforce/apex/HotelRoomController.processCheckIn';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RoomManagementMatrix extends LightningElement {

    @track rooms = [];
    @track selectedRoom = null;

    // ✅ Guest Fields
    @track guestName = '';
    @track email = '';
    @track phone = '';
    @track numberOfGuests = 1;

    checkInDate = this.getTodayDate();
    checkOutDate = this.getTomorrowDate();
    duration = 0;
    spaCredit = 50.00;

    hotelId = 'a0XdM00000OPJXtUAP';
    roomImageUrl = 'https://spcreation2-dev-ed--c.develop.vf.force.com/resource/1776658765000/room';

    idOptions = [
        { label: 'Passport', value: 'Passport' },
        { label: 'Driver License', value: 'DL' }
    ];

    // =========================
    // LOAD ROOMS
    // =========================
    @wire(getAvailableRooms, { hotelId: '$hotelId' })
    wiredRooms({ error, data }) {
        if (data) {
            console.log('Rooms Loaded:', data);

            this.rooms = data.map(r => ({
                ...r,
                imageUrl: this.roomImageUrl,
                floorNumber: r.Room_Number__c ? String(r.Room_Number__c).charAt(0) : '',
                selectionClass: 'room-select-card'
            }));

            this.selectedRoom = null;
            this.calculateDuration();

        } else if (error) {
            console.error('Room Load Error:', JSON.stringify(error));
        }
    }

    // =========================
    // INPUT HANDLER
    // =========================
    handleInputChange(event) {
        const field = event.target.name;
        this[field] = event.target.value;

        console.log(`Field Updated → ${field}:`, this[field]);
    }

    // =========================
    // DATE CHANGE
    // =========================
    handleDateChange(event) {
        if (event.target.name === 'checkin') {
            this.checkInDate = event.target.value;
        } else {
            this.checkOutDate = event.target.value;
        }

        console.log('Dates Updated:', this.checkInDate, this.checkOutDate);

        this.calculateDuration();
    }

    calculateDuration() {
        const start = new Date(this.checkInDate);
        const end = new Date(this.checkOutDate);

        const diff = end - start;

        this.duration = diff > 0
            ? Math.ceil(diff / (1000 * 60 * 60 * 24))
            : 0;

        console.log('Duration:', this.duration);
    }

    // =========================
    // ROOM SELECT
    // =========================
    handleRoomSelect(event) {
        const roomId = event.currentTarget.dataset.id;

        console.log('Clicked Room ID:', roomId);

        this.rooms = this.rooms.map(r => ({
            ...r,
            selectionClass: r.Id === roomId
                ? 'room-select-card selected'
                : 'room-select-card'
        }));

        this.selectedRoom = this.rooms.find(r => r.Id === roomId);

        console.log('Selected Room:', JSON.stringify(this.selectedRoom));
    }

    // =========================
    // VALIDATION
    // =========================
    validateInputs() {

        if (!this.guestName) {
            this.showToast('Error', 'Guest name is required', 'error');
            return false;
        }

        if (!this.email) {
            this.showToast('Error', 'Email is required', 'error');
            return false;
        }

        if (!this.phone) {
            this.showToast('Error', 'Phone is required', 'error');
            return false;
        }

        if (!this.selectedRoom) {
            this.showToast('Error', 'Please select a room', 'error');
            return false;
        }

        if (this.duration <= 0) {
            this.showToast('Error', 'Invalid check-in dates', 'error');
            return false;
        }

        return true;
    }

    // =========================
    // CONFIRM CHECK-IN
    // =========================
    handleConfirmCheckIn() {

        console.log('=== CHECK-IN CLICKED ===');

        if (!this.validateInputs()) {
            return;
        }

        const payload = {
            guestName: this.guestName,
            email: this.email,
            phone: this.phone,
            numberOfGuests: Number(this.numberOfGuests),
            checkInDate: this.checkInDate,
            checkOutDate: this.checkOutDate,
            roomId: this.selectedRoom.Id,
            pricePerNight: this.selectedRoom.Price_Per_Night__c,
            numberOfDays: this.duration
        };

        console.log('Sending Payload:', JSON.stringify(payload));

        processCheckIn(payload)
            .then(result => {

                console.log('Booking Success:', result);

                this.showToast(
                    'Success',
                    'Check-in completed successfully!',
                    'success'
                );

                this.resetForm();
            })
            .catch(error => {

                console.error('FULL ERROR:', JSON.stringify(error));

                this.showToast(
                    'Error',
                    error?.body?.message || 'Check-in failed',
                    'error'
                );
            });
    }

    // =========================
    // RESET FORM
    // =========================
    resetForm() {

        this.guestName = '';
        this.email = '';
        this.phone = '';
        this.numberOfGuests = 1;

        this.selectedRoom = null;

        this.rooms = this.rooms.map(r => ({
            ...r,
            selectionClass: 'room-select-card'
        }));

        console.log('Form Reset Complete');
    }

    // =========================
    // CALCULATIONS
    // =========================
    get baseTotal() {
        if (!this.selectedRoom) return '0.00';
        return (this.selectedRoom.Price_Per_Night__c * this.duration).toFixed(2);
    }

    get taxAmount() {
        return (Number(this.baseTotal) * 0.12).toFixed(2);
    }

    get grandTotal() {
        const total =
            Number(this.baseTotal) +
            Number(this.taxAmount) -
            this.spaCredit;

        return total > 0 ? total.toFixed(2) : '0.00';
    }

    get selectedRoomType() {
        return this.selectedRoom?.Room_Type__c || 'No Room Selected';
    }

    // =========================
    // TOAST
    // =========================
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }

    // =========================
    // DATE HELPERS
    // =========================
    getTodayDate() {
        return new Date().toISOString().split('T')[0];
    }

    getTomorrowDate() {
        const d = new Date();
        d.setDate(d.getDate() + 1);
        return d.toISOString().split('T')[0];
    }
}