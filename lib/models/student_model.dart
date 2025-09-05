class Student {
  final int? id;
  final String name;
  final String? email;
  final int classId;
  final DateTime? createdAt;

  Student({
    this.id,
    required this.name,
    this.email,
    required this.classId,
    this.createdAt,
  });

  Student copyWith({
    int? id,
    String? name,
    String? email,
    int? classId,
    DateTime? createdAt,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      classId: classId ?? this.classId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String?,
      classId: map['class_id'] as int,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'class_id': classId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) => Student.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Student &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          classId == other.classId;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ classId.hashCode;
}