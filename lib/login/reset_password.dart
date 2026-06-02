import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/login/inscription.dart';
import 'package:new_app/login/login.dart';
import 'package:new_app/models/utilisateur.dart';
import 'package:new_app/pages/home/home_page.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/alerte_message.dart';

class ResetPasswordScreen extends StatefulWidget {
  ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final UserService _userService = UserService();

  final TextEditingController _emailController = TextEditingController();

  // Visibilite
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 350,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/connection-inscription/logo_ept_baobab.png',
                          fit: BoxFit.cover,
                        ),
                        Image.asset(
                          'assets/images/connection-inscription/cercles_login.png',
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Réinitialisation',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Tous les services des polytechniciens à portée de main.',
                        style: TextStyle(
                          fontSize: MediaQuery.sizeOf(context).width * 0.032,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Entrer un votre email.';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Votre mail EPT',
                              labelStyle: TextStyle(fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  bool? user = await _userService.resetAccount(
                                      _emailController.value.text);
                                  String? role = await _userService
                                      .getUserRole(_emailController.text);
                                  if (user && role != null) {
                                    _userService.setRole(role);

                                    changerPage(context, LoginScreen());
                                    alerteMessageWidget(
                                        context,
                                        "Un mail vous a été envoyé.",
                                        AppColors.success);
                                  } else {
                                    alerteMessageWidget(
                                        context,
                                        "Le mail n'existe pas. Merci de fournir un mail valide.",
                                        AppColors.echec);
                                  }
                                } catch (e) {
                                  alerteMessageWidget(
                                      context,
                                      "Un problème est survenu lors de la réinitialisation. Merci de contacter votre administrateur.",
                                      AppColors.echec);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: orange,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 110, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Réinitialiser',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          )
                        ],
                      )),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Pas de compte? "),
                      TextButton(
                        onPressed: () {
                          changerPage(context, Inscription());
                        },
                        child: Text(
                          'Inscrivez vous',
                          style: TextStyle(
                            color: orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
