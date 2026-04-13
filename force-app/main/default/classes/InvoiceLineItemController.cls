public with sharing class InvoiceLineItemController {

    public class InvoiceSummary {
        @AuraEnabled public Decimal grandTotal;
        @AuraEnabled public String status;
    }

    @AuraEnabled(cacheable=true)
    public static InvoiceSummary getInvoiceSummary(Id invoiceId) {
        InvoiceSummary summary = new InvoiceSummary();
        if(invoiceId == null) {
            summary.grandTotal = 0;
            summary.status = null;
            return summary;
        }

        // Get grand total
        AggregateResult result = [
            SELECT SUM(Total_Price__c) totalAmt
            FROM Invoice_Line_Items__c
            WHERE Invoice__c = :invoiceId
        ];
        summary.grandTotal = (Decimal)result.get('totalAmt') != null ? (Decimal)result.get('totalAmt') : 0;

        // Get invoice status
        Invoice__c inv = [SELECT Status__c FROM Invoice__c WHERE Id = :invoiceId LIMIT 1];
        summary.status = inv.Status__c;

        return summary;
    }
}