public with sharing class GatePassController {
    
    @AuraEnabled
    public static Id createGatePass(Customer gp) {
        insert gp;
        return gp.Id;
    }
    
}