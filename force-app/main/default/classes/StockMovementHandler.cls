public class StockMovementHandler {

    // BEFORE INSERT → calculate Result_Stocks__c
    public static void updateResultField(List<Warehouse_Inventory__c> newRecords) {

        // 1. Collect all Price Book Entry IDs
        Set<Id> pbeIds = new Set<Id>();
        for (Warehouse_Inventory__c rec : newRecords) {
            if (rec.Price_Book_Entry__c != null) {
                pbeIds.add(rec.Price_Book_Entry__c);
            }
        }
        if (pbeIds.isEmpty()) return;

        // 2. Query Current Stocks for all Price Book Entries
        Map<Id, Price_Book_entry__c> pbeMap = new Map<Id, Price_Book_entry__c>(
            [SELECT Id, Current_Stocks__c FROM Price_Book_entry__c WHERE Id IN :pbeIds]
        );

        // 3. Map to track latest stock in memory
        Map<Id, Decimal> latestStockMap = new Map<Id, Decimal>();
        for(Id pid : pbeMap.keySet()) {
            latestStockMap.put(pid, pbeMap.get(pid).Current_Stocks__c == null ? 0 : pbeMap.get(pid).Current_Stocks__c);
        }

        // 4. Calculate Result_Stocks__c for each Warehouse Inventory record
        for(Warehouse_Inventory__c rec : newRecords) {
            if(rec.Price_Book_Entry__c == null) continue;

            Decimal stock = latestStockMap.get(rec.Price_Book_Entry__c);
            Decimal qty = rec.Quantity__c == null ? 0 : rec.Quantity__c;
            Decimal newStock;

            if(rec.Type__c == 'Used') {
                newStock = stock - qty;
                if(newStock < 0) newStock = 0; // Only clamp if negative
            } else if(rec.Type__c == 'Added') {
                newStock = stock + qty;
            } else {
                newStock = stock;
            }

            rec.Result_Stocks__c = newStock;
            latestStockMap.put(rec.Price_Book_Entry__c, newStock);
        }
    }

    // AFTER INSERT → update Current_Stocks__c on Price Book Entry
    public static void updateStock(List<Warehouse_Inventory__c> newRecords) {

        // 1. Collect all Price Book Entry IDs
        Set<Id> pbeIds = new Set<Id>();
        for (Warehouse_Inventory__c rec : newRecords) {
            if(rec.Price_Book_Entry__c != null) {
                pbeIds.add(rec.Price_Book_Entry__c);
            }
        }
        if(pbeIds.isEmpty()) return;

        // 2. Query Price Book Entry stock
        Map<Id, Price_Book_entry__c> pbeMap = new Map<Id, Price_Book_entry__c>(
            [SELECT Id, Current_Stocks__c FROM Price_Book_entry__c WHERE Id IN :pbeIds]
        );

        // 3. Track latest stock in memory
        Map<Id, Decimal> latestStockMap = new Map<Id, Decimal>();
        for(Id pid : pbeMap.keySet()) {
            latestStockMap.put(pid, pbeMap.get(pid).Current_Stocks__c == null ? 0 : pbeMap.get(pid).Current_Stocks__c);
        }

        // 4. Apply stock changes from Warehouse Inventory
        for(Warehouse_Inventory__c rec : newRecords) {
            if(rec.Price_Book_Entry__c == null) continue;

            Decimal stock = latestStockMap.get(rec.Price_Book_Entry__c);
            Decimal qty = rec.Quantity__c == null ? 0 : rec.Quantity__c;
            Decimal newStock;

            if(rec.Type__c == 'Used') {
                newStock = stock - qty;
                if(newStock < 0) newStock = 0; // Only clamp if negative
            } else if(rec.Type__c == 'Added') {
                newStock = stock + qty;
            } else {
                newStock = stock;
            }

            latestStockMap.put(rec.Price_Book_Entry__c, newStock);
        }

        // 5. Update Price Book Entry records
        List<Price_Book_entry__c> pbeToUpdate = new List<Price_Book_entry__c>();
        for(Id pid : latestStockMap.keySet()) {
            Price_Book_entry__c pbe = pbeMap.get(pid);
            pbe.Current_Stocks__c = latestStockMap.get(pid);
            pbeToUpdate.add(pbe);
        }

        if(!pbeToUpdate.isEmpty()) {
            update pbeToUpdate;
        }
    }
}