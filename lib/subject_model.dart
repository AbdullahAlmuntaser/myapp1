class Subject {
  final int? id;
  final String name;
  final String
  subjectId; // Unique identifier for the subject (e.g., "MATH101", "ARAB102")
  final String? description;
  final String? teacherId; // ID of the teacher responsible for this subject

  Subject({
    this.id,
    required this.name,
    required this.subjectId,
    this.description,
    this.teacherId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subjectId': subjectId,
      'description': description,
      'teacherId': teacherId,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] as int?,
      name: map['name'] as String,
      subjectId: map['subjectId'] as String,
      description: map['description'] as String?,
      teacherId: map['teacherId'] as String?,
    );
  }

  @override
  String toString() {
    return 'Subject{id: $id, name: $name, subjectId: $subjectId, description: $description, teacherId: $teacherId}';
  }

  Subject copyWith({
    int? id,
    String? name,
    String? subjectId,
    String? description,
    String? teacherId,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      subjectId: subjectId ?? this.subjectId,
      description: description ?? this.description,
      teacherId: teacherId ?? this.teacherId,
    );
  }
}
