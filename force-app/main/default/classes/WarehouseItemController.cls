/**
* @File Name : WarehouseItemController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : November 19, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | November 19, 2025 |   | Initial Version
**/

public with sharing class WarehouseItemController {
    @AuraEnabled(cacheable=true)
    public static Asset getItem(String barcodeValue) {
        return [
            SELECT Id, Name, Quantity, Status, SerialNumber
            FROM Asset
            WHERE SerialNumber = :barcodeValue
            LIMIT 1
        ];
    }
}