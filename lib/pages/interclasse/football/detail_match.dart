import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/basket.dart';
import 'package:new_app/models/football.dart';
import 'package:new_app/models/jeux_esprit.dart';
import 'package:new_app/models/match.dart';
import 'package:new_app/models/volleyball.dart';
import 'package:new_app/services/sport_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:new_app/widgets/comment_widget.dart';
import 'package:new_app/widgets/delete_confirmed_dialog.dart';
import 'package:new_app/widgets/reusable_comment_input.dart';

// ignore: must_be_immutable
class DetailMatchScreen extends StatefulWidget {
  String id;
  String typeSport;
  DetailMatchScreen(this.id, this.typeSport, {super.key});

  @override
  State<DetailMatchScreen> createState() =>
      // ignore: no_logic_in_create_state
      _DetailMatchScreenState(id, typeSport);
}

class _DetailMatchScreenState extends State<DetailMatchScreen> {
  final SportService _sportService = SportService();
  final String _id;
  final String _typeSport;
  _DetailMatchScreenState(this._id, this._typeSport);

  final ValueNotifier<bool> _isPressCommment = ValueNotifier<bool>(false);
  final ValueNotifier<dynamic> _match = ValueNotifier<dynamic>(null);

  final TextEditingController _commentairController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: jauneClair,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Détail du match",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<dynamic>(
            future: _sportService.getMatchById(_id, _typeSport),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return AppLoader();
              } else if (snapshot.hasError) {
                return Text('Erreur lors de la récupération du rôle');
              } else {
                final match = snapshot.data;
                _match.value = match;
                return match == null
                    ? AppLoader()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(color: jauneClair),
                            padding: EdgeInsets.only(bottom: 20),
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                // Match Information
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        CircleAvatar(
                                            radius: MediaQuery.sizeOf(context)
                                                .width *
                                                0.1,
                                            backgroundImage: ResizeImage(
                                              CachedNetworkImageProvider(
                                                match.equipeA.logo,
                                              ),
                                              width: 210,
                                            )
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          match.equipeA.nom,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "VS",
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                              radius: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.1,
                                              backgroundImage: ResizeImage(
                                                  CachedNetworkImageProvider(
                                                    match.equipeB.logo,
                                                  ),
                                                width: 210,
                                                )
                                            ),
                                          SizedBox(height: 10),
                                          Text(
                                            match.equipeB.nom,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 20),
                                // Score
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 35),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 40),
                                  decoration: BoxDecoration(
                                    color: orange,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                match.scoreEquipeA.toString(),
                                                style: TextStyle(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                              SingleChildScrollView(
                                                  child: Column(
                                                children: [
                                                  for (var butteur
                                                      in match.buteursA!)
                                                    Text(
                                                      "${butteur.joueur.nom} (${butteur.minute}')",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                ],
                                              ))
                                            ],
                                          ),
                                          Text(
                                            "-",
                                            style: TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                match.scoreEquipeB.toString(),
                                                style: TextStyle(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                              Column(
                                                children: [
                                                  for (var butteur
                                                      in match.buteursB!)
                                                    Text(
                                                      "${butteur.joueur.nom} (${butteur.minute}')",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          // Statistiques
                          Text(
                            "Statistiques",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          // Statistics Row
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Align(
                                alignment: Alignment.center,
                                child:SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child:  Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Carton Equipe 1
                                    if (_typeSport == "FOOTBALL")
                                      Row(children: [
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.yellow,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Text(
                                                    match.statistiques[
                                                            "yellowCardA"]
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Text(
                                                    match.statistiques[
                                                            "redCardA"]
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Text("Cartons"),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 16,
                                        ),
                                      ]),
                                    // Statistics Icons

                                    if (_typeSport == "FOOTBALL")
                                      statisticFootball(match),

                                    if (_typeSport == "FOOTBALL")
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 16,
                                          ),
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.yellow,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: Text(
                                                      match.statistiques[
                                                              "yellowCardB"]
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: Text(
                                                      match.statistiques[
                                                              "redCardB"]
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              Text("Cartons"),
                                            ],
                                          )
                                        ],
                                      ),

                                    if (_typeSport == "BASKETBALL")
                                      statisticBasket(match),

                                    if (_typeSport == "VOLLEYBALL")
                                      statisticVolleyball(match),
                                    if (_typeSport == "JEUX_ESPRIT")
                                      statisticJeuxEsprit(match),
                                  ],
                             ) )),
                          ),
                          SizedBox(height: 20),

                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 100.0),
                            child: Divider(
                              color: Colors.black,
                            ),
                          ),
                          // SECTION LIKE
                          Row(
                            children: [
                              ValueListenableBuilder<dynamic>(
                                  valueListenable: _match,
                                  builder: (context, matchProvider, child) {
                                    return Row(
                                      children: [
                                        IconButton(
                                            icon: Icon(
                                              Icons.thumb_up,
                                              color: _match.value!.likers!.any(
                                                      (liker) =>
                                                          liker!.email ==
                                                          FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .email)
                                                  ? Colors.blue
                                                  : Colors.grey,
                                            ),
                                            onPressed: () async {
                                              if (_match.value!.likers!.any(
                                                  (liker) =>
                                                      liker!.email ==
                                                      FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .email)) {
                                                _match.value =
                                                    await _sportService
                                                        .removeLikeMatch(
                                                            match.id, _typeSport);
                                              } else {
                                                _match.value =
                                                    await _sportService
                                                        .likerMatch(match.id, _typeSport);
                                              }
                                            }),
                                        Text(_match.value!.likers!.length
                                            .toString())
                                      ],
                                    );
                                  }),
                              IconButton(
                                  onPressed: () {
                                    _isPressCommment.value =
                                        !_isPressCommment.value;
                                  },
                                  icon: Icon(
                                    Icons.message,
                                    color: Colors.grey,
                                  ))
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          // SECTION COMMENTAIRE
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ValueListenableBuilder<bool>(
                                    valueListenable: _isPressCommment,
                                    builder: (context, passwordsMatch, child) {
                                      return passwordsMatch
                                          ? reusableCommentInput("Commenter",
                                              _commentairController, (value) {
                                              return null;
                                            }, () async {
                                              _match.value = await _sportService
                                                  .addCommentMatch(
                                                      match.id,
                                                      _commentairController
                                                          .value.text, _typeSport);
                                              _isPressCommment.value =
                                                  !_isPressCommment.value;
                                            })
                                          : Container(
                                              height: 0,
                                            );
                                    }),

                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Commentaires",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    )),
                                SizedBox(height: 10),
                                // Comment 1
                                ValueListenableBuilder<dynamic>(
                                    valueListenable: _match,
                                    builder: (context, matchProvider, child) {
                                      return Column(
                                        children: [
                                          for (var comment in _match
                                              .value!.comments!.reversed)
                                            GestureDetector(
                                              onLongPress: () async {
                                                if (comment.user.email ==
                                                    FirebaseAuth.instance
                                                        .currentUser!.email) {
                                                  bool confirm =
                                                      await showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return deleteConfirmedDialog(
                                                          context,
                                                          "Voulez-vous vraiment supprimer ce commentaire ?");
                                                    },
                                                  );

                                                  if (confirm) {
                                                    _match.value =
                                                        await _sportService
                                                            .removeCommentMatch(
                                                                match.id,
                                                                comment, _typeSport);
                                                  }
                                                } else {}
                                              },
                                              child: CommentWidget(
                                                photo: comment.user.photo!,
                                                name: comment.user.prenom +
                                                    comment.user.nom
                                                        .toUpperCase(),
                                                comment: comment.content,
                                                timeAgo: comment.date,
                                              ),
                                            )
                                        ],
                                      );
                                    })
                              ],
                            ),
                          ),
                        ],
                      );
              }
            }),
      ),
    );
  }
}

