import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_app/models/enums/statut_xoss.dart';
import 'package:new_app/models/xoss.dart';
import 'package:new_app/services/xoss_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/alerte_message.dart';

class CreateXoss extends StatefulWidget {
  const CreateXoss({super.key});

  @override
  State<CreateXoss> createState() => _CreateXossState();
}

class _CreateXossState extends State<CreateXoss> {
  final XossService _xossService = XossService();
  final _produitController = TextEditingController();
  final _montantController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> _produits = [];
  bool _saving = false;

  void _ajouterProduit() {
    final p = _produitController.text.trim();
    if (p.isEmpty) return;
    if (_produits.contains(p)) {
      alerteMessageWidget(context, 'Ce produit est déjà dans la liste.', AppColors.echec);
      return;
    }
    setState(() => _produits.add(p));
    _produitController.clear();
  }

  Future<void> _submit() async {
    if (_produits.isEmpty) {
      alerteMessageWidget(context, 'Ajoutez au moins un produit.', AppColors.echec);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final xoss = Xoss(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        montant: int.parse(_montantController.text.trim()),
        versement: 0,
        produit: List.from(_produits),
        statut: StatutXoss.IMPAYEE,
      );
      final code = await _xossService.postXoss(xoss);
      if (!mounted) return;
      if (code == 'OK') {
        alerteMessageWidget(context, 'Khoss créé avec succès !', AppColors.success);
        Navigator.pop(context);
      } else {
        alerteMessageWidget(context, 'Erreur lors de la création.', AppColors.echec);
      }
    } catch (e) {
      if (mounted) {
        alerteMessageWidget(context, 'Erreur : $e', AppColors.echec);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _produitController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau khoss'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ---- Section produits ----
            const Text('Produits',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),

            // Champ + bouton ajout
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _produitController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Ex: Café, Pain…',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: orange),
                      ),
                    ),
                    onFieldSubmitted: (_) => _ajouterProduit(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _ajouterProduit,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),

            // Chips des produits ajoutés
            if (_produits.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _produits
                    .map((p) => Chip(
                          label: Text(p),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => setState(() => _produits.remove(p)),
                          backgroundColor: orange.withAlpha(25),
                          side: const BorderSide(color: orange),
                          labelStyle: const TextStyle(fontSize: 13),
                        ))
                    .toList(),
              ),
            ],

            const SizedBox(height: 24),

            // ---- Montant ----
            const Text('Montant total',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _montantController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: '0',
                suffixText: 'FCFA',
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: orange),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Entrez un montant';
                if (int.tryParse(v) == null || int.parse(v) <= 0) {
                  return 'Montant invalide';
                }
                return null;
              },
            ),

            const SizedBox(height: 36),

            // ---- Bouton soumettre ----
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Enregistrer le khoss',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
