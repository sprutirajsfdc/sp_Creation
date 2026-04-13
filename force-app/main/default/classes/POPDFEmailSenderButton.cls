public with sharing class POPDFEmailSenderButton {

    @AuraEnabled
    public static String sendPOEmail(Id poId) {
        try {
            // Query PO and Vendor info
            Purchase_Order__c po = [
                SELECT Id, Name, CreatedDate, Total_Amount__c, Vendor__c,
                       Vendor__r.Name
                FROM Purchase_Order__c
                WHERE Id = :poId
                LIMIT 1
            ];

            // Generate PDF from VF Page
            PageReference pdfPage = Page.PO; // Replace with your VF page name
            pdfPage.getParameters().put('id', po.Id);
            Blob pdfBlob = pdfPage.getContentAsPDF();

            // Create Attachment
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('PO_' + po.Name + '.pdf');
            attachment.setBody(pdfBlob);
            attachment.setContentType('application/pdf');

            // Create Email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           mail.setToAddresses(new String[] {'sprutiraj21@gmail.com'}); // <-- added email
            mail.setSubject('Purchase Order: ' + po.Name);
            mail.setPlainTextBody(
                'Dear ' + po.Vendor__r.Name + ',\n\n' +
                'Please find attached your Purchase Order PDF.\n\n' +
                'PO Number: ' + po.Name + '\n' +
                'Date: ' + po.CreatedDate.format() + '\n' +
                'Total Amount: ₹' + po.Total_Amount__c + '\n\n' +
                'Regards,\nSales Team'
            );
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachment});

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            return 'PO email sent successfully to ';

        } catch(Exception e){
            return 'Error sending PO email: ' + e.getMessage();
        }
    }
}