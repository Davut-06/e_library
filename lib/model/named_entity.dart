class NamedEntity {
  final int id;
  final String name;

  NamedEntity({required this.id, required this.name});

  factory NamedEntity.fromMap(Map<String, dynamic> map) {
    return NamedEntity(
      id: map['id'] is int
          ? map['id'] as int
          : int.tryParse('${map['id']}') ?? 0,
      name: map['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }
}
