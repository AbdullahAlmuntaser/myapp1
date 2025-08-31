
class Student {
  final int? id;
  final String name;
  final String dob;
  final String phone;
  final String grade;

  Student({
    this.id,
    required this.name,
    required this.dob,
    required this.phone,
    required this.grade,
  });

  // Convert a Student into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dob': dob,
      'phone': phone,
      'grade': grade,
    };
  }

  // Implement toString to make it easier to see information about
  // each student when using the print statement.
  @override
  String toString() {
    return 'Student{id: $id, name: $name, dob: $dob, phone: $phone, grade: $grade}';
  }
}
