public with sharing class ListingMapController {
    @AuraEnabled(cacheable=true)
    public static List<ListingLocationDTO> getListingLocations(String cityFilter, Integer limitSize) {
        // Default limits for safety
        Integer effectiveLimit = (limitSize != null && limitSize > 0 && limitSize <= 2000) ? limitSize : 500;

        // Build dynamic filter (optional)
        String whereClause = '';
        if (String.isNotBlank(cityFilter)) {
            whereClause = 'WHERE City__c = :cityFilter';
        }

        // Query only needed fields
        String soql = 'SELECT Id, Name, Street__c, City__c, State__c ' +
                      'FROM Listing__c ' + whereClause + ' ORDER BY LastModifiedDate DESC LIMIT :effectiveLimit';

        List<Listing__c> listings = Database.query(soql);

        // Map into DTOs for the LWC
        List<ListingLocationDTO> results = new List<ListingLocationDTO>();
        for (Listing__c l : listings) {
            if (String.isNotBlank(l.Street__c) || String.isNotBlank(l.City__c) || String.isNotBlank(l.State__c)) {
                results.add(new ListingLocationDTO(
                    l.Id,
                    l.Name,
                    l.Street__c,
                    l.City__c,
                    l.State__c
                ));
            }
        }
        return results;
    }

    // Lightweight transport object
    public class ListingLocationDTO {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String street;
        @AuraEnabled public String city;
        @AuraEnabled public String state;

        public ListingLocationDTO(String id, String name, String street, String city, String state) {
            this.id = id;
            this.name = name;
            this.street = street;
            this.city = city;
            this.state = state;
        }
    }
}