/**
    * @File Name : VisitorPassController.cls
    * @Description :
    * @Author :
    * @Last Modified By :
    * @Last Modified On : November 26, 2025
    * @Modification Log :
    *==============================================================================
    * Ver | Date | Author | Modification
    *==============================================================================
    * 1.0 | November 26, 2025 |   | Initial Version
    **/
    
    public with sharing class VisitorPassController {
        
        public class PhotoWrapper {
            @AuraEnabled public String fileName;
            @AuraEnabled public String contentType; // e.g., 'image/jpeg' or 'image/png'
            @AuraEnabled public String base64Data;  // raw base64, no data URL prefix
        }
        
        @AuraEnabled
        public static Permit_Gate_Pass__c createGatePass( String companyName,String visitorName,String mobile,String purpose,PhotoWrapper photo) {
            Permit_Gate_Pass__c newPass = new Permit_Gate_Pass__c();
            //newPass.Company_Name__c = companyName;
            newPass.Visitor_Name__c = visitorName;
            newPass.Visitor_Mobile_Number__c = mobile;
            newPass.Purpose_to_Visit__c = purpose;
            
            insert newPass;
            
           
    if (photo != null && !String.isBlank(photo.fileName) && !String.isBlank(photo.base64Data)) {
                try {
                    // (Optional) basic contentType guard
                    if (!String.isBlank(photo.contentType) &&
                        !('image/jpeg,image/jpg,image/png'.contains(photo.contentType.toLowerCase()))) {
                        // Skip unsupported types silently or throw error; here we skip
                        System.debug(LoggingLevel.WARN, 'Unsupported content type: ' + photo.contentType);
                    } else {
                        Blob body = EncodingUtil.base64Decode(photo.base64Data);
    
                        // Quick size guard: typical safe payload under ~4–5MB due to heap & base64 overhead
                        // Adjust if needed; max heap is 6MB in synchronous contexts.
                        Integer maxBytes = 4 * 1024 * 1024; // 4 MB safety buffer
                        if (body.size() > maxBytes) {
                            System.debug(LoggingLevel.WARN, 'Image too large; skipping upload. Size: ' + body.size());
                        } else {
                            ContentVersion cv = new ContentVersion();
                            cv.Title = photo.fileName.contains('.')
                                ? photo.fileName.substringBeforeLast('.')
                                : photo.fileName;
                            cv.PathOnClient = photo.fileName;
                            cv.VersionData = body;
                            // This auto-creates ContentDocument and ContentDocumentLink to the record
                            cv.FirstPublishLocationId = newPass.Id;
                            insert cv;
                        }
                    }
                } catch (Exception ex) {
                    // Log and continue; the pass was created successfully
                    System.debug(LoggingLevel.ERROR, 'Failed to attach photo: ' + ex.getMessage());
                }
            }
    
            
            return newPass;
        }
    }