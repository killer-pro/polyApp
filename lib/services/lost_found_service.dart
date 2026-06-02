import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:new_app/models/objet_perdu_model.dart';
import 'dart:io';

import 'package:new_app/services/notification_service.dart';

class ObjetPerduService {
  LocalNotificationService _notificationService = LocalNotificationService();
  final _firestore = FirebaseFirestore.instance;

  Future<String?> uploadImage(File imageFile) async {
    try {
      // Create a reference to the Firebase Storage location
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('LOSTOBJECTS/${imageFile.path.split('/').last}');

      // Upload the file
      final uploadTask = storageRef.putFile(imageFile);

      // Get the download URL once the upload is complete
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  Future<void> addLostObject(ObjetPerdu objetPerdu) async {
    try {
      await _firestore.collection('LOSTOBJECTS').add({
        'description': objetPerdu.description,
        'details': objetPerdu.details,
        'photoURL': objetPerdu.photoURL,
        'lieu': objetPerdu.lieu,
        'date': objetPerdu.date,
        'etat': objetPerdu.estTrouve,
        'idUser': objetPerdu.idUser
      });
      await _notificationService.sendAllNotification("Nouveau objet perdu",
          "Quelqu'un(e) vient de perdre un objet. Veuillez consulter l'annonce.");
    } catch (e) {
      return null;
    }
  }

  Stream<QuerySnapshot> getLostObjects() {
    return _firestore
        .collection('LOSTOBJECTS')
        .orderBy('etat', descending: false)
        .snapshots();
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      var snapshot = await _firestore.collection('USER').doc(email).get();
      return snapshot.data() as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> toggleFoundStatus(String docId, int value) async {
    try {
      _firestore.collection('LOSTOBJECTS').doc(docId).update({'etat': value});
    } catch (e) {
    }
  }

  Future<void> deleteLostObject(String docId) async {
    try {
      final doc =
          await _firestore.collection('LOSTOBJECTS').doc(docId).get();
      if (doc.exists) {
        final photoURL = doc.data()?['photoURL'] as String?;
        if (photoURL != null && photoURL.isNotEmpty) {
          try {
            await FirebaseStorage.instance.refFromURL(photoURL).delete();
          } catch (_) {}
        }
        await _firestore.collection('LOSTOBJECTS').doc(docId).delete();
      }
    } catch (e) {
    }
  }
}
