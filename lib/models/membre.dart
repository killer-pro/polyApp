import 'package:new_app/models/enums/sport_type.dart';

class Membre {
  final String role;
  final String nom;
  final String image;
  final SportType sport;
  final String id;

  Membre({
    required this.role,
    required this.nom,
    required this.image,
    required this.sport,
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'nom': nom,
      'image': image,
      'sport': sport.name,
      'id': id,
    };
  }

  factory Membre.fromJson(Map<String, dynamic> json) {
    return Membre(
      role: json['role'] as String,
      nom: json['nom'] as String,
      image: json['image'] as String,
      sport: SportType.values.firstWhere(
        (e) => e.name == json['sport'],
        orElse: () => SportType.FOOTBALL,
      ),
      id: json['id'] as String,
    );
  }
}
