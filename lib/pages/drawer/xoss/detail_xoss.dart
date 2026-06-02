import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/enums/statut_xoss.dart';
import 'package:new_app/models/xoss.dart';
import 'package:new_app/pages/drawer/xoss/page_boutiquier.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/services/xoss_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/app_loader.dart';

class DetailXoss extends StatefulWidget {
  String id;
  DetailXoss(this.id, {super.key});

  @override
  State<DetailXoss> createState() => _DetailXossState();
}

class _DetailXossState extends State<DetailXoss> {
  final XossService _xossService = XossService();

  ValueNotifier<Xoss?> _xossProvider = ValueNotifier(null);

  final UserService _userService = UserService();

  String? userId;
  bool isAdmin = false;

  Future<void> _checkUserRole() async {
    try {
      // Récupérer l'utilisateur connecté via FirebaseAuth
      var user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userId = user.email;

        String? role = await _userService.getUserRole(userId!);

        if (role == 'ADMIN_PSHOP') {
          setState(() {
            isAdmin = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Erreur lors de la vérification du rôle : $e");
    }
  }

  @override
  void initState() {
    super.initState();

    _checkUserRole();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: EdgeInsets.all(MediaQuery.sizeOf(context).height * 0.02),
          child: FutureBuilder<Xoss?>(
              future: _xossService.getXossId(widget.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return AppLoader();
                } else if (snapshot.hasError) {
                  return Text('Erreur lors de la récupération des données');
                }
                final xoss = snapshot.data;
                _xossProvider.value = xoss;
                return xoss == null
                    ? AppLoader()
                    : Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${_xossProvider.value!.versement - _xossProvider.value!.montant} FCFA",
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.sizeOf(context).height *
                                            0.03),
                              ),
                              CircleAvatar(
                                backgroundColor: AppColors.gray,
                                backgroundImage: CachedNetworkImageProvider(
                                    _xossProvider.value!.user!.photo!),
                              )
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.03,
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: AppColors.gray,
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Montant total"),
                                    Text("${_xossProvider.value!.montant} FCFA")
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.03,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Montant versé"),
                                    Text(
                                        "${_xossProvider.value!.versement} FCFA")
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.03,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Statut"),
                                    Text(
                                      _xossProvider.value!.statut
                                          .toString()
                                          .split(".")
                                          .last,
                                      style: TextStyle(
                                          color: _xossProvider.value!.statut
                                                      .toString()
                                                      .split(".")
                                                      .last ==
                                                  StatutXoss.PAYEE
                                                      .toString()
                                                      .split(".")
                                                      .last
                                              ? AppColors.success
                                              : _xossProvider.value!.statut
                                                          .toString()
                                                          .split(".")
                                                          .last ==
                                                      StatutXoss.ATTENTE
                                                          .toString()
                                                          .split(".")
                                                          .last
                                                  ? Colors.yellow
                                                  : Colors.red),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.03,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Date"),
                                    Text(dateCustomformat(
                                        _xossProvider.value!.date))
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.03,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Produits"),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        for (var produit
                                            in _xossProvider.value!.produit)
                                          Text(produit)
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.03,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("ID"),
                                    Text(_xossProvider.value!.id)
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.03,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.02,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (_xossProvider.value!.statut
                                          .toString()
                                          .split(".")
                                          .last !=
                                      StatutXoss.PAYEE
                                          .toString()
                                          .split(".")
                                          .last &&
                                  isAdmin) ...[
                                ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.yellow),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title:
                                                Text("Confirmation versement"),
                                            content: Text(
                                                "Voulez-vous confirmer le paiement total."),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text("Annuler"),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  _xossProvider.value =
                                                      await _xossService
                                                          .updateXoss(
                                                              widget.id,
                                                              "statut",
                                                              StatutXoss.PAYEE
                                                                  .toString()
                                                                  .split(".")
                                                                  .last);
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            XossListPage()),
                                                  );
                                                },
                                                child: Text("Confirmer"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Text("Valider")),
                              ]
                            ],
                          )
                        ],
                      );
              }),
        ));
  }
}
