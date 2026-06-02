// // ignore_for_file: must_be_immutable

// import 'dart:io';

// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:new_app/fonctions.dart';
// import 'package:new_app/models/commission.dart';
// import 'package:new_app/models/enums/sport_type.dart';
// import 'package:new_app/models/equipe.dart';
// import 'package:new_app/models/football.dart';
// import 'package:new_app/models/utilisateur.dart';
// import 'package:new_app/pages/interclasse/football/home_admin_sport_type_page.dart';
// import 'package:new_app/services/sport_service.dart';
// import 'package:new_app/services/user_service.dart';
// import 'package:new_app/utils/app_colors.dart';
// import 'package:new_app/widgets/alerte_message.dart';
// import 'package:new_app/widgets/reusable_description_input.dart';
// import 'package:new_app/widgets/reusable_widgets.dart';
// import 'package:new_app/widgets/submited_button.dart';

// class CreateCommission extends StatelessWidget {
//   String typeSport;
//   CreateCommission(this.typeSport, {super.key});
//   TextEditingController _nomCommissionTextController = TextEditingController();
//   SportService _SportService = new SportService();
//   UserService _userService = new UserService();

//   final ValueNotifier<List<Utilisateur>> _equipes = ValueNotifier([]);
//   ValueNotifier<Utilisateur?> _selectedEquipeA = ValueNotifier(null);
//   Future<void> _loadEquipes() async {
//     List<Utilisateur> equipes = await _userService.getAllUser();
//     _equipes.value = equipes;
//   }

//   @override
//   Widget build(BuildContext context) {
//     _loadEquipes();
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.primary,
//         title: Text("Créer un match"),
//       ),
//       body: Container(
//           width: MediaQuery.of(context).size.width,
//           // height: MediaQuery.of(context).size.height,
//           child: SingleChildScrollView(
//               child: Padding(
//                   padding: EdgeInsets.fromLTRB(
//                       20, MediaQuery.of(context).size.height * 0.02, 20, 0),
//                   child: Column(children: <Widget>[
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         ValueListenableBuilder<List<Utilisateur>>(
//                           valueListenable: _equipes,
//                           builder: (context, equipes, child) {
//                             return ValueListenableBuilder<Utilisateur?>(
//                               valueListenable: _selectedEquipeA,
//                               builder: (context, selectedEquipeA, child) {
//                                 return DropdownButton<Utilisateur>(
//                                   hint: Text('Equipe A'),
//                                   value: equipes.contains(selectedEquipeA)
//                                       ? selectedEquipeA
//                                       : null,
//                                   onChanged: (Utilisateur? newValue) {
//                                     _selectedEquipeA.value = newValue;
//                                   },
//                                   items: equipes
//                                       .map<DropdownMenuItem<Utilisateur>>(
//                                           (Utilisateur equipe) {
//                                     return DropdownMenuItem<Utilisateur>(
//                                       value: equipe,
//                                       child: Text(equipe.nom),
//                                     );
//                                   }).toList(),
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 20,
//                     ),
//                     reusableTextFormField("Poste", _nomCommissionTextController,
//                         (value) {
//                       return null;
//                     }),
//                     reusableTextFormField(
//                         "Nom Commission", _nomCommissionTextController,
//                         (value) {
//                       return null;
//                     }),
//                     SizedBox(
//                       height: 20,
//                     ),
//                     SubmittedButton("Créer", () async {
//                       try {
//                         Commission commission = Commission(
//                             id: DateTime.now().toString(),
//                             nom: _nomCommissionTextController.value.text,
//                             membres: [
//                               Membre(
//                                   id: DateTime.now().toString(),
//                                   poste: "Président",
//                                   email: "tester",
//                                   prenom: "Elimane",
//                                   nom: "SALL")
//                             ]);
//                         try {
//                           String code =
//                               await _SportService.postCommission(commission);
//                           if (code == "OK") {
//                             alerteMessageWidget(context,
//                                 "Match crée avec succès !", AppColors.success);
//                             changerPage(
//                                 context, HomeAdminSportTypePage(typeSport));
//                           }
//                         } catch (e) {}
//                       } catch (e) {
//                         alerteMessageWidget(
//                             context,
//                             "Une erreur est survie lors de la création.${e}",
//                             AppColors.echec);
//                       }
//                     })
//                   ])))),
//     );
//   }
// }
