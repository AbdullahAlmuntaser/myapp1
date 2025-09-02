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
      id: map['id'],
      name: map['name'],
      subject: map['subject'],
      phone: map['phone'],
      email: map['email'],
      password: map['password'],
      qualificationType: map['qualificationType'],
      responsibleClassId: map['responsibleClassId'],
    );
  }
}
