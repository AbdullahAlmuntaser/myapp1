
class Student {
  final int? id;
  final String name;
  final String dob;
  final String phone;
  final String grade;
  final String? email;
  final String? password;
  final String? classId;

  Student({
    this.id,
    required this.name,
    required this.dob,
    required this.phone,
    required this.grade,
    this.email,
    this.password,
    this.classId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dob': dob,
      'phone': phone,
      'grade': grade,
      'email': email,
      'password': password,
      'classId': classId,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      name: map['name'] as String,
      dob: map['dob'] as String,
      phone: map['phone'] as String,
      grade: map['grade'] as String,
      email: map['email'] as String?,
      password: map['password'] as String?,
      classId: map['classId'] as String?,
    );
  }

  @override
  String toString() {
    return 'Student{id: $id, name: $name, dob: $dob, phone: $phone, grade: $grade, email: $email, password: $password, classId: $classId}';
  }

  Student copyWith({
    int? id,
    String? name,
    String? dob,
    String? phone,
    String? grade,
    String? email,
    String? password,
    String? classId,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      dob: dob ?? this.dob,
      phone: phone ?? this.phone,
      grade: grade ?? this.grade,
      email: email ?? this.email,
      password: password ?? this.password,
      classId: classId ?? this.classId,
    );
  }
}
