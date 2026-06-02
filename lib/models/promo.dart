import 'package:uuid/uuid.dart';

class Promo {
  final String id;
  final String nom;
  final String devise;
  final String logo;

  Promo({
    required this.id,
    required this.nom,
    required this.devise,
    required this.logo,
  });

  // Factory method to create an Promo object from JSON
  factory Promo.fromJson(Map<String, dynamic> json) {
    return Promo(
      id: json['id'] as String,
      nom: json['nom'] as String,
      devise: json['devise'] as String,
      logo: json['logo'] as String,
    );
  }

  // Method to convert an Promo object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'devise': devise,
      'logo': logo,
    };
  }
}
