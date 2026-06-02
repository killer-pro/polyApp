import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/jeu.dart';
import 'package:new_app/models/joueur.dart';
import 'package:new_app/models/session_jeu.dart';
import 'package:new_app/services/jeu_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/alerte_message.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:new_app/widgets/delete_confirmed_dialog.dart';
import 'package:new_app/widgets/empty_state_widget.dart';

import '../../../models/joueur_jeu.dart';

class GameScreen extends StatefulWidget {
  final String id;
  GameScreen(this.id, {super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late JeuService _jeuService;
  Jeu? _jeu;
  bool _hasError = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _jeuService = JeuService();
    _fetchJeu();
    _userId = FirebaseAuth.instance.currentUser?.email;
  }

  Future<void> _fetchJeu() async {
    setState(() => _hasError = false);
    try {
      Jeu? jeu = await _jeuService.getJeuId(widget.id);
      setState(() {
        _jeu = jeu;
        if (jeu == null) _hasError = true;
      });
    } catch (e) {
      setState(() => _hasError = true);
    }
  }

  Future<void> _createSession(String lieu) async {
    try {
      Jeu? jeu = await _jeuService.postSessionJeu(widget.id, lieu);
      if (jeu != null) {
        alerteMessageWidget(
          context,
          "Session créée avec succès.",
          AppColors.success,
        );
        _fetchJeu();
      }
    } catch (e) {
      alerteMessageWidget(
        context,
        "Erreur lors de la création de la session.",
        AppColors.echec,
      );
    }
  }

  Future<void> _deleteSession(SessionJeu session) async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return deleteConfirmedDialog(
          context,
          "Voulez-vous vraiment supprimer cette session ?",
        );
      },
    );

    if (confirm) {
      try {
        await _jeuService.deleteSessionJeu(widget.id, session);
        alerteMessageWidget(
          context,
          "Session supprimée avec succès.",
          AppColors.success,
        );
        _fetchJeu(); // Recharger les sessions
      } catch (e) {
        alerteMessageWidget(
          context,
          "Erreur lors de la suppression de la session.",
          AppColors.echec,
        );
      }
    }
  }

  List<SessionJeu> _sortSessions(List<SessionJeu> sessions) {
    sessions.sort((a, b) => b.date.compareTo(a.date));
    return sessions;
  }

  bool _isUserInSession(SessionJeu session) {
    return session.joueurs.any((joueur) => joueur.id == _userId);
  }

  Future<void> _toggleSession(SessionJeu session) async {
    if (_isUserInSession(session)) {
      JoueurJeu joueur =
          session.joueurs.firstWhere((joueur) => joueur.id == _userId!);
      await _quitterSession(session, joueur);
    } else {
      await _rejoindreSession(session);
    }
  }

  Future<void> _quitterSession(SessionJeu session, JoueurJeu joueur) async {
    try {
      await _jeuService.quitterSessionJeu(widget.id, session.id);
      alerteMessageWidget(
        context,
        "Vous avez quitté la session.",
        AppColors.success,
      );
      _fetchJeu();
    } catch (e) {
      alerteMessageWidget(
        context,
        "Erreur lors de la sortie de la session.",
        AppColors.echec,
      );
    }
  }

  Future<void> _rejoindreSession(SessionJeu session) async {
    try {
      Jeu? jeu = await _jeuService.rejoindreSessionJeu(widget.id, session.id);
      if (jeu == null) {
        alerteMessageWidget(
          context,
          "Vous êtes déjà dans la session.",
          AppColors.echec,
        );
      } else {
        alerteMessageWidget(
          context,
          "Bienvenue dans la session.",
          AppColors.success,
        );
        _fetchJeu();
      }
    } catch (e) {
      alerteMessageWidget(
        context,
        "Erreur lors de la jonction de la session.",
        AppColors.echec,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
      ),
      extendBodyBehindAppBar: true,
      body: _hasError
          ? ErrorStateWidget(
              message: 'Impossible de charger ce jeu.',
              onRetry: _fetchJeu,
            )
          : _jeu == null
          ? Center(child: AppLoader())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 310,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/homepage/jeux_top_bg.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(height: 70),
                          Center(
                            child: Image.network(
                              _jeu!.logo,
                              height: 150,
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: Text(
                              _jeu!.nom,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Règles:", style: TextStyle(fontSize: 18)),
                        SizedBox(height: 10),
                        Text(
                          _jeu!.regle,
                          style: TextStyle(
                              fontSize: 12, fontFamily: 'InterRegular'),
                        ),
                        SizedBox(height: 10),
                        Text("Sessions:",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        ..._sortSessions(_jeu!.sessions).where((session) {
                          DateTime now = DateTime.now();
                          DateTime sessionDate = session.date;

                          Duration difference = now.difference(sessionDate);

                          return difference.inHours < 24;
                        }).map((session) {
                          return ExpansionTile(
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            title: Text(
                              "Session à ${session.lieu} ${timeAgoCustom(session.date)}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            children: [
                              Text(
                                  "Il y a ${session.joueurs.length} joueurs en attente à ${session.lieu}",
                                  style: TextStyle(fontSize: 16)),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: session.joueurs.map((joueur) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10),
                                        Text(
                                            "${joueur.prenom} ${joueur.nom.toUpperCase()}"),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      await _toggleSession(session);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: grisClair,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      _isUserInSession(session)
                                          ? 'Quitter'
                                          : 'Rejoindre',
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.black),
                                    ),
                                  ),
                                  Spacer(),
                                  if (session.creatorId == _userId)
                                    IconButton(
                                      onPressed: () {
                                        _deleteSession(session);
                                      },
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                    ),
                                ],
                              ),
                            ],
                          );
                        }).toList(),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        TextEditingController _lieuController =
                            TextEditingController();

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Entrer le lieu de la session'),
                              content: TextField(
                                controller: _lieuController,
                                decoration: InputDecoration(hintText: 'Lieu'),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    String lieu = _lieuController.text.trim();
                                    if (lieu.isNotEmpty) {
                                      _createSession(lieu);
                                      Navigator.of(context).pop();
                                    } else {
                                      alerteMessageWidget(
                                          context,
                                          "Veuillez entrer un lieu.",
                                          AppColors.echec);
                                    }
                                  },
                                  child: Text('Valider'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Créer une session',
                          style: TextStyle(fontSize: 15, color: Colors.black)),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
