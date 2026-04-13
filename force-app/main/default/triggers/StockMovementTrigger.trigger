trigger StockMovementTrigger on Warehouse_Inventory__c (before insert, after insert) {

   // BEFORE INSERT: calculate Result_Stocks__c for each record
    if (Trigger.isBefore && Trigger.isInsert) {
        StockMovementHandler.updateResultField(Trigger.new);
    }

    // AFTER INSERT: update PricebookEntry Current_Stocks__c
    if (Trigger.isAfter && Trigger.isInsert) {
        StockMovementHandler.updateStock(Trigger.new);
    }
}