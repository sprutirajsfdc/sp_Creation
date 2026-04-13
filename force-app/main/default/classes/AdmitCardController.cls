/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : AdmitCardController
 * Author          : Sprutiraj
 * Created Date    : Apr 13, 2026
 * Last Modified By: <Sprutiraj>
 * Last Modified On: Apr 13, 2026
 * Description     : This class implements for to creae the Admit card for studnet 
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Apr 13, 2026  │ Sprutiraj │ V1.0
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

public with sharing class AdmitCardController {

    public Booking__c booking {get; set;}
    public String studentPhotoUrl {get; set;}
    
    public AdmitCardController() {
        // Assume you pass the Booking ID as a URL parameter like ?id=a00...
        Id bookingId = ApexPages.currentPage().getParameters().get('id');
        
        if (bookingId != null) {
            // 1. Query dynamic data based on your requirements
            booking = [SELECT Id, Name, 
                              Student__c, 
                              Student__r.Name,Student__r.Roll_Number__c,
                              Exam__r.Name,
                              Exam__r.Subject__c,Exam__r.Subject_Code__c,
                              Exam__r.Date__c, // Need this for the view
                              Seat_Allocation__r.Exam_Center__r.Name,
                              Seat_Number__c,
                              Status__c
                       FROM Booking__c
                       WHERE Id = :bookingId LIMIT 1];           
            studentPhotoUrl = '/profilephoto/005/F'; // Default placeholder
            
            if(booking.Student__c != null) {
                List<ContentDocumentLink> links = [SELECT ContentDocumentId 
                                                  FROM ContentDocumentLink 
                                                  WHERE LinkedEntityId = :booking.Student__r.Id 
                                                  ORDER BY ContentDocument.CreatedDate DESC 
                                                  LIMIT 1];
                
                if (!links.isEmpty()) {
                    List<ContentVersion> versions = [SELECT Id 
                                                     FROM ContentVersion 
                                                     WHERE ContentDocumentId = :links[0].ContentDocumentId 
                                                     AND FileType IN ('PNG', 'JPG', 'JPEG') 
                                                     AND IsLatest = true LIMIT 1];
                    
                    if (!versions.isEmpty()) {
                        studentPhotoUrl = '/sfc/servlet.shepherd/version/download/' + versions[0].Id;
                    }
                }
            }
        }
    }
}