import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/enums/sport_type.dart';
import 'package:new_app/models/equipe.dart';
import 'package:new_app/models/match.dart';
import 'package:new_app/pages/interclasse/football/detail_match.dart';
import 'package:new_app/services/sport_service.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:new_app/widgets/match_card.dart';

class AllMatch extends StatefulWidget {
  const AllMatch({super.key});

  @override
  State<AllMatch> createState() => _AllMatchState();
}

class _AllMatchState extends State<AllMatch> {
  final SportService _sportService = SportService();
  final ValueNotifier<List<Equipe>> _equipes = ValueNotifier<List<Equipe>>([]);
  Future<void> _loadEquipes() async {
    List<Equipe> equipes = await _sportService.getEquipeList();
    _equipes.value = equipes;
  }

  final ValueNotifier<List<Matches>?> _matchNotifier = ValueNotifier([]);
  final ValueNotifier<SportType?> _selectedTypeSport = ValueNotifier(null);
  final ValueNotifier<Equipe?> _selectedEquipe = ValueNotifier(null);
  final ValueNotifier<DateTime?> _selectedDateDebut = ValueNotifier(null);
  final ValueNotifier<DateTime?> _selectedDateFin = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _loadEquipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tous les matchs"),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<Matches>?>(
          future: _sportService.getAllMatch(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AppLoader();
            } else if (snapshot.hasError) {
              return Text('Erreur lors de la récupération du rôle');
            } else {
              final match = snapshot.data;
              _matchNotifier.value = match;
              return Column(
                children: [
                  // SingleChildScrollView(
                  //   scrollDirection: Axis.horizontal,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       ValueListenableBuilder<SportType?>(
                  //           valueListenable: _selectedTypeSport,
                  //           builder: (context, selectedEquipeB, child) {
                  //             return DropdownButton<SportType>(
                  //               hint: Text("TypeSport"),
                  //               items: SportType.values
                  //                   .map((SportType type) {
                  //                 return DropdownMenuItem<SportType>(
                  //                   value: type,
                  //                   child: Text(type
                  //                       .toString()
                  //                       .split('.')
                  //                       .last), // Affiche juste le nom sans enum class
                  //                 );
                  //               }).toList(),
                  //               onChanged: (SportType? newValue) {
                  //                 // Traiter la
                  //                 _selectedTypeSport.value = newValue;
                  //               },
                  //             );
                  //           }),
                  //       ValueListenableBuilder<List<Equipe>>(
                  //         valueListenable: _equipes,
                  //         builder: (context, equipes, child) {
                  //           return ValueListenableBuilder<Equipe?>(
                  //             valueListenable: _selectedEquipe,
                  //             builder: (context, selectedEquipeB, child) {
                  //               return DropdownButton<Equipe>(
                  //                 hint: Text('Equipe'),
                  //                 value: equipes.contains(selectedEquipeB)
                  //                     ? selectedEquipeB
                  //                     : null,
                  //                 onChanged: (Equipe? newValue) {
                  //                   _selectedEquipe.value = newValue;
                  //                 },
                  //                 items: equipes
                  //                     .map<DropdownMenuItem<Equipe>>(
                  //                         (Equipe equipe) {
                  //                   return DropdownMenuItem<Equipe>(
                  //                     value: equipe,
                  //                     child: Text(equipe.nom),
                  //                   );
                  //                 }).toList(),
                  //               );
                  //             },
                  //           );
                  //         },
                  //       ),
                  //       ElevatedButton(
                  //         onPressed: () async {
                  //           DateTime? dateDebut = await showDatePicker(
                  //             context: context,
                  //             initialDate: DateTime.now(),
                  //             firstDate: DateTime(2000),
                  //             lastDate: DateTime(2100),
                  //           );
                  //           // Traiter la date début
                  //           _selectedDateDebut.value = dateDebut;
                  //         },
                  //         child: Text("Date Début"),
                  //       ),
                  //       ElevatedButton(
                  //         onPressed: () async {
                  //           DateTime? dateFin = await showDatePicker(
                  //             context: context,
                  //             initialDate: DateTime.now(),
                  //             firstDate: DateTime(2000),
                  //             lastDate: DateTime(2100),
                  //           );
                  //           // Traiter la date fin
                  //           _selectedDateFin.value = dateFin;
                  //           _sportService.getAllMatch();
                  //         },
                  //         child: Text("Date Fin"),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  for (var i in _matchNotifier.value!)
                    Column(
                      children: [
                        Text(
                          i.sport.name,
                        ),
                        buildMatchCard(
                            context,
                            i.id,
                            dateCustomformat(i.date),
                            i.equipeA.nom,
                            i.equipeB.nom,
                            i.scoreEquipeA,
                            i.scoreEquipeB,
                            i.equipeA.logo,
                            i.equipeB.logo,
                            DetailMatchScreen(
                                i.id, i.sport.name.split(".").last)),
                      ],
                    )
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
