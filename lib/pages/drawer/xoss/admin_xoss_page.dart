import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/enums/statut_xoss.dart';
import 'package:new_app/models/xoss.dart';
import 'package:new_app/services/xoss_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/alerte_message.dart';
import 'package:new_app/widgets/app_loader.dart';

class AdminXossPage extends StatefulWidget {
  const AdminXossPage({super.key});

  @override
  State<AdminXossPage> createState() => _AdminXossPageState();
}

class _AdminXossPageState extends State<AdminXossPage> {
  final XossService _xossService = XossService();
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion khoss'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ---- Barre de recherche ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un étudiant…',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: orange),
                ),
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),

          // ---- Liste groupée par utilisateur ----
          Expanded(
            child: StreamBuilder<List<Xoss>>(
              stream: _xossService.streamAllXoss(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: AppLoader());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Erreur de chargement'));
                }

                final all = snapshot.data ?? [];

                // Grouper par email utilisateur
                final Map<String, List<Xoss>> grouped = {};
                for (final x in all) {
                  final email = x.user?.email ?? 'inconnu';
                  grouped.putIfAbsent(email, () => []).add(x);
                }

                // Filtrer par recherche (nom ou prénom)
                final entries = grouped.entries.where((e) {
                  if (_query.isEmpty) return true;
                  final user = e.value.first.user;
                  final nom =
                      '${user?.prenom ?? ''} ${user?.nom ?? ''}'.toLowerCase();
                  return nom.contains(_query) ||
                      e.key.toLowerCase().contains(_query);
                }).toList();

                if (entries.isEmpty) {
                  return const Center(
                      child: Text('Aucun résultat.',
                          style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: entries.length,
                  itemBuilder: (context, i) =>
                      _UserXossCard(entry: entries[i], service: _xossService),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte d'un utilisateur avec ses khoss et bouton de paiement
class _UserXossCard extends StatefulWidget {
  final MapEntry<String, List<Xoss>> entry;
  final XossService service;

  const _UserXossCard({required this.entry, required this.service});

  @override
  State<_UserXossCard> createState() => _UserXossCardState();
}

class _UserXossCardState extends State<_UserXossCard> {
  bool _expanded = false;

  List<Xoss> get _encours => widget.entry.value
      .where((x) => x.statut != StatutXoss.PAYEE)
      .toList();

  int get _totalRestant => _encours.fold(
      0, (sum, x) => sum + (x.montant - x.versement));

  void _ouvrirDialogPaiement() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Paiement — ${widget.entry.value.first.user?.prenom ?? ''} ${(widget.entry.value.first.user?.nom ?? '').toUpperCase()}',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Restant dû : $_totalRestant FCFA',
                style: const TextStyle(
                    color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Montant reçu',
                suffixText: 'FCFA',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: orange),
            onPressed: () async {
              final montant = int.tryParse(ctrl.text.trim());
              if (montant == null || montant <= 0) return;
              Navigator.pop(context);
              try {
                await widget.service
                    .applyPayment(widget.entry.key, montant);
                if (mounted) {
                  alerteMessageWidget(context,
                      'Paiement de $montant FCFA appliqué.', AppColors.success);
                }
              } catch (e) {
                if (mounted) {
                  alerteMessageWidget(
                      context, 'Erreur : $e', AppColors.echec);
                }
              }
            },
            child: const Text('Valider',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.entry.value.first.user;
    final nom =
        '${user?.prenom ?? ''} ${(user?.nom ?? '').toUpperCase()}'.trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: orange.withAlpha(40),
              child: Text(
                nom.isNotEmpty ? nom[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: orange, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(nom,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              '$_totalRestant FCFA restant  •  ${_encours.length} en cours',
              style: TextStyle(
                color: _totalRestant > 0 ? Colors.red[400] : Colors.green,
                fontSize: 12,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_totalRestant > 0)
                  TextButton(
                    onPressed: _ouvrirDialogPaiement,
                    child: const Text('Payer',
                        style: TextStyle(color: orange)),
                  ),
                IconButton(
                  icon: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _expanded = !_expanded),
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            ..._encours.map((x) => _XossRow(xoss: x)),
            if (_encours.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Tous les khoss sont soldés.',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              ),
          ],
        ],
      ),
    );
  }
}

class _XossRow extends StatelessWidget {
  final Xoss xoss;
  const _XossRow({required this.xoss});

  @override
  Widget build(BuildContext context) {
    final restant = xoss.montant - xoss.versement;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(xoss.produit.join(', '),
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(dateCustomformat(xoss.date),
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${xoss.montant} FCFA',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              Text('$restant restant',
                  style: TextStyle(
                      color: Colors.red[400], fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
