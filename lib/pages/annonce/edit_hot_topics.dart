import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/hot_topic.dart';
import 'package:new_app/pages/annonce/annonce_screen.dart';
import 'package:new_app/services/hot_topic_service.dart';
import 'dart:io';

import 'package:new_app/widgets/reusable_widgets.dart';
import 'package:new_app/widgets/submited_button.dart';

class EditHotTopicScreen extends StatefulWidget {
  final HotTopic hotTopic; // Le Hot Topic à modifier

  EditHotTopicScreen({required this.hotTopic});

  @override
  _EditHotTopicScreenState createState() => _EditHotTopicScreenState();
}

class _EditHotTopicScreenState extends State<EditHotTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  HotTopicService _hotTopicService = HotTopicService();
  String? _selectedCategory;
  String? _excelFileUrl; // URL du fichier Excel si joint
  File? _selectedFile;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  // Liste des catégories disponibles
  final List<String> _categories = ['restauration', 'bourse'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.hotTopic.title);
    _descriptionController =
        TextEditingController(text: widget.hotTopic.content);
    _selectedCategory = widget.hotTopic.category;
    _excelFileUrl = widget.hotTopic.fileUrl; // URL du fichier existant
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le Hot Topic'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              reusableTextFormField(
                'Titre',
                _titleController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              reusableTextFormField(
                'Description',
                _descriptionController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(labelText: 'Catégorie'),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner une catégorie';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _selectFile,
                icon: Icon(Icons.attach_file),
                label: Text(_selectedFile == null
                    ? (_excelFileUrl == null
                        ? 'Joindre un document (PDF, xlsx…)'
                        : 'Changer le document')
                    : 'Changer le document'),
              ),
              if (_excelFileUrl != null && _selectedFile == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Fichier existant : $_excelFileUrl'),
                ),
              SizedBox(height: 16),
              Center(child: SubmittedButton('Confirmer', _submitHotTopic)),
            ],
          ),
        ),
      ),
    );
  }

  // Sélectionner un document (PDF, xlsx, docx)
  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'xlsx', 'docx', 'doc'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  // Soumettre la mise à jour du Hot Topic
  Future<void> _submitHotTopic() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? fileUrl = _excelFileUrl;

        // Si un nouveau fichier est sélectionné, uploader dans Firebase Storage
        if (_selectedFile != null) {
          fileUrl = await _uploadExcelFile(_selectedFile!);
        }

        // Créer une instance de HotTopic mise à jour
        HotTopic updatedHotTopic = HotTopic(
          id: widget.hotTopic.id, // Conserver l'ID d'origine
          title: _titleController.text,
          content: _descriptionController.text,
          category: _selectedCategory!,
          fileUrl: fileUrl,
          dateCreation:
              widget.hotTopic.dateCreation, // Conserver la date d'origine
        );

        // Mettre à jour dans Firestore
        await _hotTopicService.updateHotTopic(updatedHotTopic);
        changerPage(context, AnnonceScreen());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hot Topic modifié avec succès')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  // Uploader le document dans Firebase Storage
  Future<String> _uploadExcelFile(File file) async {
    final ext = file.path.split('.').last;
    final fileName = 'hotTopics/${DateTime.now().millisecondsSinceEpoch}.$ext';
    UploadTask uploadTask =
        FirebaseStorage.instance.ref(fileName).putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }
}
