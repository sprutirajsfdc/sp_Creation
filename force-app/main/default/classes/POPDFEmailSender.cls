public class POPDFEmailSender {

    @InvocableMethod(label='Send PO Email with PDF')
    public static void sendPOEmail(List<Id> poIds) {
        if(poIds == null || poIds.isEmpty()) return;

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        // Query all POs with Vendor info
        List<Purchase_Order__c> poList = [
            SELECT Id, Name, CreatedDate, Total_Amount__c, Vendor__c,
                   Vendor__r.Name, Vendor__r.BillingStreet, Vendor__r.BillingCity,
                   Vendor__r.BillingState, Vendor__r.BillingPostalCode, Vendor__r.Phone
            FROM Purchase_Order__c
            WHERE Id IN :poIds
        ];

        for(Purchase_Order__c po : poList){
            try {
                // Generate PDF from Visualforce page
                PageReference pdfPage = Page.PO; // Replace with your VF page name
                pdfPage.getParameters().put('id', po.Id);
                Blob pdfBlob = pdfPage.getContentAsPDF();

                // Create attachment
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('PO_' + po.Name + '.pdf');
                attachment.setBody(pdfBlob);
                attachment.setContentType('application/pdf');

                // Create email
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] {'vendor@example.com'}); // Replace with Vendor email dynamically if needed
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

                emails.add(mail);
            } catch(Exception e){
                System.debug('Error sending email for PO ' + po.Name + ': ' + e.getMessage());
            }
        }

        // Send all emails
        if(!emails.isEmpty()){
            Messaging.sendEmail(emails);
        }
    }
}