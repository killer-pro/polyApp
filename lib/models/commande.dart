import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_app/models/enums/statut_commande.dart';

class Commande {
  String id;
  String produitId;
  DateTime date;
  String userId;
  int nombre;
  StatutCommande statut;
  bool recu;
  bool paye;

  Commande({
    required this.id,
    required this.produitId,
    required this.date,
    required this.userId,
    required this.nombre,
    this.statut = StatutCommande.EN_ATTENTE,
    this.recu = false,
    this.paye = false,
  });

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      id: json['id'] as String,
      produitId: json['produitId'] as String,
      date: (json['date'] as Timestamp).toDate(),
      userId: json['userId'] as String,
      nombre: json['nombre'] as int,
      statut: StatutCommande.values.firstWhere(
        (e) => e.name == json['statut'],
        orElse: () => StatutCommande.EN_ATTENTE,
      ),
      recu: json['recu'] as bool? ?? false,
      paye: json['paye'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'produitId': produitId,
      'date': Timestamp.fromDate(date),
      'userId': userId,
      'nombre': nombre,
      'statut': statut.name,
      'recu': recu,
      'paye': paye,
    };
  }
}
