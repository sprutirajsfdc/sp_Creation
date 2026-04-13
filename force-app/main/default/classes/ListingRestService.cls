@RestResource(urlMapping='/AllListing/*')
global with sharing class ListingRestService {

    // Owner Wrapper
    global class OwnerWrapper {
        public String username;
        public String phone;

        public OwnerWrapper(String username, String phone) {
            this.username = username;
            this.phone = phone;
        }
    }

    // Record Wrapper
    global class RecordWrapper {
        public Id id;
        public String name;
        public OwnerWrapper owner;

        public RecordWrapper(Id id, String name, OwnerWrapper owner) {
            this.id = id;
            this.name = name;
            this.owner = owner;
        }
    }

    // Folder Wrapper
    global class FolderWrapper {
        public String recordType;
        public List<RecordWrapper> records;

        public FolderWrapper(String recordType) {
            this.recordType = recordType;
            this.records = new List<RecordWrapper>();
        }
    }

    @HttpGet
    global static void getListingsGrouped() {

        Map<String, FolderWrapper> folderMap = new Map<String, FolderWrapper>();

        try {
            List<Listing__c> listings = [
                SELECT Id, Name, RecordType.Name,
                       Owner.Name, Owner.Phone
                FROM Listing__c
            ];

            for (Listing__c lst : listings) {

                String recordTypeName = (lst.RecordType != null)
                    ? lst.RecordType.Name
                    : 'Unknown';

                // Create folder if not exists
                if (!folderMap.containsKey(recordTypeName)) {
                    folderMap.put(recordTypeName, new FolderWrapper(recordTypeName));
                }

                // Owner Info
                OwnerWrapper owner = new OwnerWrapper(
                    lst.Owner.Name,
                    lst.Owner.Phone
                );

                // Record Info
                RecordWrapper rec = new RecordWrapper(
                    lst.Id,
                    lst.Name,
                    owner
                );

                folderMap.get(recordTypeName).records.add(rec);
            }

            // Convert to array
            List<FolderWrapper> result = folderMap.values();

            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf(
                JSON.serializePretty(result)
            );

        } catch (Exception e) {

            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf(
                JSON.serializePretty(
                    new Map<String, String>{
                        'error' => e.getMessage()
                    }
                )
            );
        }
    }
}