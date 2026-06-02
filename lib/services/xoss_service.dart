import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/models/enums/statut_xoss.dart';
import 'package:new_app/models/utilisateur.dart';
import 'package:new_app/models/xoss.dart';

class XossService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> xossCollection =
      FirebaseFirestore.instance.collection("XOSS");

  Future<List<Xoss>> getAllXoss() async {
    List<Xoss> list = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await xossCollection.get();

      if (querySnapshot.docs.isEmpty) {
      }

      List<Map<String, dynamic>> data = querySnapshot.docs.map((doc) {
        return doc.data();
      }).toList();

      for (var d in data) {
        try {
          Xoss xoss = Xoss.fromJson(d);
          list.add(xoss);
        } catch (e) {
        }
      }

      return list;
    } catch (e) {
      return [];
    }
  }

  Future<List<Xoss>> getAllXossOfUserByEmail(String email) async {
    List<Xoss> list = [];

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await xossCollection
          .where("user.email", isEqualTo: email)
          .get();

      List<Map<String, dynamic>> data =
          querySnapshot.docs.map((doc) => doc.data()).toList();
      for (var d in data) {
        list.add(Xoss.fromJson(d));
      }
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    } catch (e) {
      return [];
    }
  }

  Stream<List<Xoss>> streamXossOfUser(String email) {
    return xossCollection
        .where("user.email", isEqualTo: email)
        .snapshots()
        .map((snap) {
      final list = <Xoss>[];
      for (final d in snap.docs) {
        try {
          list.add(Xoss.fromJson(d.data()));
        } catch (e) {
          debugPrint('[XossService] fromJson error on ${d.id}: $e');
        }
      }
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Future<String> postXoss(Xoss xoss) async {
    try {
      String email = FirebaseAuth.instance.currentUser!.email!;
      // Récupérer l'utilisateur avec l'email
      QuerySnapshot userSnapshot = await _firestore
          .collection("USER")
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (userSnapshot.docs.isEmpty) return "";

      Map<String, dynamic> userData =
          userSnapshot.docs.first.data() as Map<String, dynamic>;

      Utilisateur utilisateur = Utilisateur.fromJson(userData);
      xoss.user = utilisateur;
      await xossCollection.doc(xoss.id).set(xoss.toJson());
      return "OK";
    } catch (e) {
      return "Erreur lors de la création du match : $e";
    }
  }

  Future<Xoss?> getXossId(String id) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await xossCollection.where('id', isEqualTo: id).get();

      if (querySnapshot.docs.isNotEmpty) {
        return Xoss.fromJson(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<List<Xoss>> streamAllXoss() {
    return xossCollection.snapshots().map((snap) {
      final list = <Xoss>[];
      for (final d in snap.docs) {
        try {
          list.add(Xoss.fromJson(d.data()));
        } catch (e) {
          debugPrint('[XossService] fromJson error on ${d.id}: $e');
        }
      }
      list.sort((a, b) => a.date.compareTo(b.date));
      return list;
    });
  }

  /// Distribue un paiement en soldant les khoss du plus ancien au plus récent (FIFO).
  Future<void> applyPayment(String userEmail, int montant) async {
    final snap = await xossCollection
        .where("user.email", isEqualTo: userEmail)
        .get();

    final xossList = snap.docs
        .map((d) => Xoss.fromJson(d.data()))
        .where((x) => x.statut != StatutXoss.PAYEE)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date)); // FIFO : plus ancien d'abord

    int restant = montant;
    for (final x in xossList) {
      if (restant <= 0) break;
      final du = x.montant - x.versement;
      if (restant >= du) {
        await xossCollection.doc(x.id).update({
          'versement': x.montant,
          'statut': StatutXoss.PAYEE.toString().split('.').last,
        });
        restant -= du;
      } else {
        await xossCollection.doc(x.id).update({
          'versement': x.versement + restant,
          'statut': StatutXoss.ATTENTE.toString().split('.').last,
        });
        restant = 0;
      }
    }
  }

  Future<bool> deleteXoss(String id) async {
    try {
      await xossCollection.doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Xoss?> updateXoss(String id, String libelle, dynamic value) async {
    try {
      DocumentReference matchDoc = xossCollection.doc(id);
      await matchDoc.update(
        {libelle: value},
      );

      DocumentSnapshot querySnapshot = await matchDoc.get();

      return Xoss.fromJson(querySnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }
}
