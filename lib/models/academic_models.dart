class Subject {
  final String name;
  final double marks;
  final double creditHours;

  Subject({required this.name, required this.marks, required this.creditHours});

  // Convert marks into letter grade

  String get letterGrade {
    if (marks >= 85) return 'A+';
    if (marks >= 80) return 'A-';
    if (marks >= 75) return 'B+';
    if (marks >= 70) return 'B';
    if (marks >= 65) return 'B-';
    if (marks >= 61) return 'C+';
    if (marks >= 58) return 'C';
    if (marks >= 55) return 'C-';
    if (marks >= 50) return 'D';
    return 'F';
  }

  // Convert marks into grade point

  double get gradePoint {
    if (marks >= 85) return 4.00;
    if (marks >= 80) return 3.70;
    if (marks >= 75) return 3.30;
    if (marks >= 70) return 3.00;
    if (marks >= 65) return 2.70;
    if (marks >= 61) return 2.30;
    if (marks >= 58) return 2.00;
    if (marks >= 55) return 1.70;
    if (marks >= 50) return 1.00;
    return 0.00;
  }

  double get qualityPoints {
    return gradePoint * creditHours;
  }
}

// SEMESTER / GPA RESULT
class SemesterResult {
  final List<Subject> subjects;

  SemesterResult({required this.subjects});

  double get totalCredits {
    return subjects.fold(0.0, (sum, subject) => sum + subject.creditHours);
  }

  double get totalQualityPoints {
    return subjects.fold(0.0, (sum, subject) => sum + subject.qualityPoints);
  }

  double get gpa {
    if (totalCredits == 0) return 0.0;

    return totalQualityPoints / totalCredits;
  }

  // Overall GPA grade
  String get letterGrade {
    if (gpa >= 3.70) return 'A+';
    if (gpa >= 3.30) return 'A';
    if (gpa >= 3.00) return 'B+';
    if (gpa >= 2.70) return 'B';
    if (gpa >= 2.30) return 'C+';
    if (gpa >= 2.00) return 'C';
    if (gpa >= 1.70) return 'C-';
    if (gpa >= 1.00) return 'D';
    return 'F';
  }
}

// SEMESTER DATA

class SemesterData {
  final String name;

  double? gpa;
  double? creditHours;

  SemesterData({required this.name, this.gpa, this.creditHours});

  bool get hasData {
    return gpa != null &&
        creditHours != null &&
        gpa! >= 0 &&
        gpa! <= 4 &&
        creditHours! > 0;
  }
}

// CGPA RESULT

class CgpaResult {
  final List<SemesterData> semesters;

  CgpaResult({required this.semesters});

  double get totalCredits {
    return semesters.fold(
      0.0,
      (sum, semester) => sum + (semester.creditHours ?? 0),
    );
  }

  double get totalQualityPoints {
    return semesters.fold(
      0.0,
      (sum, semester) =>
          sum + ((semester.gpa ?? 0) * (semester.creditHours ?? 0)),
    );
  }

  double get cgpa {
    if (totalCredits == 0) return 0.0;

    return totalQualityPoints / totalCredits;
  }

  // CGPA → Letter Grade

  String get letterGrade {
    return gradeToLetter(cgpa);
  }
}
 
String gradeToLetter(double value) {
  if (value >= 4.00) return 'A+';
  if (value >= 3.70) return 'A-';
  if (value >= 3.30) return 'B+';
  if (value >= 3.00) return 'B';
  if (value >= 2.70) return 'B-';
  if (value >= 2.30) return 'C+';
  if (value >= 2.00) return 'C';
  if (value >= 1.70) return 'C-';
  if (value >= 1.00) return 'D';
  return 'F';
}
