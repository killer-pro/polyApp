import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/enums/statut_xoss.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:new_app/models/xoss.dart';
import 'package:new_app/pages/drawer/xoss/admin_xoss_page.dart';
import 'package:new_app/pages/drawer/xoss/create_xoss.dart';
import 'package:new_app/pages/drawer/xoss/detail_xoss.dart';
import 'package:new_app/pages/drawer/xoss/historique_xoss.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/services/xoss_service.dart';
import 'package:new_app/utils/app_colors.dart';

class XossScreen extends StatefulWidget {
  const XossScreen({super.key});

  @override
  State<XossScreen> createState() => _XossScreenState();
}

class _XossScreenState extends State<XossScreen> {
  final XossService _xossService = XossService();
  final UserService _userService = UserService();
  final String _email = FirebaseAuth.instance.currentUser!.email!;
  bool _isAdminMb = false;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final user = await _userService.getUserByEmail(_email);
    if (mounted) {
      setState(() {
        _isAdminMb = user?.role.toString().contains('ADMIN') == true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        actions: [
          if (_isAdminMb)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              tooltip: 'Gestion khoss',
              onPressed: () => changerPage(context, const AdminXossPage()),
            ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: StreamBuilder<List<Xoss>>(
        stream: _xossService.streamXossOfUser(_email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AppLoader());
          }
          if (snapshot.hasError) {
            debugPrint('[XossScreen] stream error: ${snapshot.error}');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Erreur : ${snapshot.error}',
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ),
            );
          }

          final all = snapshot.data ?? [];
          // Liste principale : khoss en cours uniquement (IMPAYEE / ATTENTE)
          final xossList = all
              .where((x) => x.statut != StatutXoss.PAYEE)
              .toList();
          final totalMontant =
              xossList.fold(0, (sum, x) => sum + x.montant);
          final totalVersement =
              xossList.fold(0, (sum, x) => sum + x.versement);
          final restant = totalMontant - totalVersement;
          final userName = all.isNotEmpty
              ? '${all.first.user?.prenom ?? ''} ${(all.first.user?.nom ?? '').toUpperCase()}'
              : '';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Header avec carte et montant ----
                _XossHeader(restant: restant, userName: userName),

                const SizedBox(height: 16),

                // ---- Bouton historique ----
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () => changerPage(context, HistoriqueXoss()),
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text('Historique'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: orange,
                      side: const BorderSide(color: orange),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ---- Titre + bouton ajout ----
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text('Mes khoss',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => changerPage(context, const CreateXoss()),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: orange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ---- Liste des xoss ----
                if (xossList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('Aucun khoss pour le moment.',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ...xossList.map((x) => _XossCard(xoss: x)),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---- Header ----
class _XossHeader extends StatelessWidget {
  final int restant;
  final String userName;
  const _XossHeader({required this.restant, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      width: double.infinity,
      color: const Color.fromRGBO(250, 242, 230, 1),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Image de la carte
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/xoss/xoss_card.png',
              fit: BoxFit.fitWidth,
            ),
          ),
          // Texte superposé sur l'image
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (userName.isNotEmpty)
                  Text(
                    userName,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 4, color: Colors.black54)
                        ]),
                  ),
                const SizedBox(height: 4),
                Text(
                  '$restant FCFA restant',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: restant > 0 ? Colors.red[300] : Colors.green[300],
                    shadows: const [
                      Shadow(blurRadius: 6, color: Colors.black87)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Carte d'un xoss ----
class _XossCard extends StatelessWidget {
  final Xoss xoss;
  const _XossCard({required this.xoss});

  Color get _statutColor {
    switch (xoss.statut) {
      case StatutXoss.PAYEE:
        return Colors.green;
      case StatutXoss.ATTENTE:
        return Colors.orange;
      case StatutXoss.IMPAYEE:
        return Colors.red;
    }
  }

  String get _statutLabel {
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
    return GestureDetector(
      onTap: () => changerPage(context, DetailXoss(xoss.id)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- En-tête : titre + statut ----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Xossna',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statutColor.withAlpha(40),
                    border: Border.all(color: _statutColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_statutLabel,
                      style: TextStyle(
                          color: _statutColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ---- Produits + montant ----
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: xoss.produit
                        .map((p) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(p,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${xoss.montant} FCFA',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ---- Barre de progression versement ----
            if (xoss.versement > 0) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: xoss.versement / xoss.montant,
                  backgroundColor: Colors.white12,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(_statutColor),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${xoss.versement} / ${xoss.montant} FCFA versé',
                style:
                    const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],

            const SizedBox(height: 6),
            Text(dateCustomformat(xoss.date),
                style:
                    const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
