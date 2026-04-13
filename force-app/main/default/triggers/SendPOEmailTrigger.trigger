trigger SendPOEmailTrigger on Purchase_Order__c (after insert, after update) {

    List<Id> poIdsToSend = new List<Id>();

    // After Insert
    if(Trigger.isInsert){
        poIdsToSend.addAll(Trigger.newMap.keySet());
    }

    // After Update: only if Status__c changed to Approved
    if(Trigger.isUpdate){
        for(Purchase_Order__c poNew : Trigger.new){
            Purchase_Order__c poOld = Trigger.oldMap.get(poNew.Id);
            if(poOld.Status__c != 'Approved' && poNew.Status__c != null && poNew.Status__c.trim() == 'Approved'){
                poIdsToSend.add(poNew.Id);
            }
        }
    }

    if(!poIdsToSend.isEmpty()){
        POPDFEmailSender.sendPOEmail(poIdsToSend);
    }
}