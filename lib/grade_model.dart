class Grade {
  int? id;
  final int studentId;
  final int subjectId;
  final int classId;
  final String assessmentType; // e.g., 'واجب', 'اختبار', 'مشروع'
  final double gradeValue;
  final double weight; // Relative weight of the assessment
  final String date; // Date of the assessment (YYYY-MM-DD)
  final String? description; // Optional description for the grade
  final double? maxGrade; // Maximum possible grade for this assessment

  Grade({
    this.id,
    required this.studentId,
    required this.subjectId,
    required this.classId,
    required this.assessmentType,
    required this.gradeValue,
    required this.weight,
    required this.date,
    this.description,
    this.maxGrade,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'subjectId': subjectId,
      'classId': classId,
      'assessmentType': assessmentType,
      'gradeValue': gradeValue,
      'weight': weight,
      'date': date,
      'description': description,
      'maxGrade': maxGrade,
    };
  }

  static Grade fromMap(Map<String, dynamic> map) {
    return Grade(
      id: map['id'],
      studentId: map['studentId'],
      subjectId: map['subjectId'],
      classId: map['classId'],
      assessmentType: map['assessmentType'],
      gradeValue: map['gradeValue'],
      weight: map['weight'],
      date: map['date'],
      description: map['description'],
      maxGrade: map['maxGrade'],
    );
  }

  @override
  String toString() {
    return 'Grade{id: $id, studentId: $studentId, subjectId: $subjectId, classId: $classId, assessmentType: $assessmentType, gradeValue: $gradeValue, weight: $weight, date: $date, description: $description, maxGrade: $maxGrade}';
  }
}

// Extension to allow copyWith on Grade model
extension GradeCopyWith on Grade {
  Grade copyWith({
    int? id,
    int? studentId,
    int? subjectId,
    int? classId,
    String? assessmentType,
    double? gradeValue,
    double? weight,
    String? date,
    String? description,
    double? maxGrade,
  }) {
    return Grade(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      subjectId: subjectId ?? this.subjectId,
      classId: classId ?? this.classId,
      assessmentType: assessmentType ?? this.assessmentType,
      gradeValue: gradeValue ?? this.gradeValue,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      description: description ?? this.description,
      maxGrade: maxGrade ?? this.maxGrade,
    );
  }
}
