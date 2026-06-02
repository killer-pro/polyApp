import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/login/inscription.dart';
import 'package:new_app/login/reset_password.dart';
import 'package:new_app/models/utilisateur.dart';
import 'package:new_app/pages/home/home_page.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/alerte_message.dart';
import 'package:new_app/widgets/reusable_textformfield.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final UserService _userService = UserService();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
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
                        'Connexion',
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
                          CustomTextFormField(
                            hintText: 'Mail EPT',
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Entrer un mail valide';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          CustomTextFormField(
                            maxLines: 1,
                            hintText: 'Mot de passe',
                            controller: _passwordController,
                            isPassword: !_isPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Entrer un mot de passe valide';
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
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () async {
                                //debugPrint("Ok");
                                changerPage(context, ResetPasswordScreen());
                              },
                              child: Text(
                                'Mot de passe oublié ?',
                                style: TextStyle(color: orange),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  User? user = await _userService
                                      .signInWithEmailAndPassword(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );
                                  String? role = await _userService
                                      .getUserRole(_emailController.text);
                                  if (user != null && role != null) {
                                    _userService.setRole(role);
                                    changerPage(context, HomePage());
                                  } else {
                                    alerteMessageWidget(context,
                                        "Compte non activé !", AppColors.echec);
                                  }
                                } catch (e) {
                                  if (e
                                      .toString()
                                      .contains('email_not_verified')) {
                                    alerteMessageWidget(
                                        context,
                                        "Veuillez vérifier votre email avant de vous connecter.",
                                        AppColors.echec);
                                  } else {
                                    alerteMessageWidget(
                                        context,
                                        "Email ou mot de passe incorrect.",
                                        AppColors.echec);
                                  }
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
                              'Se connecter',
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
