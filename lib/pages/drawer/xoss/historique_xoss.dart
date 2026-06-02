import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/enums/statut_xoss.dart';
import 'package:new_app/models/xoss.dart';
import 'package:new_app/services/xoss_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:new_app/widgets/empty_state_widget.dart';

class HistoriqueXoss extends StatelessWidget {
  HistoriqueXoss({super.key});

  final XossService _xossService = XossService();
  final String _email = FirebaseAuth.instance.currentUser!.email!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des khoss'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Xoss>>(
        stream: _xossService.streamXossOfUser(_email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AppLoader());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement'));
          }
          final xossList = snapshot.data ?? [];
          if (xossList.isEmpty) {
            return EmptyStateWidget(
              message: 'Aucun khoss dans l\'historique.',
              icon: Icons.history,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: xossList.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _HistoriqueRow(xoss: xossList[index]),
          );
        },
      ),
    );
  }
}

class _HistoriqueRow extends StatelessWidget {
  final Xoss xoss;
  const _HistoriqueRow({required this.xoss});

  Color get _color {
    switch (xoss.statut) {
      case StatutXoss.PAYEE:
        return Colors.green;
      case StatutXoss.ATTENTE:
        return Colors.orange;
      case StatutXoss.IMPAYEE:
        return Colors.red;
    }
  }

  String get _label {
    switch (xoss.statut) {
      case StatutXoss.PAYEE:
        return 'Payé';
      case StatutXoss.ATTENTE:
        return 'En attente';
      case StatutXoss.IMPAYEE:
        return 'Impayé';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Indicateur statut
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  xoss.produit.join(', '),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  dateCustomformat(xoss.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // Montant + statut
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${xoss.montant} FCFA',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _color.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _label,
                  style: TextStyle(
                      color: _color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
