import { LightningElement, wire, track } from 'lwc';
import getRooms from '@salesforce/apex/HotelRoomController.getRooms';

export default class RoomManagementMatrix extends LightningElement {
    hotelId = 'a0XdM00000OPJXtUAP';
    // Your specific image URL
    roomImageUrl = 'https://spcreation2-dev-ed--c.develop.vf.force.com/resource/1776658765000/room';

    @track rooms = [];
    @track floors = [];
    selectedStatus = 'All';

    totalRooms = 0;
    occupancyRate = 0;
    cleaningCount = 0;
    maintenanceCount = 0;

    statusOptions = [
        { label: 'All', value: 'All' },
        { label: 'Available', value: 'Available' },
        { label: 'Occupied', value: 'Occupied' },
        { label: 'Cleaning', value: 'Cleaning' },
        { label: 'Maintenance', value: 'Maintenance' }
    ];

    @wire(getRooms, { hotelId: '$hotelId' })
    wiredRooms({ error, data }) {
        if (data) {
            this.rooms = data.map(r => ({
                ...r,
                // Adding the image URL here
                imageUrl: this.roomImageUrl, 
                cardClass: this.getStatusClass(r.Status__c)
            }));
            this.processRooms();
        } else if (error) {
            console.error(error);
        }
    }

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
        this.processRooms();
    }

    processRooms() {
        let filtered = this.selectedStatus === 'All'
            ? this.rooms
            : this.rooms.filter(r => r.Status__c === this.selectedStatus);

        let floorMap = {};
        filtered.forEach(room => {
            let floor = room.Room_Number__c.toString().charAt(0);
            if (!floorMap[floor]) floorMap[floor] = [];
            floorMap[floor].push(room);
        });

        this.floors = Object.keys(floorMap).sort().map(f => ({
            floorNumber: f,
            rooms: floorMap[f]
        }));

        this.calculateStats();
    }

    calculateStats() {
        this.totalRooms = this.rooms.length;
        this.cleaningCount = this.rooms.filter(r => r.Status__c === 'Cleaning').length;
        this.maintenanceCount = this.rooms.filter(r => r.Status__c === 'Maintenance').length;
        let occupied = this.rooms.filter(r => r.Status__c === 'Occupied').length;
        this.occupancyRate = this.totalRooms ? Math.round((occupied / this.totalRooms) * 100) : 0;
    }

    getStatusClass(status) {
        switch (status) {
            case 'Available': return 'room-card available';
            case 'Occupied': return 'room-card occupied';
            case 'Cleaning': return 'room-card cleaning';
            case 'Maintenance': return 'room-card maintenance';
            default: return 'room-card';
        }
    }
    
}