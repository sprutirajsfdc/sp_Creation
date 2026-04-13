public class SfdcinvoiceController {

    public List<Warehouse_Inventory__c> lineItems {get; set;}
    public Decimal grandTotal {get; set;}

    // ❌ old: accountId
    public Id warehouseId {get; set;}
    public Id accountId {get; set;}

    public Account acc {get; set;}
    public Contact billContact {get; set;}

    public String invoiceNumber {get; set;}

    public SfdcinvoiceController() {

        // ✅ Get Warehouse Inventory Id from URL
        warehouseId = ApexPages.currentPage().getParameters().get('id');

        // ✅ Fetch that Warehouse record
        Warehouse_Inventory__c inv = [
            SELECT Id, Account__c, Name,
                   Quantity__c, Rate__c,Additional_Notes__c,
                   Item_Description__c, Item_Name__c
            FROM Warehouse_Inventory__c
            WHERE Id = :warehouseId
            LIMIT 1
        ];

        // ✅ Set Account Id from Warehouse
        accountId = inv.Account__c;

        // ✅ Set Invoice Number
        invoiceNumber = inv.Name;

        // Fetch Account
        acc = [
            SELECT Id, Name, BillingStreet, BillingCity, BillingState,
                   BillingPostalCode, BillingCountry, Phone, VAT_Number__c
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];

        // Fetch Contact
        billContact = [
            SELECT Id, Name, MailingStreet, MailingCity, MailingState,
                   MailingPostalCode, MailingCountry, Phone,Title,Department
            FROM Contact
            WHERE AccountId = :accountId
            LIMIT 1
        ];

        // ✅ Only ONE line item (current record)
        lineItems = new List<Warehouse_Inventory__c>();
        lineItems.add(inv);

        // Calculate Total
        grandTotal = 0;

        if (inv.Quantity__c != null && inv.Rate__c != null) {
            grandTotal = inv.Quantity__c * inv.Rate__c;
        }
    }
}