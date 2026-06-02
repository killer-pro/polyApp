import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/basket.dart';
import 'package:new_app/models/buteur.dart';
import 'package:new_app/models/commentaires.dart';
import 'package:new_app/models/enums/sport_type.dart';
import 'package:new_app/models/equipe.dart';
import 'package:new_app/models/football.dart';
import 'package:new_app/models/jeux_esprit.dart';
import 'package:new_app/models/joueur.dart';
import 'package:new_app/models/match.dart';
import 'package:new_app/models/membre.dart';
import 'package:new_app/models/utilisateur.dart';
import 'package:new_app/models/volleyball.dart';
import 'package:new_app/services/notification_service.dart';

class SportService {
  LocalNotificationService _notificationService = LocalNotificationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference footballCollection =
      FirebaseFirestore.instance.collection("MATCH");

  CollectionReference commissionCollection =
      FirebaseFirestore.instance.collection("COMMISSION");

  CollectionReference tokenCollection =
      FirebaseFirestore.instance.collection("TOKEN");

// Football SERVICE
  Future<List<Equipe>> getEquipeList() async {
    try {
      List<Equipe> list = [];
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _firestore.collection("EQUIPE").get();
      List<Map<String, dynamic>> listeEquipes =
          querySnapshot.docs.map((doc) => doc.data()).toList();
      for (var equipe in listeEquipes) {
        list.add(Equipe.fromJson(equipe));
      }
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<String> postFootball(dynamic football) async {
    try {
      await footballCollection
          .doc(football.equipeA.nom +
              " VS " +
              football.equipeB.nom +
              football.date.toString())
          .set(football.toJson());

      // Envoyer une notification à chaque token actif
      await _notificationService.sendAllNotification(
          "Un nouveau match",
          "La ${football.equipeA.nom} jouera avec ${football.equipeB.nom} "
              "le ${dateCustomformat(football.date)}. Rendez-vous à ne pas manquer!");

      return "OK";
    } catch (e) {
      return "Erreur lors de la création du match : $e";
    }
  }

  Future<String> removeMatch(String id) async {
    // Vérification du rôle admin sport
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    const adminRoles = [
      'ADMIN',
      'ADMIN_MB',
      'ADMIN_FOOTBALL',
      'ADMIN_BASKETBALL',
      'ADMIN_VOLLEYBALL',
      'ADMIN_JEUX_ESPRIT'
    ];
    if (role == null || !adminRoles.contains(role)) {
      return "Permission refusée : rôle administrateur requis";
    }

    try {
      DocumentSnapshot matchSnapshot =
          await _firestore.collection("MATCH").doc(id).get();

      if (matchSnapshot.exists) {
        String imageUrl = matchSnapshot['photo'] ?? '';

        if (imageUrl.isNotEmpty) {
          try {
            Reference imageRef = FirebaseStorage.instance.refFromURL(imageUrl);
            await imageRef.delete();
          } catch (e) {
            return "Erreur lors de la suppression de l'image : $e";
          }
        }

        await _firestore.collection("MATCH").doc(id).delete();
        return "ok";
      } else {
        return "Match non trouvé";
      }
    } catch (e) {
      return "Erreur : $e";
    }
  }

  Future<List<Matches>> getLastMatch() async {
    List<Matches> list = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection("MATCH")
          .where("date", isLessThanOrEqualTo: Timestamp.now())
          .orderBy("date", descending: true)
          .limit(2)
          .get();
      List<Map<String, dynamic>> data =
          querySnapshot.docs.map((doc) => doc.data()).toList();
      for (var d in data) {
        list.add(Matches.fromJson(d));
      }

      return list;
    } catch (e) {
      return [];
    }
  }

  Future<List<Matches>> getNextMatch() async {
    List<Matches> list = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection("MATCH")
          .where("date", isGreaterThanOrEqualTo: Timestamp.now())
          .limit(5)
          .get();
      List<Map<String, dynamic>> data =
          querySnapshot.docs.map((doc) => doc.data()).toList();
      for (var d in data) {
        list.add(Matches.fromJson(d));
      }

      return list;
    } catch (e) {
      return [];
    }
  }

