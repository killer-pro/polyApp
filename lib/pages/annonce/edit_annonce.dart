import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/annonce.dart';
import 'package:new_app/models/categorie.dart';
import 'package:new_app/pages/annonce/annonce_screen.dart';
import 'package:new_app/services/annonce_service.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/alerte_message.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:new_app/widgets/reusable_description_input.dart';
import 'package:new_app/widgets/reusable_widgets.dart';
import 'package:new_app/widgets/submited_button.dart';
import 'package:intl/intl.dart';

class EditAnnonce extends StatefulWidget {
  final String idAnnonce; // L'annonce que l'on veut modifier

  EditAnnonce({required this.idAnnonce, super.key});

  @override
  _EditAnnonceState createState() => _EditAnnonceState();
}

class _EditAnnonceState extends State<EditAnnonce> {
  Annonce? _currentAnnonce;
  final TextEditingController _descriptionTextController =
      TextEditingController();
  final TextEditingController _titreTextController = TextEditingController();
  final TextEditingController _lieuTextController = TextEditingController();
  DateTime selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    DateTime.now().hour,
    DateTime.now().minute,
  );
  final AnnonceService _annonceService = AnnonceService();
  final UserService _userService = UserService();

  final ValueNotifier<List<Categorie>> _categories = ValueNotifier([]);
  final ValueNotifier<Categorie?> _selectedCategory = ValueNotifier(null);
  final ValueNotifier<DateTime> _selectedDate = ValueNotifier(DateTime.now());
  final ValueNotifier<bool> _loading = ValueNotifier(false);
  final ValueNotifier<String> _url = ValueNotifier("");

  @override
  void initState() {
    super.initState();

    Future<void> _loadAnnonce() async {
      // Récupérer l'annonce
      Annonce? annonce = await _annonceService.getAnnonceId(widget.idAnnonce);
      if (annonce != null) {
        setState(() {
          _currentAnnonce = annonce; // Stocker l'annonce dans la variable
        });
        // Remplissez les champs du formulaire avec les informations de l'annonce
        _titreTextController.text = annonce.titre;
        _lieuTextController.text = annonce.lieu;
        _descriptionTextController.text = annonce.description;
        _url.value = annonce.image; // Si vous avez une image
        _selectedCategory.value =
            annonce.categorie; // Remplissez également la catégorie
        _selectedDate.value = annonce.date; // Remplissez la date
      }
    }

    // Appelez la fonction pour charger l'annonce
    _loadAnnonce();

    // Charger les catégories disponibles
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    List<Categorie> categories = await _annonceService.getAllCategories();
    _categories.value = categories;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate.value,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate.value),
      );

      if (pickedTime != null) {
        final DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        _selectedDate.value = pickedDateTime;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text("Modifier l'annonce"),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.02, 20, 0),
            child: Column(
              children: <Widget>[
                ValueListenableBuilder<String>(
                    valueListenable: _url,
                    builder: (context, url, child) {
                      return url == ""
                          ? Container(
                              height: MediaQuery.sizeOf(context).width * 0.6,
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
                                                  child: ElevatedButton.icon(
                                                    onPressed: () async {
                                                      String? newUrl =
                                                          await _userService
                                                              .uploadImage(
                                                                  context,
                                                                  _loading,
                                                                  _url);
                                                      if (newUrl != null) {
                                                        alerteMessageWidget(
                                                            context,
                                                            "Fichier enregistré avec succès !",
                                                            AppColors.success);
                                                      } else {
                                                        alerteMessageWidget(
                                                            context,
                                                            "Une erreur s'est produite !",
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
                                                              AppColors.black),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                    }),
                              ),
                            )
                          : Image.network(url);
                    }),
                SizedBox(height: 20),
                Align(
                    alignment: Alignment.centerLeft,
                    child: ValueListenableBuilder<List<Categorie>>(
                      valueListenable: _categories,
                      builder: (context, categories, child) {
                        return ValueListenableBuilder<Categorie?>(
                          valueListenable: _selectedCategory,
                          builder: (context, selectedCategory, child) {
                            return DropdownButton<Categorie>(
                              hint: Text('Catégorie'),
                              value: categories.contains(selectedCategory)
                                  ? selectedCategory
                                  : null,
                              onChanged: (Categorie? newValue) {
                                _selectedCategory.value = newValue;
                              },
                              items: categories
                                  .map<DropdownMenuItem<Categorie>>(
                                      (Categorie categorie) {
                                return DropdownMenuItem<Categorie>(
                                  value: categorie,
                                  child: Text(categorie.libelle),
                                );
                              }).toList(),
                            );
                          },
                        );
                      },
                    )),
                SizedBox(height: 20),
                reusableTextFormField(
                    "Titre", _titreTextController, (value) {}),
                SizedBox(height: 20),
                reusableTextFormField("Lieu", _lieuTextController, (value) {}),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _selectDateTime(context),
                  child: Row(children: [
                    Icon(Icons.calendar_month),
                    SizedBox(width: 5),
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
                SizedBox(height: 20),
                ReusableDescriptionInput(
                    "Description", _descriptionTextController, (value) {
                  return null;
                }),
                SizedBox(height: 20),
                SubmittedButton("Enregistrer", () async {
                  if (_currentAnnonce == null) {
                    alerteMessageWidget(
                        context, "Annonce non trouvée.", AppColors.echec);
                    return; // Assurez-vous que l'annonce existe
                  }

                  // Création de l'annonce avec les nouvelles données
                  Annonce updatedAnnonce = _currentAnnonce!.copyWith(
                    categorie:
                        _selectedCategory.value ?? _currentAnnonce!.categorie,
                    titre: _titreTextController.text,
                    date: _selectedDate.value,
                    description: _descriptionTextController.text,
                    lieu: _lieuTextController.text,
                    image: _url.value,
                  );

                  try {
                    String code =
                        await _annonceService.updateAnnonce(updatedAnnonce);
                    if (code == "OK") {
                      alerteMessageWidget(context,
                          "Annonce modifiée avec succès !", AppColors.success);
                      Navigator.pop(context); // Retourner à la page précédente
                      changerPage(context, AnnonceScreen());
                    }
                  } catch (e) {
                    alerteMessageWidget(context,
                        "Erreur lors de la modification : $e", AppColors.echec);
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
