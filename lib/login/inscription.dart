import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/login/validation.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:new_app/models/enums/role_type.dart';
import 'package:new_app/models/utilisateur.dart';
import 'package:new_app/pages/home/home_page.dart';
import 'package:new_app/login/login.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/alerte_message.dart';
import 'package:new_app/widgets/reusable_textformfield.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Inscription extends StatefulWidget {
  Inscription({super.key});

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  final UserService _userService = UserService();

  final TextEditingController _prenomController = TextEditingController();

  final TextEditingController _nomController = TextEditingController();

  final TextEditingController _telephoneController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final TextEditingController _promoController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final ValueNotifier<bool> _isSaving = ValueNotifier<bool>(false);

  final ValueNotifier<double> _strengthNotifier = ValueNotifier<double>(0);

  final ValueNotifier<bool> _passwordsMatchNotifier =
      ValueNotifier<bool>(false);

  bool _hasStartedTypingPassword = false;
  String? mtoken;
  void _requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      //debugPrint("User granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      //debugPrint("User granted provisional permission");
    } else {
      //debugPrint("User declined or has not accepted permission");
    }
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token;
        //debugPrint("My token is $mtoken");
      });
      // saveToken(token!);
    });
  }

  // Fonction pour calculer la force du mot de passe
  void _checkPasswordStrength(String password) {
    double strength = 0;

    // Critère 1: Longueur du mot de passe
    if (password.length >= 8) strength += 0.25;

    // Critère 2: Présence d'une lettre majuscule
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;

    // Critère 3: Présence d'un chiffre
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;

    // Critère 4: Présence d'un caractère spécial
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;

    // Mise à jour de la valeur dans le ValueNotifier
    _strengthNotifier.value = strength;
  }

  void _checkPasswordsMatch() {
    _passwordsMatchNotifier.value =
        _passwordController.text == _confirmPasswordController.text;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestPermission();
    getToken();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 170,
                      child: Image.asset(
                        'assets/images/connection-inscription/logo_ept_baobab.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                // Title
                Row(
                  children: [
                    Text(
                      'Inscription',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                // Subtitle
                Row(
                  children: [
                    Text(
                      'Vos premiers pas dans la vie polytechnicienne',
                      style: TextStyle(
                        fontSize: MediaQuery.sizeOf(context).width * 0.035,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Nom TextField
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextFormField(
                            controller: _prenomController,
                            hintText: 'Prénom',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Entrer un prénom valide';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),
                          CustomTextFormField(
                            controller: _nomController,
                            hintText: 'Nom',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Entrer un nom valide';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),
                          CustomTextFormField(
                            controller: _telephoneController,
                            hintText: 'Téléphone',
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Entrer un numéro valide';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),
                          CustomTextFormField(
                            controller: _emailController,
                            hintText: 'Mail',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Entrer un mail valide';
                              }
                              final regex = RegExp(
                                  r'^[a-zA-Z0-9.]+@(ept\.sn|ept\.edu\.sn)$');
                              if (!regex.hasMatch(value)) {
                                return 'Veuillez entrer votre mail EPT';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),
                          CustomTextFormField(
                            maxLines: 1,
                            controller: _passwordController,
                            hintText: 'Mot de passe',
                            isPassword: !_isPasswordVisible,
                            onChanged: (value) {
                              setState(() {
                                _hasStartedTypingPassword = value.isNotEmpty;
                              });
                              _checkPasswordStrength(value);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Entrer un password valide';
                              } else if (value.length < 8) {
                                return 'Le password doit contenir au moins 8 caractères';
                              } else if (!value.contains(RegExp(r'[A-Z]'))) {
                                return 'Le password doit contenir au moins une majuscule';
                              } else if (!value.contains(RegExp(r'[0-9]'))) {
                                return 'Le password doit contenir au moins un chiffre';
                              } else if (!value.contains(
                                  RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                                return 'Le password doit contenir au moins un caractère spécial';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 10),

                          if (_hasStartedTypingPassword) ...[
                            ValueListenableBuilder<double>(
                              valueListenable: _strengthNotifier,
                              builder: (context, strength, child) {
                                return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Affichage de la barre de progression
                                      LinearProgressIndicator(
                                        borderRadius: BorderRadius.circular(10),
                                        value:
                                            strength, // Valeur de la force (entre 0.0 et 1.0)
                                        backgroundColor: Colors.grey[300],
                                        color: strength <= 0.5
                                            ? Colors.red
                                            : (strength <= 0.75
                                                ? Colors.orange
                                                : Colors.green),
                                        minHeight: 10,
                                      ),
                                      SizedBox(height: 10),
                                      // Affichage textuel de la force
                                      Text(
                                        strength <= 0.25
                                            ? 'Mot de passe faible'
                                            : (strength <= 0.5
                                                ? 'Mot de passe moyen'
                                                : (strength <= 0.75
                                                    ? 'Mot de passe fort'
                                                    : 'Mot de passe très fort')),
                                        style: TextStyle(
                                            color: strength <= 0.5
                                                ? Colors.red
                                                : (strength <= 0.75
                                                    ? Colors.orange
                                                    : Colors.green)),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ]);
                              },
                            ),
                          ],

                          CustomTextFormField(
                            maxLines: 1,
                            controller: _confirmPasswordController,
                            hintText: 'Confirmer mot de passe',
                            isPassword: !_isConfirmPasswordVisible,
                            onChanged: (value) {
                              _checkPasswordsMatch();
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Entrer un mot de passe valide';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          if (_passwordController.text != '') ...[
                            ValueListenableBuilder<bool>(
                              valueListenable: _passwordsMatchNotifier,
                              builder: (context, passwordsMatch, child) {
                                return Text(
                                  passwordsMatch
                                      ? 'Les mots de passe correspondent'
                                      : 'Les mots de passe ne correspondent pas',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: passwordsMatch
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                          // Promotion TextField
                          DropdownButtonFormField<String>(
                            initialValue: _promoController.text.isNotEmpty
                                ? _promoController.text
                                : null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Choisir une promo';
                              }
                              return null;
                            },
                            onChanged: (newValue) {
                              _promoController.text = newValue!;
                            },
                            items: ["47", "48", "49", "50", "51", "52"]
                                .map((promo) => DropdownMenuItem(
                                      value: promo,
                                      child: Text(promo),
                                    ))
                                .toList(),
                            decoration: InputDecoration(
                              labelText: 'Promotion',
                              labelStyle: TextStyle(fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          // S'inscrire Button
                          ValueListenableBuilder<bool>(
                            valueListenable: _isSaving,
                            builder: (context, isSaving, child) {
                              return isSaving
                                  ? AppLoader()
                                  : ElevatedButton(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          _isSaving.value =
                                              true; // Déplace cette ligne ici
                                          try {
                                            User? user = await _userService
                                                .signUpWithEmailAndPassword(
                                              _emailController.text.trim(),
                                              _passwordController.text.trim(),
                                            );

                                            if (user != null &&
                                                mtoken != null) {
                                              Utilisateur utilisateur =
                                                  Utilisateur(
                                                id: _emailController.value.text,
                                                prenom: _prenomController
                                                    .value.text,
                                                nom: _nomController.value.text,
                                                email:
                                                    _emailController.value.text,
                                                telephone: _telephoneController
                                                    .value.text,
                                                photo: "",
                                                genie: "",
                                                promo:
                                                    "#${_promoController.value.text}",
                                                role: RoleType.USER,
                                              );

                                              await _userService.setRole(
                                                RoleType.USER
                                                    .toString()
                                                    .split('.')
                                                    .last,
                                              );
                                              await _userService.postToken(
                                                mtoken!,
                                                RoleType.USER
                                                    .toString()
                                                    .split('.')
                                                    .last,
                                              );

                                              String code = await _userService
                                                  .ajouterUser(utilisateur);
                                              if (code == "OK") {
                                                changerPage(
                                                    context,
                                                    Validation(
                                                        email: _emailController
                                                            .text));
                                              } else {
                                                alerteMessageWidget(
                                                  context,
                                                  "Erreur lors de l'inscription.",
                                                  AppColors.echec,
                                                );
                                              }
                                            } else {
                                              alerteMessageWidget(
                                                context,
                                                "Erreur lors de la création du compte.",
                                                AppColors.echec,
                                              );
                                            }
                                          } catch (e) {
                                            alerteMessageWidget(
                                              context,
                                              "Une erreur est survenue.",
                                              AppColors.echec,
                                            );
                                          } finally {
                                            _isSaving.value = false;
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: orange,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 100, vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Text(
                                        "S'inscrire",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                    );
                            },
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Déjà inscrit? "),
                              TextButton(
                                onPressed: () {
                                  changerPage(context, LoginScreen());
                                },
                                child: Text(
                                  'connectez vous',
                                  style: TextStyle(
                                    color: orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
