public with sharing class InvoicePDFController {

    public List<Invoice_Line_Items__c> lineItems {get; set;}
    public Contact customer {get; set;}
    public Decimal grandTotal {get; set;}
    public Id invoiceId {get; set;}
    public Invoice__c invoiceRecord {get; set;} // ✅ ADD THIS

    public InvoicePDFController() {

        // Get Invoice Id from URL
        invoiceId = ApexPages.currentPage().getParameters().get('id');

        // Fetch Invoice
        invoiceRecord = [   // ✅ STORE IN PROPERTY
            SELECT Id, Name, Customer__c, CreatedDate
            FROM Invoice__c
            WHERE Id = :invoiceId
            LIMIT 1
        ];

        // Fetch Customer
        customer = [
            SELECT Id, Name, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,Phone
            FROM Contact
            WHERE Id = :invoiceRecord.Customer__c
            LIMIT 1
        ];

        // Fetch Line Items
        lineItems = [
            SELECT Id, Name, GST_18_Rate__c, Invoice__c, Net_Price__c,
                   Quantity__c, Total_Price__c, Unit_Price__c,
                   Product__r.Name, Product__r.Size__c,Product__r.Thickness__c,Product__r.Plywood_Type__c,Product__r.Packaging_Size__c 
            FROM Invoice_Line_Items__c
            WHERE Invoice__c = :invoiceId
        ];

        // Calculate Total
        grandTotal = 0;
        for(Invoice_Line_Items__c item : lineItems){
            if(item.Total_Price__c != null){
                grandTotal += item.Total_Price__c;
            }
        }
    }
}