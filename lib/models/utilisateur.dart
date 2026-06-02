import 'package:uuid/uuid.dart';
import 'package:new_app/models/enums/role_type.dart';

class Utilisateur {
  final String? id;
  final String? promo;
  final String? genie;
  final String prenom; // Obligatoire
  final String nom; // Obligatoire
  final String email; // Obligatoire
  final String? telephone;
  final String? photo; // This could be a URL
  final RoleType? role;

  Utilisateur(
      {this.id,
      this.promo,
      this.genie,
      required this.prenom,
      required this.nom,
      required this.email,
      this.telephone,
      this.photo,
      this.role});

  // Factory method to create a Utilisateur object from JSON
  Utilisateur.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String?,
        genie = json['genie'] as String?,
        promo = json['promo'] as String?,
        prenom = json['prenom'] as String? ?? '',
        nom = json['nom'] as String? ?? '',
        email = json['email'] as String? ?? '',
        telephone = json['telephone'] as String?,
        photo = json['photo'] as String?,
        role = RoleType.values.firstWhere(
          (e) => e.toString().split('.').last == json['role'],
          orElse: () => RoleType.USER,
        );
  // token FCM stocké uniquement dans la collection TOKEN, pas dans USER

  // Method to convert a Utilisateur object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'promo': promo,
      'genie': genie,
      'prenom': prenom,
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'photo': photo,
      'role': role.toString().split('.').last,
    };
  }
}
