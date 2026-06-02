import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:new_app/models/utilisateur.dart';
import 'package:new_app/models/enums/statut_xoss.dart';

class Xoss {
  final String id; // UUID
  final int montant; // Transaction amount
  final int versement;
  final DateTime date; // Date of the transaction
  Utilisateur? user; // The user associated with the transaction
  final List<String> produit; // List of product names or IDs
  final StatutXoss statut; // Payment status (PAYEE, IMPAYEE)

  Xoss({
    required this.id,
    required this.montant,
    required this.versement,
    required this.date,
    this.user,
    required this.produit,
    required this.statut,
  });

  factory Xoss.fromJson(Map<String, dynamic> json) {
    return Xoss(
      id: json['id'] as String,
      montant: (json['montant'] as num).toInt(),
      versement: (json['versement'] as num?)?.toInt() ?? 0,
      date: json['date'] is String
          ? DateTime.parse(json['date'] as String)
          : (json['date'] as Timestamp).toDate(),
      user: Utilisateur.fromJson(json['user'] as Map<String, dynamic>),
      produit: List<String>.from(json['produit'] as List<dynamic>),
      statut: StatutXoss.values.firstWhere(
        (e) => e.toString() == 'StatutXoss.${json['statut']}',
        orElse: () => StatutXoss.IMPAYEE,
      ),
    );
  }

  // Method to convert a Xoss object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'montant': montant,
      'versement': versement,
      'date': Timestamp.fromDate(date),
      'user': user!.toJson(),
      'produit': produit,
      'statut': statut.toString().split('.').last,
    };
  }
}
