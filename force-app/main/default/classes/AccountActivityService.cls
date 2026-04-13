public without sharing class AccountActivityService {

    @AuraEnabled(cacheable=true)
    public static AccountActivityData getAccountSummary() {
        // Get the current User Id
        Id currentUserId = UserInfo.getUserId();

        // 1. Get the total number of accounts owned by the current user
        Integer totalAccounts = [SELECT COUNT() FROM Account WHERE OwnerId = :currentUserId];

        // 2. Determine activity counts (You would adjust this logic based on your org's specific activity tracking fields/objects)
        
        // For demonstration, we use the counts from your image (13 Total, 0 Upcoming, 0 Past, 13 No Activity).
        // In a real scenario, you'd calculate these by querying Activities (Tasks/Events)
        // or a custom 'Last Activity Date' field on the Account.

        Integer upcomingActivityCount = 0; // Example: Count of Events/Tasks with DueDate > TODAY
        Integer pastActivityCount = 0;     // Example: Count of completed Tasks/Events
        Integer noActivityCount = totalAccounts; // Calculated: Total - Upcoming - Past

        // Return the data structure
        return new AccountActivityData(
            totalAccounts,
            upcomingActivityCount,
            pastActivityCount,
            noActivityCount
        );
    }

    // Inner class to structure the data sent back to the LWC
    public class AccountActivityData {
        @AuraEnabled public Integer totalAccounts { get; set; }
        @AuraEnabled public Integer upcomingActivity { get; set; }
        @AuraEnabled public Integer pastActivity { get; set; }
        @AuraEnabled public Integer noActivity { get; set; }

        public AccountActivityData(Integer total, Integer upcoming, Integer past, Integer no) {
            this.totalAccounts = total;
            this.upcomingActivity = upcoming;
            this.pastActivity = past;
            this.noActivity = no;
        }
    }
}