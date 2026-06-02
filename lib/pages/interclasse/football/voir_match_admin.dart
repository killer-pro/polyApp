import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/match.dart';
import 'package:new_app/pages/interclasse/football/administrate_one_match.dart';
import 'package:new_app/services/sport_service.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:new_app/widgets/match_card.dart';

class VoirMatchAdmin extends StatefulWidget {
  final String typeSport;
  const VoirMatchAdmin({super.key, required this.typeSport});

  @override
  State<VoirMatchAdmin> createState() => _VoirMatchAdminState();
}

class _VoirMatchAdminState extends State<VoirMatchAdmin> {
  SportService _sportService = SportService();

  Widget _buildMatchList(String typeSport) {
    return FutureBuilder<List<Matches>>(
      future: (typeSport != 'MB')
          ? _sportService.getListMatchFootball(typeSport)
          : _sportService.getAllMatch(), // Vérifiez bien cette méthode
      builder: (context, snapshot) {
        // Si en attente de la réponse
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppLoader();
        } else if (snapshot.hasError) {
          return Text('Erreur lors du chargement des matchs');
        } else {
          List<Matches> matches = snapshot.data ?? [];

          if (matches.isNotEmpty) {
            return Column(
              children: matches.map((match) {
                return Column(
                  children: [
                    Text(match.sport.name),
                    buildMatchCard(
                      context,
                      match.id,
                      dateCustomformat(match.date),
                      match.equipeA.nom,
                      match.equipeB.nom,
                      match.scoreEquipeA,
                      match.scoreEquipeB,
                      match.equipeA.logo,
                      match.equipeB.logo,
                      AdministrateOneFootball(match.id, match.sport.name),
                    ),
                    SizedBox(
                      height: 5,
                    )
                  ],
                );
              }).toList(),
            );
          } else {
            return Text("Aucun match à administrer");
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listes des matchs'),
      ),
      body: SingleChildScrollView(
        child: _buildMatchList(widget.typeSport),
      ),
    );
  }
}
