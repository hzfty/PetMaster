class Pet {
  String id; // Сделали id не-nullable
  String name;
  DateTime birthDate;
  String gender;
  String breed;
  String type; // Собака, Кошка, Птица, Грызун
  String? photoUrl;
  bool isSterilized;
  bool isChipped;
  String? chipNumber;
  String? distinctiveMarks;
  String? allergies;
  double? weight;

  Pet({
    required this.id, // Сделали id обязательным
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.breed,
    required this.type,
    this.photoUrl,
    this.isSterilized = false,
    this.isChipped = false,
    this.chipNumber,
    this.distinctiveMarks,
    this.allergies,
    this.weight,
  });

  // Методы для конвертации из/в Map для Firestore
  Map<String, dynamic> toMap() {
    return {
      // 'id': id, // Можно не сохранять id в документе, так как он уже есть в Firestore
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'breed': breed,
      'type': type,
      'photoUrl': photoUrl,
      'isSterilized': isSterilized,
      'isChipped': isChipped,
      'chipNumber': chipNumber,
      'distinctiveMarks': distinctiveMarks,
      'allergies': allergies,
      'weight': weight,
    };
  }

  factory Pet.fromMap(String id, Map<String, dynamic> map) {
    return Pet(
      id: id, // Теперь id обязательно и не может быть null
      name: map['name'],
      birthDate: DateTime.parse(map['birthDate']),
      gender: map['gender'],
      breed: map['breed'],
      type: map['type'],
      photoUrl: map['photoUrl'],
      isSterilized: map['isSterilized'],
      isChipped: map['isChipped'],
      chipNumber: map['chipNumber'],
      distinctiveMarks: map['distinctiveMarks'],
      allergies: map['allergies'],
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
    );
  }
}
