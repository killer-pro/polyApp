// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:new_app/models/utilisateur.dart';
import 'package:new_app/pages/drawer/compte/compte.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/alerte_message.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:new_app/widgets/reusable_description_input.dart';
import 'package:new_app/widgets/reusable_widgets.dart';
import 'package:new_app/widgets/submited_button.dart';

class EditInfosUtilisateur extends StatefulWidget {
  const EditInfosUtilisateur({super.key});

  @override
  State<EditInfosUtilisateur> createState() => _EditInfosUtilisateurState();
}

class _EditInfosUtilisateurState extends State<EditInfosUtilisateur> {
  final TextEditingController _prenomTextController = TextEditingController();
  final TextEditingController _nomTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _telephoneTextController =
      TextEditingController();
  final TextEditingController _promoTextController = TextEditingController();
  final TextEditingController _genieTextController = TextEditingController();

  final UserService _userService = UserService();
  final ValueNotifier<bool> _loading = ValueNotifier(false);
  final ValueNotifier<String> _url = ValueNotifier("");

  bool _isLoading = true; // Pour gérer l'affichage du CircularProgressIndicator
  Utilisateur? _user; // Stocke les informations de l'utilisateur
  String? _selectedGenie;
  final List<String> _genies = [
    'GIT',
    'GC',
    'GEM',
    'GI',
    'GA',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Charger les données utilisateur au démarrage
  }

  // Charger les données utilisateur et initialiser les contrôleurs
  Future<void> _loadUserData() async {
    try {
      Utilisateur? user = await _userService
          .getUserByEmail(FirebaseAuth.instance.currentUser!.email!);

      if (user != null) {
        setState(() {
          _url.value = user.photo!;
          _user = user;
          _prenomTextController.text = user.prenom;
          _nomTextController.text = user.nom;
          _emailTextController.text = user.email;
          _telephoneTextController.text = user.telephone ?? '';
          _promoTextController.text = user.promo ?? '';
          _genieTextController.text = user.genie ?? '';
          _isLoading = false; // Les données sont chargées
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Arrêter le chargement même en cas d'erreur
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: AppLoader());
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text("Modification"),
      ),
      body: SizedBox(
          width: MediaQuery.of(context).size.width,
          // height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      20, MediaQuery.of(context).size.height * 0.02, 20, 0),
                  child: Column(children: <Widget>[
                    ValueListenableBuilder<String>(
                        valueListenable: _url,
                        builder: (context, url, child) {
                          return ValueListenableBuilder<bool>(
                              valueListenable: _loading,
                              builder: (context, loading, child) {
                                return loading
                                    ? AppLoader()
                                    : Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape
                                              .circle, // Forme en cercle
                                          border: Border.all(
                                            color:
                                                orange, // Couleur de la bordure
                                            width: 4.0, // Largeur de la bordure
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 80,
                                          backgroundImage: ResizeImage(
                                            CachedNetworkImageProvider(url),
                                            height: 360,
                                          ),
                                          backgroundColor: grisClair,
                                          child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  if (url != '') {
                                                    // Affiche un dialogue si l'utilisateur a déjà une photo
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title: Text(
                                                            "Modifier la photo de profil"),
                                                        content: Text(
                                                            "Que souhaitez-vous faire ?"),
                                                        actions: [
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              // Supprime la photo de profil
                                                              await _userService
                                                                  .deleteProfilePicture(
                                                                      _user!
                                                                          .photo!);
                                                              _url.value =
                                                                  ""; // Supprime le lien localement
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              alerteMessageWidget(
                                                                  context,
                                                                  "Photo supprimée avec succès.",
                                                                  AppColors
                                                                      .success);
                                                            },
                                                            child: Text(
                                                                "Supprimer"),
                                                          ),
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              // Modifie la photo de profil
                                                              String? newUrl =
                                                                  await _userService
                                                                      .uploadImage(
                                                                          context,
                                                                          _loading,
                                                                          _url);
                                                              if (newUrl !=
                                                                  null) {
                                                                await _userService
                                                                    .deleteProfilePicture(
                                                                        _user!
                                                                            .photo!);
                                                                _url.value =
                                                                    newUrl; // Met à jour le lien localement
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                alerteMessageWidget(
                                                                    context,
                                                                    "Photo modifiée avec succès.",
                                                                    AppColors
                                                                        .success);
                                                              }
                                                            },
                                                            child: Text(
                                                                "Modifier"),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  } else {
                                                    // Charge une nouvelle photo si aucune n'existe
                                                    String? url =
                                                        await _userService
                                                            .uploadImage(
                                                                context,
                                                                _loading,
                                                                _url);
                                                    if (url != null) {
                                                      _url.value = url;
                                                      alerteMessageWidget(
                                                          context,
                                                          "Photo enregistrée avec succès.",
                                                          AppColors.success);
                                                    } else {
                                                      alerteMessageWidget(
                                                          context,
                                                          "Une erreur est survenue lors du chargement.",
                                                          AppColors.echec);
                                                    }
                                                  }
                                                },
                                                child: Icon(
                                                  Icons.edit,
                                                  color: AppColors.primary,
                                                ),
                                              )),
                                        ),
                                      );
                              });
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    reusableTextFormField("Prénom", _prenomTextController,
                        (value) {
                      return null;
                    }),
                    SizedBox(
                      height: 20,
                    ),
                    reusableTextFormField("Nom", _nomTextController, (value) {
                      return null;
                    }),
                    SizedBox(
                      height: 20,
                    ),
                    reusableTextFormField("Téléphone", _telephoneTextController,
                        (value) {
                      return null;
                    }),
                    SizedBox(
                      height: 20,
                    ),
                    reusableTextFormField("Promo", _promoTextController,
                        (value) {
                      return null;
                    }),
                    SizedBox(
                      height: 20,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Sélectionner un génie',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      initialValue: _selectedGenie,
                      items: _genies.map((String genie) {
                        return DropdownMenuItem<String>(
                          value: genie,
                          child: Text(genie),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGenie = newValue;
                          _genieTextController.text = newValue!;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner un génie';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SubmittedButton("Modifier", () async {
                      //debugPrint("Tap");
                      try {
                        //debugPrint("T1p");

                        String code =
                            await _userService.updateUser(_user!.email, {
                          "photo": _url.value,
                          "prenom": _prenomTextController.text,
                          "nom": _nomTextController.text,
                          "telephone": _telephoneTextController.text,
                          "promo": _promoTextController.text,
                          "genie": _genieTextController.text,
                        });

                        if (code == "OK") {
                          alerteMessageWidget(
                              context,
                              "Informations modifiée avec succès !",
                              AppColors.success);
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CompteScreen()),
                          );
                        }
                      } catch (e) {
                        alerteMessageWidget(
                            context,
                            "Une erreur est survie lors de la modification.$e",
                            AppColors.echec);
                      }
                    })
                  ])))),
    );
  }
}
