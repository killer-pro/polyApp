import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_app/models/annonce.dart';
import 'package:new_app/models/categorie.dart';
import 'package:new_app/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnnonceService {
  LocalNotificationService _notificationService = LocalNotificationService();
  CollectionReference<Map<String, dynamic>> annonceCollection =
      FirebaseFirestore.instance.collection("ANNONCE");

  Future<List<Annonce>> getAllAnnonces() async {
    List<Annonce> list = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await annonceCollection.get();

      List<Map<String, dynamic>> data =
          querySnapshot.docs.map((doc) => doc.data()).toList();
      for (var d in data) {
        list.add(Annonce.fromJson(d));
      }

      return list;
    } catch (e) {
      return [];
    }
  }

  Future<String> postAnnonce(Annonce annonce) async {
    try {
      await annonceCollection.doc(annonce.id).set(annonce.toJson());
      await _notificationService.sendAllNotification(
          "${annonce.titre}", "${annonce.description}");

      return "OK";
    } catch (e) {
      return "Erreur lors de la création de l'annnonce : $e";
    }
  }

  Future<Annonce?> getAnnonceId(String id) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await annonceCollection.where('id', isEqualTo: id).get();

      if (querySnapshot.docs.isNotEmpty) {
        return Annonce.fromJson(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> addCategorie(Categorie categorie) async {
    try {
      CollectionReference categories =
          FirebaseFirestore.instance.collection('CATEGORIE');

      await categories.doc(categorie.id).set(categorie.toJson());
    } catch (e) {
    }
  }

  Future<void> updateCategorie(Categorie categorie) async {
    try {
      CollectionReference categories =
          FirebaseFirestore.instance.collection('CATEGORIE');

      await categories.doc(categorie.id).update(categorie.toJson());
    } catch (e) {
    }
  }

  Future<void> deleteCategorie(String id) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('CATEGORIE')
          .doc(id)
          .get();

      if (doc.exists) {
        String logoUrl = doc.get('logo');

        if (logoUrl.isNotEmpty) {
          Reference imageRef = FirebaseStorage.instance.refFromURL(logoUrl);
          await imageRef.delete();
        }

        await FirebaseFirestore.instance
            .collection('CATEGORIE')
            .doc(id)
            .delete();
      } else {
      }
    } catch (e) {
    }
  }

  Future<List<Categorie>> getAllCategories() async {
    try {
      List<Categorie> list = [];
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection("CATEGORIE").get();

      List<Map<String, dynamic>> listeCategories =
          querySnapshot.docs.map((doc) => doc.data()).toList();
      for (var categorie in listeCategories) {
        list.add(Categorie.fromJson(categorie));
      }

      return list;
    } catch (e) {
      return [];
    }
  }

  Future<List<Annonce>> getAnnoncesByCategorie(Categorie categorie) async {
    List<Annonce> list = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await annonceCollection
              .where("categorie.id", isEqualTo: categorie.id)
              .get();

      List<Map<String, dynamic>> data =
          querySnapshot.docs.map((doc) => doc.data()).toList();
      for (var d in data) {
        list.add(Annonce.fromJson(d));
      }

      return list;
    } catch (e) {
      return [];
    }
  }

  Future<List<Annonce>> getListEvenements(Categorie categorie) async {
    List<Annonce> list = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await annonceCollection.where("image", isNotEqualTo: "").get();

      List<Map<String, dynamic>> data =
          querySnapshot.docs.map((doc) => doc.data()).toList();
      for (var d in data) {
        list.add(Annonce.fromJson(d));
      }

      return list;
    } catch (e) {
      return [];
    }
  }

  Future<List<Annonce>> getNextEvenement() async {
    List<Annonce> list = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await annonceCollection
              .where("image", isNotEqualTo: "")
              .where("date", isLessThanOrEqualTo: Timestamp.now())
              .limit(5)
              .get();

      List<Map<String, dynamic>> data =
          querySnapshot.docs.map((doc) => doc.data()).toList();
      for (var d in data) {
        list.add(Annonce.fromJson(d));
      }

      return list;
    } catch (e) {
      return [];
    }
  }

  Future<Annonce?> getNextAG() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await annonceCollection
              .where('categorie.libelle', isEqualTo: "AG")
              // .where('date', isGreaterThan: DateTime.now())
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Annonce.fromJson(querySnapshot.docs.last.data());
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String> deleteAnnonceById(String annonceId) async {
    // Vérification du rôle admin
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    const adminRoles = ['ADMIN', 'ADMIN_MB'];
    if (role == null || !adminRoles.contains(role)) {
      return "Permission refusée : rôle administrateur requis";
    }

    try {
      // Rechercher l'annonce avec l'ID correspondant
      QuerySnapshot querySnapshot = await annonceCollection
          .where('id', isEqualTo: annonceId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Récupérer l'URL de l'image de l'annonce
        String imageUrl = querySnapshot.docs.first['image'];

        // Supprimer l'image dans Firebase Storage si l'URL existe
        if (imageUrl.isNotEmpty) {
          // Créer une référence à l'image dans Firebase Storage à partir de son URL
          Reference imageRef = FirebaseStorage.instance.refFromURL(imageUrl);

          // Supprimer l'image dans Firebase Storage
          await imageRef.delete();
        }

        // Supprimer l'annonce dans Firestore
        await querySnapshot.docs.first.reference.delete();
        return "Annonce et image supprimées avec succès";
      } else {
        return "Annonce non trouvée";
      }
    } catch (e) {
      return "Erreur lors de la suppression de l'annonce ou de l'image : $e";
    }
  }

  Future<String> updateAnnonce(Annonce annonce) async {
    try {
      await FirebaseFirestore.instance
          .collection('ANNONCE')
          .doc(annonce.id)
          .update(annonce.toJson());
      return "OK";
    } catch (e) {
      return "Error";
    }
  }
}
