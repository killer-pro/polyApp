import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_app/models/categorie_shop.dart';
import 'package:new_app/models/commande.dart';
import 'package:new_app/models/utilisateur.dart';
import 'package:uuid/uuid.dart';
import 'package:new_app/models/commentaires.dart';

class ArticleShop {
  final String id;
  final DateTime dateCreation;
  final String description;
  final String titre;
  final int prix;
  final String image;
  final CategorieShop categorie;
  final List<Commande> commandes;
  final String partageLien;

  ArticleShop({
    required this.id,
    required this.dateCreation,
    required this.description,
    required this.titre,
    required this.prix,
    required this.image,
    required this.categorie,
    required this.commandes,
    required this.partageLien,
  });

  factory ArticleShop.fromJson(Map<String, dynamic> json) {
    var commandesFromJson = json['commandes'] as List<dynamic>;
    List<Commande> commandeList =
        commandesFromJson.map((item) => Commande.fromJson(item)).toList();

    return ArticleShop(
      id: json['id'] as String,
      dateCreation: (json['dateCreation'] as Timestamp).toDate(),
      description: json['description'] as String,
      titre: json['titre'] as String,
      prix: (json['prix'] as num).toInt(),
      // prix: 0,
      image: json['image'] as String,
      categorie: CategorieShop.fromJson(json['categorie']),
      commandes: commandeList,

      partageLien: json['partageLien'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateCreation': dateCreation,
      'description': description,
      'titre': titre,
      'prix': prix,
      'image': image,
      'categorie': categorie.toJson(),
      'commandes': commandes.map((user) => user.toJson()).toList(),
      'partageLien': partageLien,
    };
  }
}
