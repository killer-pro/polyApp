import 'package:uuid/uuid.dart';

class Categorie {
  final String id;
  final String libelle;
  final String logo;

  Categorie({
    required this.id,
    required this.libelle,
    required this.logo,
  });

  // Factory method to create a Categorie object from JSON
  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      id: json['id'] as String,
      libelle: json['libelle'] as String,
      logo: json['logo'] as String,
    );
  }

  // Method to convert a Categorie object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
      'logo': logo,
    };
  }
}
