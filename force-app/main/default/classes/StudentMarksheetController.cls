public with sharing class StudentMarksheetController {

    public class SubjectWrapper {
        @AuraEnabled public String subjectName;
        @AuraEnabled public Integer marks;
    }

    public class CourseWrapper {
        @AuraEnabled public String courseName;
        @AuraEnabled public String department;
        @AuraEnabled public List<SubjectWrapper> subjects;
    }

    public class StudentWrapper {
        @AuraEnabled public Id studentId;
        @AuraEnabled public String studentName;
        @AuraEnabled public String rollNumber;
        @AuraEnabled public List<CourseWrapper> courses;
    }

    @AuraEnabled(cacheable=true)
    public static StudentWrapper getStudentMarksheet(Id studentId) {

        List<Academic_Course__c> records = [
            SELECT Id,
                   Course_Code__c,
                   Department__c,
                   Student__r.Name,
                   Student__r.Roll_Number__c,

                   /* 🔥 CHILD RELATIONSHIP QUERY */
                   (SELECT Id, Subject__c FROM Exams__r)

            FROM Academic_Course__c
            WHERE Student__c = :studentId
        ];

        if (records.isEmpty()) return null;

        StudentWrapper student = new StudentWrapper();
        student.studentId = studentId;
        student.studentName = records[0].Student__r.Name;
        student.rollNumber = records[0].Student__r.Roll_Number__c;
        student.courses = new List<CourseWrapper>();

        for (Academic_Course__c rec : records) {

            CourseWrapper cw = new CourseWrapper();
            cw.courseName = rec.Course_Code__c;
            cw.department = rec.Department__c;
            cw.subjects = new List<SubjectWrapper>();

            // 🔥 LOOP CHILD EXAMS
            if (rec.Exams__r != null) {
                for (Exam__c ex : rec.Exams__r) {

                    SubjectWrapper sw = new SubjectWrapper();
                    sw.subjectName = ex.Subject__c;
                    sw.marks = 0;

                    cw.subjects.add(sw);
                }
            }

            student.courses.add(cw);
        }

        return student;
    }

    @AuraEnabled(cacheable=true)
public static String getContactImage(Id contactId) {

    List<ContentDocumentLink> docs = [
        SELECT ContentDocumentId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :contactId
        ORDER BY ContentDocument.CreatedDate DESC
        LIMIT 1
    ];

    if (docs.isEmpty()) {
        return null;
    }

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