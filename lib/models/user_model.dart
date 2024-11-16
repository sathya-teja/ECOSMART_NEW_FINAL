class UserModel {
  final String id;
  final String name;
  final String email;
  final int points;
  final int disposals;
  final int level;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.points,
    required this.disposals,
    required this.level,
  });

  // Factory method to create a UserModel from a Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      points: map['points'] ?? 0,
      disposals: map['disposals'] ?? 0,
      level: map['level'] ?? 1,
    );
  }
}
