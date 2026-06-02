import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/login/login.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/ept_button.dart';
import 'package:new_app/widgets/submited_button.dart';

class Validation extends StatefulWidget {
  String email;
  Validation({super.key, required this.email});

  @override
  State<Validation> createState() => _ValidationState();
}

class _ValidationState extends State<Validation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Un mail de confirmation a été envoyé à ',
              style: TextStyle(
                fontSize: 30,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              widget.email,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 30,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'Ouvrez le pour valider votre inscription et pouvoir vous connecter à l\'application.',
              style: TextStyle(
                fontSize: 30,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 30,
            ),
            SubmittedButton("Se connecter", () {
              changerPage(context, LoginScreen());
            })
          ],
        ),
      ),
    );
  }
}
