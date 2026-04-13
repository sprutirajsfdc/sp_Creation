public class POPDFController {

    public List<Purchase_Order_Line__c> lineItems {get; set;}
    public Account vendor {get; set;}
    public Decimal grandTotal {get; set;}
    public Id poId {get; set;}
    public Purchase_Order__c poRecord {get; set;}

    public POPDFController() {

        lineItems = new List<Purchase_Order_Line__c>();
        grandTotal = 0;

        // Get PO Id
        poId = ApexPages.currentPage().getParameters().get('id');

        if(poId == null){
            return;
        }

        // ✅ SAFE PO FETCH
        List<Purchase_Order__c> poList = [
            SELECT Id, Name, Vendor__c, CreatedDate,
                   Excepted_Delivery_Date__c, Terms__c
            FROM Purchase_Order__c
            WHERE Id = :poId
            LIMIT 1
        ];

        if(poList.isEmpty()){
            return;
        }

        poRecord = poList[0];

        // ✅ SAFE VENDOR FETCH
        if(poRecord.Vendor__c != null){

            List<Account> accList = [
                SELECT Id, Name, BillingStreet, BillingCity,
                       BillingState, BillingPostalCode,
                       BillingCountry, Phone
                FROM Account
                WHERE Id = :poRecord.Vendor__c
                LIMIT 1
            ];

            if(!accList.isEmpty()){
                vendor = accList[0];
            }
        }

        // ✅ SAFE LINE ITEMS
        lineItems = [
            SELECT Id,
                   Name,
                   Quantity__c,
                   Unit_Price__c,
                   Price__c,
                   Total_Price__c,
                   Purchase_Order__c,
                   Product__c,
                   Product__r.Name
            FROM Purchase_Order_Line__c
            WHERE Purchase_Order__c = :poId
        ];

        // ✅ TOTAL
        for(Purchase_Order_Line__c item : lineItems){
            if(item.Total_Price__c != null){
                grandTotal += item.Total_Price__c;
            }
        }
    }
}