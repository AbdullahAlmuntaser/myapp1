
class AssessmentType {
  final int? id;
  final String name;
  final double weight;

  AssessmentType({
    this.id,
    required this.name,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
    };
  }

  factory AssessmentType.fromMap(Map<String, dynamic> map) {
    return AssessmentType(
      id: map['id'] as int?,
      name: map['name'] as String,
      weight: map['weight'] as double,
    );
  }

  AssessmentType copyWith({
    int? id,
    String? name,
    double? weight,
  }) {
    return AssessmentType(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
    );
  }
}
