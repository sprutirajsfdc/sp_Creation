trigger PreventOverlapBooking on Event (before insert, before update) {
    
    for (Event e : Trigger.new) {
        if ( e.StartDateTime == null || e.EndDateTime == null) {
            continue;
        }
        
        List<Event> conflicts = [
            SELECT Id, StartDateTime, EndDateTime
            FROM Event
            WHERE 
            Id != :e.Id
            AND StartDateTime < :e.EndDateTime
            AND EndDateTime > :e.StartDateTime
        ];
        
        if (!conflicts.isEmpty()) {
            e.addError('This faculty is already booked during this time slot.');
        }
    }
}