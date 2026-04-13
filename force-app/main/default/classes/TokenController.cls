public with sharing class TokenController {

    @AuraEnabled(cacheable=true)
    public static List<Account> getServiceCounters() {
        return [
            SELECT Id, Name, Counter_Number__c
            FROM Account 
            WHERE Type = 'Service'
            ORDER BY Name
        ];
    }

    @AuraEnabled
    public static Token__c generateToken(Id counterId) {

        Integer nextNumber = 1;

        List<Token__c> tokensToday = [
            SELECT Token_Number__c 
            FROM Token__c 
            WHERE CreatedDate = TODAY
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (!tokensToday.isEmpty()) {
            String lastToken = tokensToday[0].Token_Number__c;

            if (lastToken != null && lastToken.contains('-')) {
                String numPart = lastToken.substringAfter('-');
                nextNumber = Integer.valueOf(numPart) + 1;
            }
        }

        String numberStr = String.valueOf(nextNumber);
        while (numberStr.length() < 3) {
            numberStr = '0' + numberStr;
        }

        String tokenNumber = 'T-' + numberStr;

        Token__c token = new Token__c();
        token.Token_Number__c = tokenNumber;
        token.Counter__c = counterId;

        insert token;

        // ✅ Return Counter Name + Counter Number
        return [
            SELECT Id, Token_Number__c,
                   Counter__r.Name,
                   Counter__r.Counter_Number__c
            FROM Token__c
            WHERE Id = :token.Id
        ];
    }
     @AuraEnabled
    public static Token__c assignTokenToUser(Id tokenId, Id userId) {
        
        Token__c token = [
            SELECT Id, Status__c, Ownerid
            FROM Token__c
            WHERE Id = :tokenId
            LIMIT 1
        ];
        
        token.Ownerid = userId;
        token.Status__c = 'Serving'; 
        
        update token;
        
        return token;
    }
    @AuraEnabled(cacheable=true)
public static List<User> getUsers() {
    return [SELECT Id, Name FROM User WHERE IsActive = TRUE ORDER BY Name];
}
}