public with sharing class HotelRoomController {

    @AuraEnabled(cacheable=true)
    public static List<Room__c> getRooms(Id hotelId) {
        return [
            SELECT Id, Room_Number__c, Room_Type__c, Price_Per_Night__c,
                   Status__c, Hotel__c, Guest__c
            FROM Room__c
            WHERE Hotel__c = :hotelId
            ORDER BY Room_Number__c
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Room__c> getAvailableRooms(Id hotelId) {
        return [
            SELECT Id, Room_Number__c, Room_Type__c, Price_Per_Night__c,
                   Status__c, Hotel__c, Guest__c
            FROM Room__c
            WHERE Hotel__c = :hotelId
            AND Status__c = 'Available'
            ORDER BY Room_Number__c
        ];
    }

    // ============================
    // MAIN CHECK-IN FLOW (FINAL)
    // ============================
   @AuraEnabled
public static Id processCheckIn(
    String guestName,
    String email,
    String phone,
    Integer numberOfGuests,
    Date checkInDate,
    Date checkOutDate,
    Id roomId,
    Decimal pricePerNight,
    Integer numberOfDays
) {

    System.debug('=== CHECK-IN START ===');
    System.debug('Guest: ' + guestName);
    System.debug('RoomId: ' + roomId);
    System.debug('Days: ' + numberOfDays);

    try {

        // 1. CREATE CONTACT
        Contact c = new Contact(
            LastName = guestName,
            Email = email,
            Phone = phone
        );
        insert c;

        System.debug('Contact Created: ' + c.Id);

        // 2. CREATE BOOKING
        Booking__c b = new Booking__c(
            Check_in_Date__c = checkInDate,
            Check_out_Date__c = checkOutDate,
            Number_of_Guests__c = String.valueOf(numberOfGuests), // ✅ FIX
            Booking_Status__c = 'Confirmed',
            Room__c = roomId
        );
        insert b;

        System.debug('Booking Created: ' + b.Id);

        // 3. CREATE STAY BOOKING
        Stay_Booking__c s = new Stay_Booking__c(
            Room__c = roomId,
            No_of_day_Stay__c = String.valueOf(numberOfDays), // ✅ FIX
            Total_Price__c = pricePerNight * numberOfDays
        );
        insert s;

        System.debug('Stay Booking Created: ' + s.Id);

        // 4. UPDATE ROOM
        Room__c r = new Room__c(
            Id = roomId,
            Status__c = 'Occupied',
            Guest__c = c.Id
        );
        update r;

        System.debug('Room Updated');
        System.debug('=== CHECK-IN SUCCESS ===');

        return b.Id;

    } catch (Exception e) {

        System.debug('ERROR: ' + e.getMessage());
        System.debug('STACK: ' + e.getStackTraceString());

        throw new AuraHandledException('Check-in failed: ' + e.getMessage());
    }
}
}