  Future<Matches?> getTheFollowingMatch(String typeSport) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection("MATCH")
          .where("date", isGreaterThanOrEqualTo: Timestamp.now())
          .where("sport", isEqualTo: typeSport)
          .orderBy('date', descending: true)
          .limit(1)
          .get();
      return Matches.fromJson(querySnapshot.docs.first.data());
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getMatchById(String id, String typeSport) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> querySnapshot =
          await _firestore.collection("MATCH").doc(id).get();
      return {
        "BASKETBALL":
            Basket.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "FOOTBALL":
            Football.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "VOLLEYBALL":
            Volleyball.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "JEUX_ESPRIT":
            JeuxEsprit.fromJson(querySnapshot.data() as Map<String, dynamic>)
      }[typeSport];
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> likerMatch(String matchId, String typeSport) async {
    try {
      String email = FirebaseAuth.instance.currentUser!.email!;

      // Récupérer l'utilisateur avec l'email
      QuerySnapshot userSnapshot = await _firestore
          .collection("USER")
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (userSnapshot.docs.isEmpty) return null;

      Map<String, dynamic> userData =
          userSnapshot.docs.first.data() as Map<String, dynamic>;

      DocumentReference matchDoc = _firestore.collection("MATCH").doc(matchId);

      await matchDoc.update(
        {
          'likers': FieldValue.arrayUnion([userData])
        },
      );

      DocumentSnapshot querySnapshot = await matchDoc.get();

      return {
        "BASKETBALL":
            Basket.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "FOOTBALL":
            Football.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "VOLLEYBALL":
            Volleyball.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "JEUX_ESPRIT":
            JeuxEsprit.fromJson(querySnapshot.data() as Map<String, dynamic>)
      }[typeSport];
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> removeLikeMatch(String matchId, typeSport) async {
    try {
      String email = FirebaseAuth.instance.currentUser!.email!;

      // Récupérer l'utilisateur avec l'email
      QuerySnapshot userSnapshot = await _firestore
          .collection("USER")
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (userSnapshot.docs.isEmpty) return null;

      Map<String, dynamic> userData =
          userSnapshot.docs.first.data() as Map<String, dynamic>;

      DocumentReference matchDoc = _firestore.collection("MATCH").doc(matchId);

      await matchDoc.update(
        {
          'likers': FieldValue.arrayRemove([userData])
        },
      );

      DocumentSnapshot querySnapshot = await matchDoc.get();

      return {
        "BASKETBALL":
            Basket.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "FOOTBALL":
            Football.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "VOLLEYBALL":
            Volleyball.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "JEUX_ESPRIT":
            JeuxEsprit.fromJson(querySnapshot.data() as Map<String, dynamic>)
      }[typeSport];
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> addCommentMatch(
      String matchId, String content, typeSport) async {
    try {
      String email = FirebaseAuth.instance.currentUser!.email!;

      // Récupérer l'utilisateur avec l'email
      QuerySnapshot userSnapshot = await _firestore
          .collection("USER")
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (userSnapshot.docs.isEmpty) return null;

      Map<String, dynamic> userData =
          userSnapshot.docs.first.data() as Map<String, dynamic>;

      DocumentReference matchDoc = _firestore.collection("MATCH").doc(matchId);

      Commentaire commentaire = Commentaire(
          id: DateTime.now().toString(),
          content: content,
          date: DateTime.now(),
          user: Utilisateur.fromJson(userData),
          likes: 0,
          dislikes: 0);
      await matchDoc.update(
        {
          'comments': FieldValue.arrayUnion([commentaire.toJson()])
        },
      );

      DocumentSnapshot querySnapshot = await matchDoc.get();
//  ${(querySnapshot.data()! as Map<String, dynamic>)["equipeA"].nom}
      // Envoyer une notification à chaque token actif
      await _notificationService.sendAllNotification(
          "Nouveau commentaire match",
          "${commentaire.user.prenom + commentaire.user.nom.toUpperCase()} a commenté sur le match.");

      return {
        "BASKETBALL":
            Basket.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "FOOTBALL":
            Football.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "VOLLEYBALL":
            Volleyball.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "JEUX_ESPRIT":
            JeuxEsprit.fromJson(querySnapshot.data() as Map<String, dynamic>)
      }[typeSport];
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> removeCommentMatch(
      String matchId, Commentaire commentaire, String typeSport) async {
    try {
      DocumentReference matchDoc = _firestore.collection("MATCH").doc(matchId);

      await matchDoc.update(
        {
          'comments': FieldValue.arrayRemove([commentaire.toJson()])
        },
      );

      DocumentSnapshot querySnapshot = await matchDoc.get();

      return {
        "BASKETBALL":
            Basket.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "FOOTBALL":
            Football.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "VOLLEYBALL":
            Volleyball.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "JEUX_ESPRIT":
            JeuxEsprit.fromJson(querySnapshot.data() as Map<String, dynamic>)
      }[typeSport];
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> updateStatistique(
      String matchId, String libelle, int value, String typeSport) async {
    try {
      DocumentReference matchDoc = _firestore.collection("MATCH").doc(matchId);
      await matchDoc.update(
        {"statistiques.$libelle": FieldValue.increment(value)},
      );

      DocumentSnapshot querySnapshot = await matchDoc.get();

      return {
        "BASKETBALL":
            Basket.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "FOOTBALL":
            Football.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "VOLLEYBALL":
            Volleyball.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "JEUX_ESPRIT":
            JeuxEsprit.fromJson(querySnapshot.data() as Map<String, dynamic>)
      }[typeSport];
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> updateFinPeriode(String matchId, String libelle, int value1,
      int value2, String typeSport) async {
    try {
      DocumentReference matchDoc = _firestore.collection("MATCH").doc(matchId);
      await matchDoc.update(
        {"statistiques.${libelle}A": FieldValue.increment(value1)},
      );
      await matchDoc.update(
        {"statistiques.${libelle}B": FieldValue.increment(value2)},
      );

      DocumentSnapshot querySnapshot = await matchDoc.get();

      return {
        "BASKETBALL":
            Basket.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "FOOTBALL":
            Football.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "VOLLEYBALL":
            Volleyball.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "JEUX_ESPRIT":
            JeuxEsprit.fromJson(querySnapshot.data() as Map<String, dynamic>)
      }[typeSport];
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> updateBasketScore(
      String matchId, String libelle, int value1, int value2) async {
    try {
      DocumentReference matchDoc = _firestore.collection("MATCH").doc(matchId);

      await matchDoc.update({
        "statistiques.${libelle}A": value1,
        "statistiques.${libelle}B": value2,
      });

      DocumentSnapshot querySnapshot = await matchDoc.get();
      Map<String, dynamic> data = querySnapshot.data() as Map<String, dynamic>;

      int premierA = data['statistiques']['1erA'] ?? 0;
      int deuxiemeA = data['statistiques']['2emeA'] ?? 0;
      int troisiemeA = data['statistiques']['3emeA'] ?? 0;
      int quatriemeA = data['statistiques']['4emeA'] ?? 0;

      int premierB = data['statistiques']['1erB'] ?? 0;
      int deuxiemeB = data['statistiques']['2emeB'] ?? 0;
      int troisiemeB = data['statistiques']['3emeB'] ?? 0;
      int quatriemeB = data['statistiques']['4emeB'] ?? 0;

      int scoreEquipeA = premierA + deuxiemeA + troisiemeA + quatriemeA;
      int scoreEquipeB = premierB + deuxiemeB + troisiemeB + quatriemeB;

      await matchDoc.update({
        "scoreEquipeA": scoreEquipeA,
        "scoreEquipeB": scoreEquipeB,
      });

      querySnapshot = await matchDoc.get();

      return Basket.fromJson(querySnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> updateVolleyScore(
      String matchId, String libelle, int value1, int value2) async {
    try {
      DocumentReference matchDoc = _firestore.collection("MATCH").doc(matchId);

      await matchDoc.update({
        "statistiques.${libelle}A": value1,
        "statistiques.${libelle}B": value2,
      });

      DocumentSnapshot querySnapshot = await matchDoc.get();
      Map<String, dynamic> data = querySnapshot.data() as Map<String, dynamic>;

      int set1A = data['statistiques']['Set1A'] ?? 0;
      int set2A = data['statistiques']['Set2A'] ?? 0;
      int set3A = data['statistiques']['Set3A'] ?? 0;

      int set1B = data['statistiques']['Set1B'] ?? 0;
      int set2B = data['statistiques']['Set2B'] ?? 0;
      int set3B = data['statistiques']['Set3B'] ?? 0;

      int setsWonA = 0;
      int setsWonB = 0;

      if (set1A > set1B)
        setsWonA++;
      else if (set1B > set1A) setsWonB++;
      if (set2A > set2B)
        setsWonA++;
      else if (set2B > set2A) setsWonB++;
      if (set3A > set3B)
        setsWonA++;
      else if (set3B > set3A) setsWonB++;

      await matchDoc.update({
        "scoreEquipeA": setsWonA,
        "scoreEquipeB": setsWonB,
      });

      querySnapshot = await matchDoc.get();

      return Volleyball.fromJson(querySnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> updateJEScore(
      String matchId, String libelle, int value1, int value2) async {
    try {
      DocumentReference matchDoc = _firestore.collection("MATCH").doc(matchId);

      await matchDoc.update({
        "statistiques.${libelle}A": value1,
        "statistiques.${libelle}B": value2,
      });

      DocumentSnapshot querySnapshot = await matchDoc.get();
      Map<String, dynamic> data = querySnapshot.data() as Map<String, dynamic>;

      int miTemp1A = data['statistiques']['miTemp1A'] ?? 0;
      int miTemp2A = data['statistiques']['miTemp2A'] ?? 0;

      int miTemp1B = data['statistiques']['miTemp1B'] ?? 0;
      int miTemp2B = data['statistiques']['miTemp2B'] ?? 0;

      int scoreEquipeA = miTemp1A + miTemp2A;
      int scoreEquipeB = miTemp1B + miTemp2B;

      await matchDoc.update({
        "scoreEquipeA": scoreEquipeA,
        "scoreEquipeB": scoreEquipeB,
      });

      querySnapshot = await matchDoc.get();

      return JeuxEsprit.fromJson(querySnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> addButeur(String matchId, Joueur joueur, int minute,
      String libelleScore, String libelleBut, String typeSport,
      [int increment = 1]) async {
    try {
      DocumentReference matchDoc = _firestore.collection("MATCH").doc(matchId);
      But but = But(
          joueur: joueur,
          id: DateTime.now().toString(),
          date: DateTime.now(),
          minute: minute,
          point: increment);
      await matchDoc.update(
        {
          libelleBut: FieldValue.arrayUnion([but.toJson()]),
          libelleScore: FieldValue.increment(increment)
        },
      );

      DocumentSnapshot querySnapshot = await matchDoc.get();

      return {
        "BASKETBALL":
            Basket.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "FOOTBALL":
            Football.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "VOLLEYBALL":
            Volleyball.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "JEUX_ESPRIT":
            JeuxEsprit.fromJson(querySnapshot.data() as Map<String, dynamic>)
      }[typeSport];
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> removeButeur(
    String matchId,
    But buteur,
    String team,
    String typeSport,
  ) async {
    try {
      DocumentReference matchDoc = _firestore.collection("MATCH").doc(matchId);

      WriteBatch batch = _firestore.batch();

      // Supprimer le buteur et mettre à jour le score
      batch.update(matchDoc, {
        team == 'A' ? 'buteursA' : 'buteursB':
            FieldValue.arrayRemove([buteur.toJson()]),
        team == 'A' ? 'scoreEquipeA' : 'scoreEquipeB':
            FieldValue.increment(-buteur.point),
      });

      // Mise à jour spécifique au Basketball
      if (typeSport == "BASKETBALL") {
        if (buteur.point == 1) {
          batch.update(matchDoc, {
            team == 'A' ? 'statistiques.point1A' : 'statistiques.point1B':
                FieldValue.increment(-buteur.point),
          });
        } else if (buteur.point == 2) {
          batch.update(matchDoc, {
            team == 'A' ? 'statistiques.point2A' : 'statistiques.point2B':
                FieldValue.increment(-buteur.point),
          });
        } else if (buteur.point == 3) {
          batch.update(matchDoc, {
            team == 'A' ? 'statistiques.point3A' : 'statistiques.point3B':
                FieldValue.increment(-buteur.point),
          });
        } else {
        }
      }

      // Appliquer toutes les mises à jour
      try {
        await batch.commit();
      } catch (e) {
      }
      // Récupérer le document mis à jour
      DocumentSnapshot querySnapshot = await matchDoc.get();

      return {
        "BASKETBALL":
            Basket.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "FOOTBALL":
            Football.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "VOLLEYBALL":
            Volleyball.fromJson(querySnapshot.data() as Map<String, dynamic>),
        "JEUX_ESPRIT":
            JeuxEsprit.fromJson(querySnapshot.data() as Map<String, dynamic>),
      }[typeSport];
    } catch (e) {
      return null;
    }
  }

  Future<List<Matches>> getListMatchFootball(String typeSport) async {
    List<Matches> list = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection("MATCH")
          .where("sport", isEqualTo: typeSport)
          // .limit(2)
          .get();
      List<Map<String, dynamic>> data =
          querySnapshot.docs.map((doc) => doc.data()).toList();
      for (var d in data) {
        list.add(Matches.fromJson(d));
      }

      return list;
    } catch (e) {
      return [];
    }
  }

  Future<List<Matches>> getAllMatch() async {
    List<Matches> list = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection("MATCH")
          .orderBy("date", descending: true)
          .get();
      List<Map<String, dynamic>> data =
          querySnapshot.docs.map((doc) => doc.data()).toList();
      for (var d in data) {
        list.add(Matches.fromJson(d));
      }

      return list;
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getFootballById(String id) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _firestore.collection("MATCH").where("id", isEqualTo: id).get();
      Map<String, dynamic> football = querySnapshot.docs.first.data();
      return football;
    } catch (e) {
      return {};
    }
  }

  Future<void> ajouterMembre(Membre membre) async {
    CollectionReference membres =
        FirebaseFirestore.instance.collection('MEMBRES');
    try {
      await membres.doc(membre.id).set({
        'image': membre.image,
        'nom': membre.nom,
        'role': membre.role,
        'sport': membre.sport.name,
        'id': membre.id
      });
    } catch (e) {
    }
  }

  Future<List<Membre>> getMembresParSport(String sport) async {
    CollectionReference membres =
        FirebaseFirestore.instance.collection('MEMBRES');

    try {
      QuerySnapshot querySnapshot =
          await membres.where('sport', isEqualTo: sport).get();

      // Parcourir les documents et créer une liste d'objets Membre
      return querySnapshot.docs.map((doc) {
        return Membre.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> supprimerMembre(String membreId) async {
    CollectionReference membres =
        FirebaseFirestore.instance.collection('MEMBRES');

    try {
      // Récupérer le document du membre avant de le supprimer
      DocumentSnapshot membreSnapshot = await membres.doc(membreId).get();

      if (membreSnapshot.exists) {
        String imageUrl = membreSnapshot['image'] ?? '';

        if (imageUrl.isNotEmpty) {
          try {
            Reference imageRef = FirebaseStorage.instance.refFromURL(imageUrl);

            await imageRef.delete();
          } catch (e) {
          }
        }

        await membres.doc(membreId).delete();
      } else {
      }
    } catch (e) {
    }
  }

  Future<void> modifierMembre(Membre membre) async {
    try {
      // Référence à la collection des membres
      CollectionReference membresCollection = _firestore.collection('MEMBRES');

      // Mise à jour du membre dans Firestore
      await membresCollection.doc(membre.id).update({
        'nom': membre.nom,
        'image': membre.image,
        'role': membre.role,
        'sport': membre.sport.name,
      });

    } catch (e) {
      throw e; // Tu peux gérer l'erreur comme tu le souhaites
    }
  }
}
