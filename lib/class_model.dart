class SchoolClass {
  final int? id;
  final String name;
  final String
  classId; // Unique identifier for the class (e.g., "10A", "Grade5B")
  final String? teacherId; // ID of the responsible teacher
  final int? capacity; // Maximum number of students
  final String? yearTerm; // Academic year or term

  SchoolClass({
    this.id,
    required this.name,
    required this.classId,
    this.teacherId,
    this.capacity,
    this.yearTerm,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'classId': classId,
      'teacherId': teacherId,
      'capacity': capacity,
      'yearTerm': yearTerm,
    };
  }

  factory SchoolClass.fromMap(Map<String, dynamic> map) {
    return SchoolClass(
      id: map['id'] as int?,
      name: map['name'] as String,
      classId: map['classId'] as String,
      teacherId: map['teacherId'] as String?,
      capacity: map['capacity'] as int?,
      yearTerm: map['yearTerm'] as String?,
    );
  }

  @override
  String toString() {
    return 'SchoolClass{id: $id, name: $name, classId: $classId, teacherId: $teacherId, capacity: $capacity, yearTerm: $yearTerm}';
  }

  SchoolClass copyWith({
    int? id,
    String? name,
    String? classId,
    String? teacherId,
    int? capacity,
    String? yearTerm,
  }) {
    return SchoolClass(
      id: id ?? this.id,
      name: name ?? this.name,
      classId: classId ?? this.classId,
      teacherId: teacherId ?? this.teacherId,
      capacity: capacity ?? this.capacity,
      yearTerm: yearTerm ?? this.yearTerm,
    );
  }
}
