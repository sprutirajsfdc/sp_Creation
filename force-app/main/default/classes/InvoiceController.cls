public with sharing class InvoiceController {
    public Invoice__c invoice { get; set; }
    public Contact customer { get; set; }
    public Integer totalLineItems { get; set; }
    
    public List<Invoice_Line_Items__c> lineItems { get; set; } // NEW

    public InvoiceController(ApexPages.StandardController stdController) {

        invoice = [
            SELECT Id, Customer__c
            FROM Invoice__c
            WHERE Id = :stdController.getId()
            LIMIT 1
        ];

        // Customer fetch
        if (invoice.Customer__c != null) {
            customer = [
                SELECT Id, Name, Phone, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
                FROM Contact
                WHERE Id = :invoice.Customer__c
                LIMIT 1
            ];
        }

        // Line Items fetch (ONLY required fields)
        lineItems = [
            SELECT Id, Product__r.Name, Quantity__c
            FROM Invoice_Line_Items__c
            WHERE Invoice__c = :invoice.Id
        ];

        totalLineItems = lineItems.size();
    }

    public String getBillingAddress() {
        if (customer != null) {
            String address = '';
            if (customer.MailingStreet != null) address += customer.MailingStreet + ', ';
            if (customer.MailingCity != null) address += customer.MailingCity + ', ';
            if (customer.MailingState != null) address += customer.MailingState + ' - ';
            if (customer.MailingPostalCode != null) address += customer.MailingPostalCode + ', ';
            if (customer.MailingCountry != null) address += customer.MailingCountry;
            return address;
        }
        return '';
    }
}