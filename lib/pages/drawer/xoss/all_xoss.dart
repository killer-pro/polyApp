import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/enums/statut_xoss.dart';
import 'package:new_app/models/xoss.dart';
import 'package:new_app/pages/drawer/drawer.dart';
import 'package:new_app/pages/drawer/xoss/create_xoss.dart';
import 'package:new_app/pages/drawer/xoss/detail_xoss.dart';
import 'package:new_app/pages/home/navbar.dart';
import 'package:new_app/pages/drawer/xoss/historique_xoss.dart';
import 'package:new_app/services/xoss_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/app_loader.dart';

class AllXoss extends StatelessWidget {
  AllXoss({Key? key}) : super(key: key);
  XossService _xossService = XossService();
  final ValueNotifier<List<Xoss>> _xossProvider = ValueNotifier<List<Xoss>>([]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   forceMaterialTransparency: true,
        // ),
        // extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: FutureBuilder<List<Xoss>>(
            future: _xossService.getAllXossOfUserByEmail(
                FirebaseAuth.instance.currentUser!.email!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return AppLoader();
              } else if (snapshot.hasError) {
                return Text('Erreur lors de la récupération des données');
              } else {
                List<Xoss> xoss = snapshot.data ?? [];

                _xossProvider.value = xoss;
                double totalMontant =
                    xoss.fold(0, (sum, item) => sum + item.montant);

                Text(
                  '$totalMontant Fcfa',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                );

                return Column(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(250, 242, 230, 1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Stack(
                        clipBehavior: Clip
                            .none, // Permet à l'image de sortir du Container
                        children: [
                          Positioned(
                            bottom:
                                -78, // Positionne l'image en dehors du bas du Container
                            left: 0,
                            right: 0,
                            child: Image.asset(
                              'assets/images/xoss/xoss_card.png',
                              width: 100, // Spécifiez une largeur si nécessaire
                            ),
                          ),
                          Positioned(
                            bottom:
                                0, // Positionne l'image en dehors du bas du Container
                            left: -100,
                            right: 0,
                            child: Column(
                              children: [
                                if (_xossProvider.value != [])
                                  Text(
                                    _xossProvider.value.first.user!.prenom +
                                        _xossProvider.value.first.user!.nom
                                            .toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold),
                                  ),
                                SizedBox(height: 8),
                                if (_xossProvider.value != [])
                                  Text(
                                    '$totalMontant FCFA',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        changerPage(context, HistoriqueXoss());
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(244, 171, 90, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      child: const Text(
                        'Historique',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(width: 15),
                        Text(
                          'Mes khoss',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () {
                                changerPage(context, CreateXoss());
                              },
                              child: Icon(Icons.add),
                            ))
                      ],
                    ),
                    SizedBox(height: 16),
                    for (var xoss in _xossProvider.value)
                      xossWidget(context, xoss),
                  ],
                );
              }
            }),
      ),
    ));
  }
}

Widget xossWidget(BuildContext context, Xoss xoss) {
  return GestureDetector(
      onTap: () => changerPage(context, DetailXoss(xoss.id)),
      child: Padding(
          padding: EdgeInsets.all(20),
          child: Container(
              // height: MediaQuery.sizeOf(context).height * 0.25,
              width: double.maxFinite,
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          " Xossna",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        Image.asset(xoss.statut.toString().split(".").last ==
                                StatutXoss.PAYEE.toString().split(".").last
                            ? "assets/images/xoss/Ellipse_green.png"
                            : xoss.statut.toString().split(".").last ==
                                    StatutXoss.ATTENTE
                                        .toString()
                                        .split(".")
                                        .last
                                ? "assets/images/xoss/Ellipse_white.png"
                                : "assets/images/xoss/Ellipse_red.png")
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(127, 127, 127, 1),
                              borderRadius: BorderRadius.circular(10)),
                          width: MediaQuery.sizeOf(context).width * 0.45,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          // height: 110,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Scrollbar(
                              trackVisibility: true,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    for (var produit in xoss.produit)
                                      Row(
                                        children: [
                                          SizedBox(width: 20),
                                          Image.asset(
                                            "assets/images/xoss/Ellipse_white.png",
                                          ),
                                          SizedBox(width: 10),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            child: Text(
                                              produit,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          )
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: Text(
                            "${xoss.montant} FCFA",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.01,
                    ),
                    Text(
                      dateCustomformat(xoss.date),
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    )
                  ],
                ),
              ))));
}
