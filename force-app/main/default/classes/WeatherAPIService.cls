public with sharing class WeatherAPIService {
@future(callout=true)
    public static void fetchWeatherData(String cityName, Id recordId) {
        try {
            // API endpoint
            String endpoint = 'https://api.openweathermap.org/data/2.5/weather?q=' + cityName + '&appid=6fc312be552fc2e0b3b9c2dc4b3a6b9a';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');

// Make the callout
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                // Parse the JSON response
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> mainData = (Map<String, Object>) responseBody.get('main');
                Decimal temperature = (Decimal) mainData.get('temp');
                // Update Salesforce record
                Weather_Temperature__c recordToUpdate = [SELECT Id, Name,City__c,Temp__c FROM Weather_Temperature__c WHERE Id = :recordId];
                recordToUpdate.Temp__c = temperature;
                update recordToUpdate;
            } else {
                System.debug('Error in API call: ' + response.getStatus());
            }
        } catch (Exception e) {
            System.debug('Exception during API call: ' + e.getMessage());
        }
    }
}