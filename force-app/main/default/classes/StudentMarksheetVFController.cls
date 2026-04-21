public with sharing class StudentMarksheetVFController {

    // ================= WRAPPERS =================
    public class SubjectWrapper {
        public String subjectName { get; set; }
        public Integer theoryMark { get; set; }
        public Integer practicalMark { get; set; }
        public Integer totalMark { get; set; }
    }

    public class CourseWrapper {
        public String courseName { get; set; }
        public String department { get; set; }
        public List<SubjectWrapper> subjects { get; set; }
    }

    public class StudentWrapper {
        public Id studentId { get; set; }
        public String studentName { get; set; }
        public String rollNumber { get; set; }
        public List<CourseWrapper> courses { get; set; }

        public Integer grandTotal { get; set; }
        public Integer maxTotal { get; set; }
        public Decimal percentage { get; set; }
    }

    public StudentWrapper studentData { get; set; }

    // ================= CONSTRUCTOR =================
    public StudentMarksheetVFController() {
        Id studentIdParam = ApexPages.currentPage().getParameters().get('id');
        if (studentIdParam != null) {
            studentData = getStudentMarksheet(studentIdParam);
        }
    }

    // ================= GETTERS =================
    public String getStudentName() {
        return studentData != null ? studentData.studentName : '';
    }

    public String getRollNumber() {
        return studentData != null ? studentData.rollNumber : '';
    }

    public List<CourseWrapper> getCourses() {
        return studentData != null ? studentData.courses : new List<CourseWrapper>();
    }

    public Integer getGrandTotal() {
        return studentData != null ? studentData.grandTotal : 0;
    }

    public Integer getMaxTotal() {
        return studentData != null ? studentData.maxTotal : 0;
    }

    public Decimal getPercentage() {
        return studentData != null ? studentData.percentage : 0;
    }

    public Id getStudentId() {
        return studentData != null ? studentData.studentId : null;
    }
    public String getFormattedDate() {
    Date d = Date.today();
    return String.valueOf(d.day()) + ' ' +
           String.valueOf(d.month()) + ' ' +
           String.valueOf(d.year());
}

    // ================= CORE LOGIC =================
    public static StudentWrapper getStudentMarksheet(Id studentId) {

        List<Academic_Course__c> records = [
            SELECT Id,
                   Course_Code__c,
                   Department__c,
                   Student__r.Name,
                   Student__r.Roll_Number__c,
                   (SELECT Id, Subject__c, Theroy_mark__c, Practical_mark__c
                    FROM Exams__r)
            FROM Academic_Course__c
            WHERE Student__c = :studentId
        ];

        if (records.isEmpty()) return null;

        StudentWrapper student = new StudentWrapper();
        student.studentId = studentId;
        student.studentName = records[0].Student__r.Name;
        student.rollNumber = records[0].Student__r.Roll_Number__c;
        student.courses = new List<CourseWrapper>();

        Integer totalSum = 0;
        Integer subjectCount = 0;

        for (Academic_Course__c rec : records) {

            CourseWrapper cw = new CourseWrapper();
            cw.courseName = rec.Course_Code__c;
            cw.department = rec.Department__c;
            cw.subjects = new List<SubjectWrapper>();

            if (rec.Exams__r != null) {
                for (Exam__c ex : rec.Exams__r) {

                    SubjectWrapper sw = new SubjectWrapper();
                    sw.subjectName = ex.Subject__c;

                    Integer theory = (ex.Theroy_mark__c == null) ? 0 : Integer.valueOf(ex.Theroy_mark__c);
                    Integer practical = (ex.Practical_mark__c == null) ? 0 : Integer.valueOf(ex.Practical_mark__c);

                    sw.theoryMark = theory;
                    sw.practicalMark = practical;
                    sw.totalMark = theory + practical;

                    totalSum += sw.totalMark;
                    subjectCount++;

                    cw.subjects.add(sw);
                }
            }

            student.courses.add(cw);
        }

        // ================= TOTAL CALCULATION =================
        student.grandTotal = totalSum;
        student.maxTotal = subjectCount * 100;

        if (student.maxTotal > 0) {
            student.percentage = (Decimal.valueOf(totalSum) / student.maxTotal) * 100;
        } else {
            student.percentage = 0;
        }

        return student;
    }

    // ================= IMAGE =================
    public String getContactImage() {

        if (studentData == null) return null;

        List<ContentDocumentLink> docs = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :studentData.studentId
            ORDER BY ContentDocument.CreatedDate DESC
            LIMIT 1
        ];

        if (docs.isEmpty()) return null;

        ContentVersion cv = [
            SELECT Id
            FROM ContentVersion
            WHERE ContentDocumentId = :docs[0].ContentDocumentId
            AND IsLatest = true
            LIMIT 1
        ];

        return '/sfc/servlet.shepherd/version/download/' + cv.Id;
    }
}