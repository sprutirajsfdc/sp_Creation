import { LightningElement, track, wire } from 'lwc';
import getExams from '@salesforce/apex/ExamBookingController.getExams';
import getStudents from '@salesforce/apex/ExamBookingController.getStudents';
import getAllocationData from '@salesforce/apex/ExamBookingController.getAllocationData';
import bookSeat from '@salesforce/apex/ExamBookingController.bookSeat';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SEAT_ICON from '@salesforce/resourceUrl/seaticon';

export default class ExamBooking extends LightningElement {

    /* -------------------
       DROPDOWNS
    ------------------- */
    @track examOptions = [];
    @track studentOptions = [];

    selectedExamId;
    selectedStudentId;

    /* -------------------
       SEAT DATA
    ------------------- */
    @track seatsGrid = [];
    @track selectedSeat = null;

    allocationId;
    bookedSeats = [];

    rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    cols = [1, 2, 3, 4, 5, 6, 7, 8, 9];

    /* -------------------
       WIRED EXAMS
    ------------------- */
    @wire(getExams)
    wiredExams({ error, data }) {
        if (data) {
            this.examOptions = data.map(exam => ({
                label: exam.Name,
                value: exam.Id
            }));
        }
    }

    /* -------------------
       WIRED STUDENTS
    ------------------- */
    @wire(getStudents)
    wiredStudents({ error, data }) {
        if (data) {
            this.studentOptions = data.map(stu => ({
                label: stu.Name,
                value: stu.Id
            }));
        }
    }

    /* -------------------
       GETTERS
    ------------------- */
    get noSeatSelected() {
        return !this.selectedSeat;
    }

    get disableExam() {
        return !this.selectedStudentId;
    }

    get disableSeatMap() {
        return !this.selectedExamId || !this.selectedStudentId;
    }

    /* -------------------
       HANDLERS
    ------------------- */
    handleStudentChange(event) {
        this.selectedStudentId = event.detail.value;

        // reset downstream selections
        this.selectedExamId = null;
        this.selectedSeat = null;
        this.seatsGrid = [];
    }

    handleExamChange(event) {
        this.selectedExamId = event.detail.value;
        this.selectedSeat = null;
        this.fetchData();
    }

    /* -------------------
       FETCH SEAT DATA
    ------------------- */
    fetchData() {
        if (!this.selectedExamId) return;

        getAllocationData({ examId: this.selectedExamId })
            .then(result => {
                this.allocationId = result.allocationId;
                this.bookedSeats = result.bookedSeats || [];
                this.generateGrid();
            })
            .catch(error => console.error(error));
    }

    /* -------------------
       GRID GENERATION
    ------------------- */
    get legendSeatImg() {
        return SEAT_ICON;
    }

    generateGrid() {
        let grid = [];

        this.rows.forEach(rowLabel => {
            let rowSeats = [];

            this.cols.forEach(colNum => {

                const seatId = `${rowLabel}/${colNum < 10 ? '0' + colNum : colNum}`;
                const isEven = colNum % 2 === 0;
                const isBooked = this.bookedSeats.includes(seatId);
                const isSelected = this.selectedSeat?.id === seatId;

                let state = 'available';
                if (isEven) state = 'restricted';
                else if (isBooked) state = 'occupied';
                else if (isSelected) state = 'selected';

                rowSeats.push({
                    id: seatId,
                    className: `seat ${state}`,
                    isSelected,
                    useCustomIcon: (state === 'available' || state === 'occupied'),
                    seatImg: SEAT_ICON,
                    isClickable: !isEven && !isBooked,
                    addAisle: (colNum === 3 || colNum === 6)
                });
            });

            grid.push({ rowLabel, rowSeats });
        });

        this.seatsGrid = grid;
    }

    /* -------------------
       SEAT CLICK
    ------------------- */
    handleSeatClick(event) {
        const id = event.currentTarget.dataset.id;
        const seat = this.findSeatInGrid(id);

        if (seat && seat.isClickable) {
            const [r, c] = id.split('/');
            this.selectedSeat = { id, row: r, col: c };
            this.generateGrid();
        }
    }

    findSeatInGrid(id) {
        for (let r of this.seatsGrid) {
            let s = r.rowSeats.find(item => item.id === id);
            if (s) return s;
        }
        return null;
    }

    /* -------------------
       CONFIRM BOOKING
    ------------------- */
    handleConfirm() {
        if (!this.allocationId || !this.selectedSeat || !this.selectedStudentId) return;

        bookSeat({
            allocationId: this.allocationId,
            seatNumber: this.selectedSeat.id,
            contactId: this.selectedStudentId   // ✅ FIXED HERE
        })
        .then(result => {

            if (result === 'SUCCESS') {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Seat booked successfully!',
                    variant: 'success'
                }));

                this.selectedSeat = null;
                this.fetchData();
            }

            if (result === 'ALREADY_BOOKED') {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Warning',
                    message: 'Seat already booked!',
                    variant: 'warning'
                }));
            }

            if (result && result.startsWith('ERROR')) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: result,
                    variant: 'error'
                }));
            }
        })
        .catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body ? error.body.message : error.message,
                variant: 'error'
            }));
        });
    }
}