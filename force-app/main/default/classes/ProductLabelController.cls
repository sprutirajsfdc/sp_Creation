public with sharing class ProductLabelController {

    public List<Product2> Products { get; set; }

    public ProductLabelController() {
        // Get Product Ids from page parameters
        String prodIdsParam = ApexPages.currentPage().getParameters().get('id');

        // Initialize the Products list
        Products = new List<Product2>();

        // Check if parameter is not null or blank
        if (!String.isBlank(prodIdsParam)) {
            // Split comma-separated IDs into a List<Id>
            List<Id> prodIds = new List<Id>();
            for (String s : prodIdsParam.split(',')) {
                s = s.trim(); // remove any extra whitespace
                if (!String.isBlank(s)) {
                    prodIds.add(Id.valueOf(s));
                }
            }

            // Query Product2 records if there are valid IDs
            if (!prodIds.isEmpty()) {
                Products = [
                    SELECT Id, Name, Qnty__c, Manufacture_Date__c, ProductCode, Expiry_Date__c,Description
                    FROM Product2
                    WHERE Id IN :prodIds
                ];
            }
        }
    }
}