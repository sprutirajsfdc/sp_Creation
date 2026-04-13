public with sharing class ExamBookingController {

    /* ---------------------------
       1. GET ALL EXAMS
    ----------------------------*/
    @AuraEnabled(cacheable=true)
    public static List<Exam__c> getExams() {
        return [
            SELECT Id, Name
            FROM Exam__c
            ORDER BY Name
        ];
    }

    /* ---------------------------
       2. GET STUDENTS (CONTACTS)
       For Step 1 in UI
    ----------------------------*/
    @AuraEnabled(cacheable=true)
    public static List<Contact> getStudents() {
        return [
            SELECT Id, Name
            FROM Contact
            ORDER BY Name
        ];
    }

    /* ---------------------------
       3. GET SEAT ALLOCATION DATA
    ----------------------------*/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getAllocationData(Id examId) {

        Seat_Allocation__c sa = [
            SELECT Id,
                   Total_Seat__c,
                   (SELECT Seat_Number__c
                    FROM Bookings__r
                    WHERE Status__c = 'Booked')
            FROM Seat_Allocation__c
            WHERE Exam__c = :examId
            LIMIT 1
        ];

        List<String> bookedSeatNumbers = new List<String>();

        if (sa.Bookings__r != null) {
            for (Booking__c b : sa.Bookings__r) {
                bookedSeatNumbers.add(b.Seat_Number__c);
            }
        }

        Map<String, Object> result = new Map<String, Object>();
        result.put('allocationId', sa.Id);
        result.put('bookedSeats', bookedSeatNumbers);

        return result;
    }

    /* ---------------------------
       4. BOOK SEAT
       Flow: Student → Exam → Seat
    ----------------------------*/
    @AuraEnabled
    public static String bookSeat(Id allocationId, String seatNumber, Id contactId) {
        try {

            /* 1. Validate Student (Contact) */
            Contact c = [
                SELECT Id
                FROM Contact
                WHERE Id = :contactId
                LIMIT 1
            ];

            if (c == null) {
                return 'ERROR: Invalid Student selected.';
            }

            /* 2. Get Exam from Seat Allocation */
            Seat_Allocation__c sa = [
                SELECT Id, Exam__c
                FROM Seat_Allocation__c
                WHERE Id = :allocationId
                LIMIT 1
            ];

            if (sa.Exam__c == null) {
                return 'ERROR: Seat Allocation is not linked to an Exam.';
            }

            /* 3. Check if seat already booked */
            Integer existing = [
                SELECT COUNT()
                FROM Booking__c
                WHERE Seat_Allocation__c = :allocationId
                AND Seat_Number__c = :seatNumber
                AND Status__c = 'Booked'
            ];

            if (existing > 0) {
                return 'ALREADY_BOOKED';
            }

            /* 4. Create Booking */
            Booking__c booking = new Booking__c(
                Seat_Allocation__c = sa.Id,
                Exam__c = sa.Exam__c,
                Student__c = c.Id,
                Seat_Number__c = seatNumber,
                Status__c = 'Booked'
            );

            insert booking;

            return 'SUCCESS';

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}