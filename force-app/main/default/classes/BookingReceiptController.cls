public with sharing class BookingReceiptController {

    public Booking__c booking { get; set; }
    public Contact contact { get; set; }
    public Room__c room { get; set; }
    public Stay_Booking__c stay { get; set; }
    public Hotel__c hotel { get; set; }

    public String formattedCheckIn { get; set; }
    public String formattedCheckOut { get; set; }
    public String formattedToday { get; set; }

    public BookingReceiptController() {

        Id bookingId = ApexPages.currentPage().getParameters().get('id');

        booking = [
            SELECT Id, Check_in_Date__c, Check_out_Date__c, Room__c
            FROM Booking__c
            WHERE Id = :bookingId
            LIMIT 1
        ];

        room = [
            SELECT Id, Room_Number__c, Room_Type__c, Price_Per_Night__c,
                   Guest__c, Hotel__c
            FROM Room__c
            WHERE Id = :booking.Room__c
            LIMIT 1
        ];

        hotel = [
            SELECT Id, Address__c, Rating__c, Amenities__c, Website__c
            FROM Hotel__c
            WHERE Id = :room.Hotel__c
            LIMIT 1
        ];

        contact = [
            SELECT Id, LastName, Email, Phone
            FROM Contact
            WHERE Id = :room.Guest__c
            LIMIT 1
        ];

        stay = [
            SELECT Id, No_of_day_Stay__c, Total_Price__c
            FROM Stay_Booking__c
            WHERE Room__c = :room.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        // DATE FORMATTING
        formattedCheckIn = formatDate(booking.Check_in_Date__c);
        formattedCheckOut = formatDate(booking.Check_out_Date__c);
        formattedToday = formatDate(System.now());
    }

    // =========================
    // FORMAT DATE + TIME
    // =========================
    public String formatDate(Datetime dt) {

        if (dt == null) return '';

        Date d = dt.date();

        Integer day = d.day();
        String suffix = getSuffix(day);

        String month = getMonthName(d.month());
        String year = String.valueOf(d.year());

        Integer hour = dt.hour();
        Integer minute = dt.minute();

        String ampm = (hour >= 12) ? 'PM' : 'AM';

        hour = Math.mod(hour, 12);
        if (hour == 0) hour = 12;

        String minuteStr = (minute < 10) ? '0' + minute : String.valueOf(minute);

        String timeStr = hour + ':' + minuteStr + ' ' + ampm;

        return day + suffix + ' ' + month + ' ' + year + ', ' + timeStr;
    }

    public String getMonthName(Integer month) {
        if (month == 1) return 'January';
        if (month == 2) return 'February';
        if (month == 3) return 'March';
        if (month == 4) return 'April';
        if (month == 5) return 'May';
        if (month == 6) return 'June';
        if (month == 7) return 'July';
        if (month == 8) return 'August';
        if (month == 9) return 'September';
        if (month == 10) return 'October';
        if (month == 11) return 'November';
        if (month == 12) return 'December';
        return '';
    }

    public String getSuffix(Integer day) {

        if (day >= 11 && day <= 13) return 'th';

        Integer lastDigit = Math.mod(day, 10);

        if (lastDigit == 1) return 'st';
        if (lastDigit == 2) return 'nd';
        if (lastDigit == 3) return 'rd';

        return 'th';
    }
}