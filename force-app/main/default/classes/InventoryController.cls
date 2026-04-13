/**
* @File Name : InventoryController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : November 21, 2025
**/

public with sharing class InventoryController {

    // ========================================
    //  FETCH INVENTORY LIST
    // ========================================
    @AuraEnabled(cacheable=true)
    public static List<WrapperData> getInventoryData() {
        List<Warehouse_Inventory__c> invList = [
            SELECT Id,
                   Products__c,
                   Product__r.Name,
                   Price_Book_Entry__r.Product__r.Name,
                   Quantity__c,
                   Result_Stocks__c,
                   issue_Date__c,
                   Price_Book_Entry__c,
                   Price_Book_Entry__r.List_Price__c
            FROM Warehouse_Inventory__c
        ];

        List<WrapperData> results = new List<WrapperData>();
        Integer itemCounter = 1;

        for (Warehouse_Inventory__c inv : invList) {
            results.add(new WrapperData(
                inv.Id,
                itemCounter++,
                inv.Price_Book_Entry__r.Product__r.Name,
                inv.Quantity__c,
                inv.Price_Book_Entry__r.List_Price__c,
                inv.Result_Stocks__c,
                inv.issue_Date__c
            ));
        }
        return results;
    }


    // ========================================
    //  INLINE UPDATE INVENTORY
    // ========================================
    @AuraEnabled
    public static void updateInventory(List<Warehouse_Inventory__c> updates) {
        update updates;
    }


    // ========================================
    //  FETCH PRODUCT LIST (FOR MODAL PICKLIST)
    // ========================================
    @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> getProductList() {
        List<PricebookEntry> pbeList = [
            SELECT Id,
                   Product2Id,
                   Product2.Name,
                   UnitPrice
            FROM PricebookEntry
            WHERE IsActive = true AND Product2.Family != null
            LIMIT 500
        ];

        List<ProductWrapper> result = new List<ProductWrapper>();

        for (PricebookEntry pbe : pbeList) {
            result.add(new ProductWrapper(
                pbe.Id,
                pbe.Product2Id,
                pbe.Product2.Name,
                pbe.UnitPrice
            ));
        }
        return result;
    }

    public class ProductWrapper {
        @AuraEnabled public String pricebookEntryId;
        @AuraEnabled public String productId;
        @AuraEnabled public String productName;
        @AuraEnabled public Decimal unitPrice;

        public ProductWrapper(String pbeId, String prodId, String name, Decimal price){
            pricebookEntryId = pbeId;
            productId = prodId;
            productName = name;
            unitPrice = price;
        }
    }


    // ========================================
    //  CREATE A NEW INVENTORY RECORD
    // ========================================
   @AuraEnabled
public static void createInventoryRecord(Map<String, Object> rec) {
    System.debug('Incoming record: ' + rec);

    Warehouse_Inventory__c w = new Warehouse_Inventory__c();

    // Product Id
    if (rec.containsKey('productId') && rec.get('productId') != null && String.valueOf(rec.get('productId')) != '') {
        w.Products__c = (String) rec.get('productId');
    } else {
        throw new AuraHandledException('Product is required.');
    }

    // Pricebook Entry Id
    if (rec.containsKey('pricebookEntryId') && rec.get('pricebookEntryId') != null && String.valueOf(rec.get('pricebookEntryId')) != '') {
        w.Price_Book_Entry__c = (String) rec.get('pricebookEntryId');
    } else {
        throw new AuraHandledException('Pricebook Entry is required.');
    }

    // Quantity
    if (rec.containsKey('qty') && rec.get('qty') != null && String.valueOf(rec.get('qty')) != '') {
        try {
            w.Quantity__c = Decimal.valueOf(String.valueOf(rec.get('qty')));
        } catch (Exception e) {
            throw new AuraHandledException('Quantity must be a valid number.');
        }
    } else {
        w.Quantity__c = 0;
    }

    // Current Stock
    if (rec.containsKey('currentStock') && rec.get('currentStock') != null && String.valueOf(rec.get('currentStock')) != '') {
        try {
            w.Result_Stocks__c = Decimal.valueOf(String.valueOf(rec.get('currentStock')));
        } catch (Exception e) {
            w.Result_Stocks__c = 0;
        }
    } else {
        w.Result_Stocks__c = 0;
    }

    // Issue Date
    if (rec.containsKey('issueDate') && rec.get('issueDate') != null && String.valueOf(rec.get('issueDate')) != '') {
        try {
            w.issue_Date__c = Date.valueOf(String.valueOf(rec.get('issueDate')));
        } catch (Exception e) {
            throw new AuraHandledException('Issue Date must be in YYYY-MM-DD format.');
        }
    } else {
        throw new AuraHandledException('Issue Date is required.');
    }

    try {
        insert w;
    } catch (DmlException e) {
        System.debug('Error inserting Warehouse Inventory: ' + e.getMessage());
        throw new AuraHandledException('Unable to create inventory record. Please check required fields or duplicates.');
    }
}





    // ========================================
    //  WRAPPER CLASS FOR TABLE DISPLAY
    // ========================================
    public class WrapperData {
        @AuraEnabled public String recordId;
        @AuraEnabled public Integer itemNo;
        @AuraEnabled public String productName;
        @AuraEnabled public Decimal qty;
        @AuraEnabled public Decimal listPrice;
        @AuraEnabled public Decimal currentStock;
        @AuraEnabled public Date issueDate;

        public WrapperData(
            Id id,
            Integer itemNo,
            String productName,
            Decimal qty,
            Decimal listPrice,
            Decimal currentStock,
            Date issueDate
        ) {
            this.recordId = id;
            this.itemNo = itemNo;
            this.productName = productName;
            this.qty = qty;
            this.listPrice = listPrice;
            this.currentStock = currentStock;
            this.issueDate = issueDate;
        }
    }
}