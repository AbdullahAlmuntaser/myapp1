
class Teacher {
  final int? id;
  final String name;
  final String subject;
  final String phone;
  final String? email;
  final String? password;
  final String? qualificationType;
  final String? responsibleClassId;

  Teacher({
    this.id,
    required this.name,
    required this.subject,
    required this.phone,
    this.email,
    this.password,
    this.qualificationType,
    this.responsibleClassId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'phone': phone,
      'email': email,
      'password': password,
      'qualificationType': qualificationType,
      'responsibleClassId': responsibleClassId,
    };
  }

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'] as int?,
      name: map['name'] as String,
      subject: map['subject'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String?,
      password: map['password'] as String?,
      qualificationType: map['qualificationType'] as String?,
      responsibleClassId: map['responsibleClassId'] as String?,
    );
  }

  @override
  String toString() {
    return 'Teacher{id: $id, name: $name, subject: $subject, phone: $phone, email: $email, password: $password, qualificationType: $qualificationType, responsibleClassId: $responsibleClassId}';
  }

  Teacher copyWith({
    int? id,
    String? name,
    String? subject,
    String? phone,
    String? email,
    String? password,
    String? qualificationType,
    String? responsibleClassId,
  }) {
    return Teacher(
      id: id ?? this.id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      qualificationType: qualificationType ?? this.qualificationType,
      responsibleClassId: responsibleClassId ?? this.responsibleClassId,
    );
  }
}
