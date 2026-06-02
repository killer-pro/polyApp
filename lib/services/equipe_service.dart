import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:new_app/models/equipe.dart';
import 'package:new_app/services/notification_service.dart';

class EquipeService {
  LocalNotificationService _notificationService =
      new LocalNotificationService();
  final CollectionReference equipesCollection =
      FirebaseFirestore.instance.collection('EQUIPE');

  Future<void> createEquipe(Equipe equipe) async {
    try {
      await equipesCollection.doc(equipe.id).set(equipe.toJson());
      await _notificationService.sendAllNotification("Une nouvelle équipe",
          "L'équipe du nom de ${equipe.nom} vient nous rejoindre dans la famille polytechnicienne. Nous leur souhaitons bonne chance.");
    } catch (e) {
    }
  }

  Future<Equipe?> getEquipeById(String id) async {
    try {
      DocumentSnapshot doc = await equipesCollection.doc(id).get();
      if (doc.exists) {
        return Equipe.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
    }
    return null;
  }

  Future<List<Equipe>> getAllEquipes() async {
    try {
      QuerySnapshot querySnapshot = await equipesCollection.get();
      return querySnapshot.docs
          .map((doc) => Equipe.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateEquipe(Equipe equipe) async {
    try {
      await equipesCollection.doc(equipe.id).update(equipe.toJson());
    } catch (e) {
    }
  }

  Future<void> deleteEquipe(String id) async {
    try {
      DocumentSnapshot equipeDoc = await equipesCollection.doc(id).get();

      if (equipeDoc.exists) {
        String logoUrl = equipeDoc['logo'];

        await equipesCollection.doc(id).delete();

        if (logoUrl.isNotEmpty) {
          final Reference storageRef =
              FirebaseStorage.instance.refFromURL(logoUrl);
          await storageRef.delete();
        }
      }
    } catch (e) {
    }
  }
}
