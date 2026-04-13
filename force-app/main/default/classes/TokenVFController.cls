public with sharing class TokenVFController {

    public Token__c token { get; set; }
    public String currentTime { get; set; }

    public TokenVFController() {

        Id tokenId = ApexPages.currentPage().getParameters().get('id');

        token = [
            SELECT Id, Token_Number__c,
                   Counter__r.Name,
                   Counter__r.Counter_Number__c
            FROM Token__c
            WHERE Id = :tokenId
        ];

        currentTime = System.now().format('dd/MM/yyyy hh:mm a');
    }
}