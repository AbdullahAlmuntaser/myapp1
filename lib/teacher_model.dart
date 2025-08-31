
class Teacher {
  final int? id;
  final String name;
  final String subject;
  final String phone;

  Teacher({
    this.id,
    required this.name,
    required this.subject,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'phone': phone,
    };
  }
}
