import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:new_app/models/article_shop.dart';
import 'package:new_app/models/categorie_shop.dart';
import 'package:new_app/models/collection.dart';
import 'package:new_app/models/commande.dart';
import 'package:new_app/models/utilisateur.dart';

class ShopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> collectionCollection =
      FirebaseFirestore.instance.collection("COLLECTION");

  CollectionReference<Map<String, dynamic>> articleCollection =
      FirebaseFirestore.instance.collection("ARTICLE");

  CollectionReference<Map<String, dynamic>> categorieShopCollection =
      FirebaseFirestore.instance.collection("CATEGORIESHOP");

  Future<List<Collection>> getAllCollection() async {
    List<Collection> list = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await collectionCollection.get();

      List<Map<String, dynamic>> data =
          querySnapshot.docs.map((doc) => doc.data()).toList();
      for (var d in data) {
        list.add(Collection.fromJson(d));
      }

      return list;
    } catch (e) {
      return [];
    }
  }

  Future<Collection?> getNewCollection() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await collectionCollection.get();

      Map<String, dynamic> data =
          querySnapshot.docs.map((doc) => doc.data()).last;
      return Collection.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<List<CategorieShop>> getAllCategorieShop() async {
    List<CategorieShop> list = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await categorieShopCollection.get();

      List<Map<String, dynamic>> data =
          querySnapshot.docs.map((doc) => doc.data()).toList();
      for (var d in data) {
        list.add(CategorieShop.fromJson(d));
      }

      return list;
    } catch (e) {
      return [];
    }
  }

  Future<List<ArticleShop>> getAllArticle() async {
    List<ArticleShop> list = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await articleCollection.get();

      List<Map<String, dynamic>> data =
          querySnapshot.docs.map((doc) => doc.data()).toList();
      for (var d in data) {
        list.add(ArticleShop.fromJson(d));
      }

      return list;
    } catch (e) {
      return [];
    }
  }

  Future<List<Collection>> getAllShopOfUserByEmail(String email) async {
    List<Collection> list = [];

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await collectionCollection
              .where("user.email", isEqualTo: email)
              .orderBy("date", descending: true)
              .get();

      List<Map<String, dynamic>> data =
          querySnapshot.docs.map((doc) => doc.data()).toList();
      for (var d in data) {
        list.add(Collection.fromJson(d));
      }

      return list;
    } catch (e) {
      return [];
    }
  }

  Future<String> postCollection(Collection collection) async {
    try {
      await collectionCollection.doc(collection.id).set(collection.toJson());
      return "OK";
    } catch (e) {
      return "Erreur lors de la création de collection : $e";
    }
  }

  Future<String> postArticleShop(ArticleShop article) async {
    try {
      await articleCollection.doc(article.id).set(article.toJson());
      return "OK";
    } catch (e) {
      return "Erreur lors de la création de l'article : $e";
    }
  }

  Future<void> updateArticleImage(String articleId, String newImageUrl) async {
    try {
      // Mise à jour du document Firestore correspondant à l'article
      await _firestore.collection('ARTICLE').doc(articleId).update({
        'image': newImageUrl, // Mise à jour du champ 'image' avec le nouvel URL
      });
    } catch (e) {
      throw Exception("Erreur lors de la mise à jour de l'image : $e");
    }
  }

  Future<String> updateArticleShop(ArticleShop articleShop) async {
    try {
      DocumentReference articleRef =
          _firestore.collection('ARTICLE').doc(articleShop.id);

      await articleRef.update({
        'titre': articleShop.titre,
        'description': articleShop.description,
        'prix': articleShop.prix,
        'image': articleShop.image,
        'categorie': articleShop.categorie.toJson(),
      });

      return "OK";
    } catch (e) {
      return "Erreur lors de la mise à jour de l'article.";
    }
  }

  Future<void> deleteArticle(String articleId, String imageUrl) async {
    try {
      // Supprimer l'image du stockage Firebase
      try {
        if (imageUrl.isNotEmpty) {
          await FirebaseStorage.instance.refFromURL(imageUrl).delete();
        }
      } catch (e) {
        print(e);
      }

      // Supprimer l'article de Firestore
      await _firestore.collection('ARTICLE').doc(articleId).delete();
    } catch (e) {
      throw Exception("Erreur lors de la suppression de l'article : $e");
    }
  }

  Future<String> postCommande(ArticleShop produit, int quantity) async {
    try {
      String email = FirebaseAuth.instance.currentUser!.email!;
      DocumentSnapshot userSnapshot =
          await _firestore.collection("USER").doc(email).get();
      if (userSnapshot.data() == null) return "KO";

      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

      // Créer une nouvelle commande
      Commande commande = Commande(
        date: DateTime.now(),
        id: DateTime.now().toIso8601String(),
        userId: Utilisateur.fromJson(userData).id!,
        nombre: quantity,
        produitId: produit.id,
      );

      // Ajouter la commande directement dans la collection "COMMANDE"
      await FirebaseFirestore.instance
          .collection("COMMANDE")
          .doc(commande.id)
          .set(commande.toJson());

      return "OK";
    } catch (e) {
      return "Erreur lors de la création de la commande : $e";
    }
  }

  Future<Collection?> getCollectionId(String id) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await collectionCollection.where('id', isEqualTo: id).get();

      if (querySnapshot.docs.isNotEmpty) {
        return Collection.fromJson(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> getCarouselImages(String collectionId) async {
    try {
      Collection? collection = await getCollectionId(collectionId);
      if (collection != null) {
        return collection.articleShops.map((article) => article.image).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Stream<QuerySnapshot> getCommandesByArticle(String articleId) {
    return _firestore
        .collection('COMMANDE')
        .where('produitId', isEqualTo: articleId)
        .snapshots();
  }

  Future<void> updateCommandeFields(
      String commandeId, {bool? recu, bool? paye}) async {
    final Map<String, dynamic> data = {};
    if (recu != null) data['recu'] = recu;
    if (paye != null) data['paye'] = paye;
    if (data.isEmpty) return;
    await _firestore.collection('COMMANDE').doc(commandeId).update(data);
  }

  Future<Collection?> updateShop(
      String id, String libelle, dynamic value) async {
    try {
      DocumentReference matchDoc = collectionCollection.doc(id);
      await matchDoc.update(
        {libelle: value},
      );

      DocumentSnapshot querySnapshot = await matchDoc.get();

      return Collection.fromJson(querySnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }
}
