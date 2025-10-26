class Attendance {
  int? id;
  int studentId;
  int classId;
  int subjectId; // To link attendance to a specific subject lesson
  int teacherId; // To link attendance to a specific teacher
  String date; // Format: YYYY-MM-DD
  int lessonNumber; // Example: 1, 2, 3 for first, second, third lesson
  String status; // 'present', 'absent', 'late', 'excused'
  int? lateMinutes; // New field for late minutes

  Attendance({
    this.id,
    required this.studentId,
    required this.classId,
    required this.subjectId,
    required this.teacherId,
    required this.date,
    required this.lessonNumber,
    required this.status,
    this.lateMinutes, // Make it optional
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'classId': classId,
      'subjectId': subjectId,
      'teacherId': teacherId,
      'date': date,
      'lessonNumber': lessonNumber,
      'status': status,
      'lateMinutes': lateMinutes,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      studentId: map['studentId'],
      classId: map['classId'],
      subjectId: map['subjectId'],
      teacherId: map['teacherId'],
      date: map['date'],
      lessonNumber: map['lessonNumber'],
      status: map['status'],
      lateMinutes: map['lateMinutes'],
    );
  }
}
