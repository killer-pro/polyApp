import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/pages/interclasse/football/create_equipe.dart';
import 'package:new_app/pages/interclasse/football/create_match.dart';
import 'package:new_app/pages/interclasse/football/voir_match_admin.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/submited_button.dart';

class AdminSport extends StatefulWidget {
  const AdminSport({super.key});

  @override
  State<AdminSport> createState() => _AdminSportState();
}

class _AdminSportState extends State<AdminSport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sport admin'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Column(
            children: [
              SubmittedButton("Créer un match", () {
                changerPage(context, CreateMatch('MB'));
              }),
              SizedBox(
                height: 10,
              ),
              SubmittedButton('Gestion équipes', () {
                changerPage(context, CreateEquipePage());
              }),
              SizedBox(height: 10),
              SubmittedButton("Administrer match", () {
                changerPage(
                  context,
                  VoirMatchAdmin(
                    typeSport: 'MB',
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
