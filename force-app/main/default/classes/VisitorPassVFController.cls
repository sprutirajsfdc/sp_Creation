public with sharing class VisitorPassVFController {
    public Permit_Gate_Pass__c GatePass { get; set; }

    // Expose the latest ContentVersion Id for an image attached in "Related Files"
    public Id PhotoVersionId { get; private set; }

    // ✅ Required constructor for VF StandardController extension
    public VisitorPassVFController(ApexPages.StandardController controller) {
        Id recordId = controller.getId();

        GatePass = [
            SELECT Id, Visitor_Name__c, Visitor_Mobile_Number__c, Purpose_to_Visit__c, Photo_URL__c,Description__c
            FROM Permit_Gate_Pass__c
            WHERE Id = :recordId
            LIMIT 1
        ];

        // Find the latest file linked to this record (Related Files)
        // You can refine filters as needed (e.g., only images by extension)
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
            ORDER BY SystemModstamp DESC
            LIMIT 5
        ];

        if (!links.isEmpty()) {
            // Grab the most recent ContentVersion for the most recent file
            ContentVersion cv = [
                SELECT Id, FileExtension, VersionNumber, CreatedDate
                FROM ContentVersion
                WHERE ContentDocumentId = :links[0].ContentDocumentId
                ORDER BY VersionNumber DESC
                LIMIT 1
            ];
            PhotoVersionId = cv.Id;
        }
    }
}