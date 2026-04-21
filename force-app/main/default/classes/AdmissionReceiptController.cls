public class AdmissionReceiptController {
    
    public Academic_Course__c courseRec { get; set; }
    public String studentPhotoUrl { get; set; }

    // =========================
    // Standard VF Constructor
    // =========================
    public AdmissionReceiptController(ApexPages.StandardController controller) {
        Id recordId = controller.getId();
        loadData(recordId);
    }

    // =========================
    // Optional URL Constructor
    // =========================
    public AdmissionReceiptController() {
        Id recordId = ApexPages.currentPage().getParameters().get('id');
        loadData(recordId);
    }

    // =========================
    // Data Loader
    // =========================
    private void loadData(Id recordId) {
        if (recordId == null) return;

        courseRec = [
            SELECT Id, Tution_Fees__c, Course_Code__c, Start_Date__c, Department__c,
                   Admission_Fees__c, End_Date__c, Batch_Time__c, Scholrship_Discount__c,
                   Course_Type__c, Student__r.Roll_Number__c, Student__r.Name,
                   Total_Fees__c, Duration__c, Name, Student__c
            FROM Academic_Course__c
            WHERE Id = :recordId
            LIMIT 1
        ];

        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :courseRec.Student__c
            ORDER BY SystemModstamp DESC
            LIMIT 1
        ];

        if (!links.isEmpty()) {
            studentPhotoUrl = '/sfc/servlet.shepherd/document/download/' 
                            + links[0].ContentDocumentId;
        }
    }

    // =========================
    // FORMATTED DATE PROPERTY
    // =========================
    public String startDateFormatted {
        get {
            return formatDate(courseRec.Start_Date__c);
        }
    }

    public String endDateFormatted {
        get {
            return formatDate(courseRec.End_Date__c);
        }
    }

    // =========================
    // DATE FORMATTER LOGIC
    // =========================
    public String formatDate(Date d) {
        if (d == null) return '';

        Integer day = d.day();
        String suffix;

        if (day == 1 || day == 21 || day == 31) suffix = 'st';
        else if (day == 2 || day == 22) suffix = 'nd';
        else if (day == 3 || day == 23) suffix = 'rd';
        else suffix = 'th';

        DateTime dt = DateTime.newInstance(d, Time.newInstance(0, 0, 0, 0));

        String monthName = dt.format('MMMM');
        String year = String.valueOf(d.year());

        return day + suffix + ' ' + monthName + ' ' + year;
    }
}