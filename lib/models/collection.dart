import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_app/models/article_shop.dart';
import 'package:uuid/uuid.dart';

class Collection {
  final String id;
  final String nom;
  final List<ArticleShop> articleShops;
  DateTime date;

  Collection(
      {required this.id,
      required this.nom,
      required this.articleShops,
      required this.date});

  // Factory method to create an Collection object from JSON
  factory Collection.fromJson(Map<String, dynamic> json) {
    // Parse the 'ArticleShops' list from JSON and map it to a list of ArticleShop objects
    var articleShopsFromJson = json['articleShops'] as List<dynamic>;
    List<ArticleShop> articleShopsList =
        articleShopsFromJson.map((item) => ArticleShop.fromJson(item)).toList();

    return Collection(
      id: json['id'] as String,
      nom: json['nom'] as String,
      date: (json['date'] as Timestamp).toDate(),
      articleShops:articleShopsList,
    );
  }

  // Method to convert an Collection object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'date': date,
      'articleShops': articleShops
          .map((articleShop) => articleShop.toJson())
          .toList(),
           // Convert list of ArticleShop objects to JSON
    };
  }
}
