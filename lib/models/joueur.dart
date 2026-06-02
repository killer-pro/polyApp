import 'package:new_app/models/enums/position_joueur.dart';

class Joueur {
  final String id;
  final String prenom;
  final String nom;
  final PositionJoueur? position;
  final int totalBut;

  Joueur({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.position,
    required this.totalBut,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prenom': prenom,
      'nom': nom,
      'position': position?.name,
      'totalBut': totalBut,
    };
  }

  factory Joueur.fromJson(Map<String, dynamic> json) {
    return Joueur(
      id: json['id'],
      prenom: json['prenom'],
      nom: json['nom'],
      position: PositionJoueur.values.firstWhere(
        (e) => e.name == json['position'],
        orElse: () => PositionJoueur.MILIEU,
      ),
      totalBut: json['totalBut'] as int? ?? 0,
    );
  }
}
