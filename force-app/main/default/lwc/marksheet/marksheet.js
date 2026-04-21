import { LightningElement, wire, track } from 'lwc';
import getStudentMarksheet from '@salesforce/apex/StudentMarksheetController.getStudentMarksheet';
import getContactImage from '@salesforce/apex/StudentMarksheetController.getContactImage';

export default class StudentMarksheet extends LightningElement {

    // 🔥 Hardcoded for testing
    recordId = '003dM00001tMgtGQAS';

    @track student;
    imageUrl;

    // 🔹 Contact Image
    @wire(getContactImage, { contactId: '$recordId' })
    wiredImage({ data, error }) {
        if (data) {
            this.imageUrl = data;
        }
    }

    // 🔹 Student Marksheet
    @wire(getStudentMarksheet, { studentId: '$recordId' })
    wiredData({ data, error }) {
        if (data) {

            this.student = {
                ...data,
                courses: data.courses.map(course => ({
                    ...course,
                    subjects: course.subjects.map(sub => ({
                        ...sub,
                        marks: 0,
                        grade: ''
                    }))
                })),
                total: 0,
                percentage: 0,
                division: '',
                grade: ''
            };

        } else if (error) {
            console.error(error);
        }
    }

    // 🔹 Handle Marks Change (IMPORTANT FIX)
    handleMarksChange(event) {

        const subjectName = event.target.dataset.subject;
        const courseName = event.target.dataset.course;
        const value = parseFloat(event.target.value) || 0;

        this.student.courses.forEach(course => {

            if (course.courseName === courseName) {

                course.subjects.forEach(sub => {
                    if (sub.subjectName === subjectName) {
                        sub.marks = value;
                        sub.grade = this.getGrade(value);
                    }
                });

            }
        });

        this.calculateResult();
        this.student = { ...this.student };
    }

    // 🔹 Calculation (ALL COURSES + SUBJECTS)
    calculateResult() {

    let total = 0;
    let count = 0;

    this.student.courses.forEach(course => {
        course.subjects.forEach(sub => {
            total += sub.marks || 0;
            count++;
        });
    });

    let percentage = count > 0 ? total / count : 0;

    this.student.total = total;
    this.student.percentage = percentage.toFixed(1);

    // 🔥 PASS / FAIL STATUS
    if (percentage >= 40) {
        this.student.status = 'PASS';
    } else {
        this.student.status = 'FAIL';
    }

    // Division
    if (percentage >= 80) {
        this.student.division = 'First Division';
    } else if (percentage >= 50) {
        this.student.division = 'Second Division';
    } else if (percentage >= 40) {
        this.student.division = 'Third Division';
    } else {
        this.student.division = 'Fail';
    }

    this.student.grade = this.getGrade(percentage);
}

    getGrade(score) {
        if (score >= 80) return 'A+';
        if (score >= 70) return 'A';
        if (score >= 60) return 'B';
        if (score >= 50) return 'C';
        if (score >= 40) return 'D';
        return 'F';
    }
}