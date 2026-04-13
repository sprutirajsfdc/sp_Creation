public with sharing class GatePassPDFController {
    public Customer gp { get; set; }

    public GatePassPDFController() {
        String id = ApexPages.currentPage().getParameters().get('id');
        gp = [SELECT Id, Product__c, Type__c, Quantity__c,
              Person_Name__c, Description__c, In_time__c
              FROM Customer WHERE Id = :id LIMIT 1];
    }
}