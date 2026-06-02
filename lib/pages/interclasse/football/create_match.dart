// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:io';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/basket.dart';
import 'package:new_app/models/enums/sport_type.dart';
import 'package:new_app/models/equipe.dart';
import 'package:new_app/models/football.dart';
import 'package:new_app/models/jeux_esprit.dart';
import 'package:new_app/models/match.dart';
import 'package:new_app/models/volleyball.dart';
import 'package:new_app/pages/interclasse/football/home_admin_sport_type_page.dart';
import 'package:new_app/pages/interclasse/interclasse.dart';
import 'package:new_app/services/sport_service.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/alerte_message.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:new_app/widgets/reusable_description_input.dart';
import 'package:new_app/widgets/reusable_widgets.dart';
import 'package:new_app/widgets/submited_button.dart';

class CreateMatch extends StatefulWidget {
  String typeSport;
  CreateMatch(this.typeSport, {super.key});

  @override
  State<CreateMatch> createState() => _CreateMatchState();
}

class _CreateMatchState extends State<CreateMatch> {
  final TextEditingController _descriptionTextController =
      TextEditingController();

  DateTime selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    DateTime.now().hour,
    DateTime.now().minute,
  );

  // ignore: non_constant_identifier_names
  final SportService _SportService = SportService();

  final UserService _userService = UserService();

  final ValueNotifier<List<Equipe>> _equipes = ValueNotifier([]);

  final ValueNotifier<Equipe?> _selectedEquipeA = ValueNotifier(null);

  final ValueNotifier<Equipe?> _selectedEquipeB = ValueNotifier(null);

  final ValueNotifier<DateTime> _selectedDate = ValueNotifier(DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    DateTime.now().hour,
    DateTime.now().minute,
  ));

  final ValueNotifier<bool> _loading = ValueNotifier(false);

  final ValueNotifier<String> _url = ValueNotifier("");

  TextEditingController _sportController = TextEditingController();
  String? _selectedSport;
  final List<String> _sports = [
    'FOOTBALL',
    'BASKETBALL',
    'VOLLEYBALL',
    'JEUX_ESPRIT',
  ];

  Future<void> _loadEquipes() async {
    List<Equipe> equipes = await _SportService.getEquipeList();
    _equipes.value = equipes;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    // Sélectionner la date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate.value,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // Sélectionner l'heure après la date
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate.value),
      );

      if (pickedTime != null) {
        // Combiner la date et l'heure
        final DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Mettre à jour la variable avec la nouvelle date et heure sélectionnées
        _selectedDate.value = pickedDateTime;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadEquipes();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text("Créer un match"),
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
                          return url == ""
                              ? Container(
                                  height:
                                      MediaQuery.sizeOf(context).width * 0.6,
                                  width: MediaQuery.sizeOf(context).width * 0.5,
                                  decoration: BoxDecoration(
                                      color: AppColors.gray,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: ValueListenableBuilder<bool>(
                                        valueListenable: _loading,
                                        builder: (context, loading, child) {
                                          return loading
                                              ? AppLoader()
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                        child:
                                                            ElevatedButton.icon(
                                                      style: ButtonStyle(
                                                          iconColor:
                                                              WidgetStateProperty
                                                                  .all(AppColors
                                                                      .black)),
                                                      onPressed: () async {
                                                        String? url =
                                                            await _userService
                                                                .uploadImage(
                                                                    context,
                                                                    _loading,
                                                                    _url);
                                                        if (url != null) {
                                                          alerteMessageWidget(
                                                              context,
                                                              "Fichier enregistré avec succès !",
                                                              AppColors
                                                                  .success);
                                                        } else {
                                                          alerteMessageWidget(
                                                              context,
                                                              "Une erreur s'est produit lors du chargement !",
                                                              AppColors.echec);
                                                        }
                                                      },
                                                      icon: Icon(
                                                        Icons.library_add,
                                                        color: AppColors.black,
                                                      ),
                                                      label: Text(
                                                        "Importer",
                                                        style: TextStyle(
                                                          color:
                                                              AppColors.black,
                                                        ),
                                                      ),
                                                    )),
                                                  ],
                                                );
                                        }),
                                  ),
                                )
                              : Image.network(url);
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ValueListenableBuilder<List<Equipe>>(
                          valueListenable: _equipes,
                          builder: (context, equipes, child) {
                            return ValueListenableBuilder<Equipe?>(
                              valueListenable: _selectedEquipeA,
                              builder: (context, selectedEquipeA, child) {
                                return DropdownButton<Equipe>(
                                  hint: Text('Equipe A'),
                                  value: equipes.contains(selectedEquipeA)
                                      ? selectedEquipeA
                                      : null,
                                  onChanged: (Equipe? newValue) {
                                    _selectedEquipeA.value = newValue;
                                  },
                                  items: equipes.map<DropdownMenuItem<Equipe>>(
                                      (Equipe equipe) {
                                    return DropdownMenuItem<Equipe>(
                                      value: equipe,
                                      child: Text(equipe.nom),
                                    );
                                  }).toList(),
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(width: 3),
                        Text("VS"),
                        SizedBox(width: 3),
                        ValueListenableBuilder<List<Equipe>>(
                          valueListenable: _equipes,
                          builder: (context, equipes, child) {
                            return ValueListenableBuilder<Equipe?>(
                              valueListenable: _selectedEquipeB,
                              builder: (context, selectedEquipeB, child) {
                                return DropdownButton<Equipe>(
                                  hint: Text('Equipe B'),
                                  value: equipes.contains(selectedEquipeB)
                                      ? selectedEquipeB
                                      : null,
                                  onChanged: (Equipe? newValue) {
                                    _selectedEquipeB.value = newValue;
                                  },
                                  items: equipes.map<DropdownMenuItem<Equipe>>(
                                      (Equipe equipe) {
                                    return DropdownMenuItem<Equipe>(
                                      value: equipe,
                                      child: Text(equipe.nom),
                                    );
                                  }).toList(),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    if (widget.typeSport == 'MB') ...[
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Sélectionner un sport',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        initialValue: _selectedSport,
                        items: _sports.map((String genie) {
                          return DropdownMenuItem<String>(
                            value: genie,
                            child: Text(genie),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedSport = newValue;
                            _sportController.text = newValue!;
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
                    ] else
                      ...[],
                    GestureDetector(
                      onTap: () => _selectDateTime(context),
                      child: Row(children: [
                        Icon(Icons.calendar_month),
                        SizedBox(
                          width: 5,
                        ),
                        ValueListenableBuilder<DateTime?>(
                          valueListenable: _selectedDate,
                          builder: (context, selectedDate, child) {
                            String formattedDate = selectedDate != null
                                ? DateFormat('dd MMMM yyyy')
                                    .format(selectedDate)
                                : 'Pas de date sélectionnée';
                            return Text(
                              formattedDate,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                        ValueListenableBuilder<DateTime>(
                            valueListenable: _selectedDate,
                            builder: (context, selectedDate, child) {
                              return Text(
                                DateFormat('yyyy-MM-dd HH:mm')
                                    .format(_selectedDate.value),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              );
                            }),
                      ]),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ReusableDescriptionInput(
                        "Description", _descriptionTextController, (value) {
                      return null;
                    }),
                    SizedBox(
                      height: 20,
                    ),
                    SubmittedButton("Créer", () async {
                      if (widget.typeSport == 'MB') {
                        widget.typeSport = _sportController.text;
                      }
                      if (_selectedEquipeA.value != null &&
                          _selectedEquipeB.value != null &&
                          _selectedEquipeA.value != _selectedEquipeB.value) {
                        dynamic match;
                        try {
                          if (widget.typeSport == "FOOTBALL") {
                            match = Football(
                                statistiques: {
                                  "redCardA": 0,
                                  "redCardB": 0,
                                  "yellowCardA": 0,
                                  "yellowCardB": 0,
                                  "cornersA": 0,
                                  "cornersB": 0,
                                  "fautesA": 0,
                                  "fautesB": 0,
                                  "tirsA": 0,
                                  "tirsB": 0,
                                  "tirsCadresA": 0,
                                  "tirsCadresB": 0,
                                },
                                buteursA: [],
                                buteursB: [],
                                description:
                                    _descriptionTextController.value.text,
                                photo: _url.value,
                                id: "${_selectedEquipeA.value!.nom} VS ${_selectedEquipeB.value!.nom}${_selectedDate.value}",
                                date: _selectedDate.value,
                                equipeA: _selectedEquipeA.value!,
                                equipeB: _selectedEquipeB.value!,
                                dateCreation: DateTime.now(),
                                scoreEquipeA: 0,
                                scoreEquipeB: 0,
                                sport: SportType.FOOTBALL,
                                comments: [],
                                likers: [],
                                dislikers: [],
                                partageLien: "");
                          } else if (widget.typeSport == "BASKETBALL") {
                            match = Basket(
                                statistiques: {
                                  "1erA": 0,
                                  "1erB": 0,
                                  "2emeA": 0,
                                  "2emeB": 0,
                                  "3emeA": 0,
                                  "3emeB": 0,
                                  "4emeA": 0,
                                  "4emeB": 0,
                                },
                                buteursA: [],
                                buteursB: [],
                                description:
                                    _descriptionTextController.value.text,
                                photo: _url.value,
                                id: "${_selectedEquipeA.value!.nom} VS ${_selectedEquipeB.value!.nom}${_selectedDate.value}",
                                date: _selectedDate.value,
                                equipeA: _selectedEquipeA.value!,
                                equipeB: _selectedEquipeB.value!,
                                dateCreation: DateTime.now(),
                                scoreEquipeA: 0,
                                scoreEquipeB: 0,
                                sport: SportType.BASKETBALL,
                                comments: [],
                                likers: [],
                                dislikers: [],
                                partageLien: "");
                          } else if (widget.typeSport == "VOLLEYBALL") {
                            match = Volleyball(
                                statistiques: {
                                  "Set1A": 0,
                                  "Set1B": 0,
                                  "Set2A": 0,
                                  "Set2B": 0,
                                  "Set3A": 0,
                                  "Set3B": 0,
                                },
                                buteursA: [],
                                buteursB: [],
                                description:
                                    _descriptionTextController.value.text,
                                photo: _url.value,
                                id: "${_selectedEquipeA.value!.nom} VS ${_selectedEquipeB.value!.nom}${_selectedDate.value}",
                                date: _selectedDate.value,
                                equipeA: _selectedEquipeA.value!,
                                equipeB: _selectedEquipeB.value!,
                                dateCreation: DateTime.now(),
                                scoreEquipeA: 0,
                                scoreEquipeB: 0,
                                sport: SportType.VOLLEYBALL,
                                comments: [],
                                likers: [],
                                dislikers: [],
                                partageLien: "");
                          } else if (widget.typeSport == "JEUX_ESPRIT") {
                            match = JeuxEsprit(
                                statistiques: {
                                  "miTemp1A": 0,
                                  "miTemp1B": 0,
                                  "miTemp2A": 0,
                                  "miTemp2B": 0,
                                },
                                buteursA: [],
                                buteursB: [],
                                description:
                                    _descriptionTextController.value.text,
                                photo: _url.value,
                                id: "${_selectedEquipeA.value!.nom} VS ${_selectedEquipeB.value!.nom}${_selectedDate.value}",
                                date: _selectedDate.value,
                                equipeA: _selectedEquipeA.value!,
                                equipeB: _selectedEquipeB.value!,
                                dateCreation: DateTime.now(),
                                scoreEquipeA: 0,
                                scoreEquipeB: 0,
                                sport: SportType.JEUX_ESPRIT,
                                comments: [],
                                likers: [],
                                dislikers: [],
                                partageLien: "");
                          }
                          try {
                            String code =
                                await _SportService.postFootball(match);
                            if (code == "OK") {
                              alerteMessageWidget(
                                  context,
                                  "Match crée avec succès !",
                                  AppColors.success);
                              Navigator.pop(context);
                              Navigator.pop(context);
                              changerPage(context, InterclassePage());
                            }
                          } catch (e) {
                            return null;
                          }
                        } catch (e) {
                          alerteMessageWidget(
                              context,
                              "Une erreur est survie lors de la création.$e",
                              AppColors.echec);
                        }
                      } else {
                        alerteMessageWidget(
                            context,
                            "Vous n'avez pas sélectionné une équipe ou des équipes différentes.",
                            AppColors.echec);
                      }
                    })
                  ])))),
    );
  }
}
