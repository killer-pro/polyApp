import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_app/models/avis.dart';

class AvisService {
  final CollectionReference _col =
      FirebaseFirestore.instance.collection('AVIS');

  /// Récupère tous les avis, triés du plus récent au plus ancien
  Future<List<Avis>> getAllAvis() async {
    try {
      final snap = await _col.orderBy('createdAt', descending: true).get();
      return snap.docs
          .map((d) => Avis.fromJson(d.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Récupère l'avis d'un utilisateur (null si aucun)
  Future<Avis?> getAvisByUser(String userId) async {
    try {
      final snap =
          await _col.where('userId', isEqualTo: userId).limit(1).get();
      if (snap.docs.isEmpty) return null;
      return Avis.fromJson(snap.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Crée un avis (un seul par utilisateur)
  Future<void> createAvis(Avis avis) async {
    await _col.doc(avis.id).set(avis.toJson());
  }

  /// Modifie un avis existant
  Future<void> updateAvis(Avis avis) async {
    await _col.doc(avis.id).update({
      'note': avis.note,
      'commentaire': avis.commentaire,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Supprime un avis
  Future<void> deleteAvis(String id) async {
    await _col.doc(id).delete();
  }
}