Widget statisticCard(IconData icon, String libelle, int value1, int value2) {
  return Column(
    children: [
      Icon(icon, size: 32),
      Text(libelle),
      Text("$value1 - $value2"),
    ],
  );
}

Widget statisticFootball(Football match) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      statisticCard(
          Icons.sports,
          "tirs cadrés",
          match.statistiques["tirsCadresA"]!,
          match.statistiques["tirsCadresB"]!),
      SizedBox(
        width: 16,
      ),
      statisticCard(Icons.sports_soccer, "tirs", match.statistiques["tirsA"]!,
          match.statistiques["tirsB"]!),
      SizedBox(
        width: 16,
      ),
      statisticCard(Icons.error_outline, "fautes",
          match.statistiques["fautesA"]!, match.statistiques["fautesB"]!),
    ],
  );
}

Widget statisticBasket(Basket match) {
  return   Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      statisticCard(Icons.sports_basketball, "1er", match.statistiques["1erA"]!,
          match.statistiques["1erB"]!),
      SizedBox(
        width: 30,
      ),
      statisticCard(Icons.sports_basketball, "2ème",
          match.statistiques["2emeA"]!, match.statistiques["2emeB"]!),
      SizedBox(
        width: 30,
      ),
      statisticCard(Icons.sports_basketball, "3ème",
          match.statistiques["3emeA"]!, match.statistiques["3emeB"]!),
      SizedBox(
        width: 30,
      ),
      statisticCard(Icons.sports_basketball, "4ème",
          match.statistiques["4emeA"]!, match.statistiques["4emeB"]!),
    ],
   );
}

Widget statisticVolleyball(Volleyball match) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      statisticCard(Icons.sports_volleyball, "Set 1",
          match.statistiques["Set1A"]!, match.statistiques["Set1B"]!),
      SizedBox(
        width: 30,
      ),
      statisticCard(Icons.sports_volleyball, "Set 2",
          match.statistiques["Set2A"]!, match.statistiques["Set2B"]!),
      SizedBox(
        width: 30,
      ),
      statisticCard(Icons.sports_volleyball, "Set 3",
          match.statistiques["Set3A"]!, match.statistiques["Set3B"]!),
    ],
  );
}

Widget statisticJeuxEsprit(JeuxEsprit match) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      statisticCard(
        Icons.hourglass_bottom,
        "Mi-temp 1",
        match.statistiques["miTemp1A"]!,
        match.statistiques["miTemp1B"]!,
      ),
      SizedBox(
        width: 30,
      ),
      statisticCard(
        Icons.hourglass_full,
        "Mi-temp 2",
        match.statistiques["miTemp2A"]!,
        match.statistiques["miTemp2B"]!,
      ),
      SizedBox(
        width: 30,
      ),
    ],
  );
}
