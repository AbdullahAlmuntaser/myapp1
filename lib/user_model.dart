class User {
  int? id;
  final String username;
  final String passwordHash; // Storing hashed password, not plain text
  final String role; // e.g., 'admin', 'teacher', 'student'

  User({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.role,
  });

  // Convert a User object into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'passwordHash': passwordHash,
      'role': role,
    };
  }

  // Extract a User object from a Map.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      passwordHash: map['passwordHash'],
      role: map['role'],
    );
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, role: $role}';
  }
}
