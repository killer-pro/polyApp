import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/models/avis.dart';
import 'package:new_app/models/utilisateur.dart';
import 'package:new_app/services/avis_service.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/alerte_message.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:new_app/widgets/empty_state_widget.dart';

class AvisPage extends StatefulWidget {
  const AvisPage({super.key});

  @override
  State<AvisPage> createState() => _AvisPageState();
}

class _AvisPageState extends State<AvisPage> {
  final AvisService _avisService = AvisService();
  final UserService _userService = UserService();

  List<Avis> _tous = [];
  Avis? _monAvis;
  Utilisateur? _moi;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final email = FirebaseAuth.instance.currentUser?.email;
    final results = await Future.wait([
      _avisService.getAllAvis(),
      if (email != null) _userService.getUserByEmail(email),
    ]);
    final tous = results[0] as List<Avis>;
    final moi = email != null ? results[1] as Utilisateur? : null;
    final monAvis = email != null
        ? tous.where((a) => a.userId == email).firstOrNull
        : null;
    setState(() {
      _tous = tous;
      _moi = moi;
      _monAvis = monAvis;
      _loading = false;
    });
  }

  void _ouvrirFormulaire({Avis? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AvisFormSheet(
        existing: existing,
        currentUser: _moi,
        onSaved: _load,
      ),
    );
  }

  Future<void> _supprimer(Avis avis) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer votre avis'),
        content: const Text('Voulez-vous vraiment supprimer votre avis ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _avisService.deleteAvis(avis.id);
      alerteMessageWidget(context, 'Avis supprimé.', AppColors.success);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;
    final autresAvis =
        _tous.where((a) => a.userId != email).toList();
    final double moy = _tous.isEmpty
        ? 0
        : _tous.map((a) => a.note).reduce((a, b) => a + b) / _tous.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avis'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: AppLoader())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ---- Résumé global ----
                  _SummaryCard(moyenne: moy, total: _tous.length),
                  const SizedBox(height: 20),

                  // ---- Mon avis ----
                  Text('Mon avis',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _monAvis != null
                      ? _AvisCard(
                          avis: _monAvis!,
                          isOwner: true,
                          onEdit: () => _ouvrirFormulaire(existing: _monAvis),
                          onDelete: () => _supprimer(_monAvis!),
                        )
                      : _BoutonEcrireAvis(
                          onTap: () => _ouvrirFormulaire()),

                  const SizedBox(height: 24),
                  if (autresAvis.isNotEmpty) ...[
                    Text('Avis des étudiants (${autresAvis.length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...autresAvis.map((a) => _AvisCard(avis: a)),
                  ] else if (_monAvis == null)
                    EmptyStateWidget(
                      message: 'Aucun avis pour le moment.\nSoyez le premier !',
                      icon: Icons.star_outline,
                    ),
                ],
              ),
            ),
    );
  }
}

// ---- Résumé (moyenne + étoiles) ----
class _SummaryCard extends StatelessWidget {
  final double moyenne;
  final int total;
  const _SummaryCard({required this.moyenne, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: orange.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                moyenne.toStringAsFixed(1),
                style:
                    const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              _StarRow(note: moyenne.round(), size: 28),
              Text('$total avis',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// ---- Carte d'un avis ----
class _AvisCard extends StatelessWidget {
  final Avis avis;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _AvisCard({
    required this.avis,
    this.isOwner = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isOwner ? orange.withAlpha(20) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: isOwner
            ? Border.all(color: orange.withAlpha(80))
            : Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage:
                    avis.photo != null && avis.photo!.isNotEmpty
                        ? NetworkImage(avis.photo!)
                        : null,
                backgroundColor: orange,
                child: avis.photo == null || avis.photo!.isEmpty
                    ? Text(
                        avis.prenom.isNotEmpty
                            ? avis.prenom[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${avis.prenom} ${avis.nom.toUpperCase()}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    _StarRow(note: avis.note, size: 14),
                  ],
                ),
              ),
              if (isOwner) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.red),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          if (avis.commentaire.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(avis.commentaire,
                style: const TextStyle(fontSize: 13, fontFamily: 'InterRegular')),
          ],
          const SizedBox(height: 4),
          Text(
            _formatDate(avis.updatedAt ?? avis.createdAt),
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) {
      return '${dt.day}/${dt.month}/${dt.year}';
    } else if (diff.inDays > 0) {
      return 'Il y a ${diff.inDays}j';
    } else if (diff.inHours > 0) {
      return 'Il y a ${diff.inHours}h';
    } else {
      return 'Il y a ${diff.inMinutes}min';
    }
  }
}

// ---- Bouton "Écrire un avis" ----
class _BoutonEcrireAvis extends StatelessWidget {
  final VoidCallback onTap;
  const _BoutonEcrireAvis({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_outlined, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text('Écrire votre avis',
                style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// ---- Ligne d'étoiles ----
class _StarRow extends StatelessWidget {
  final int note;
  final double size;
  const _StarRow({required this.note, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < note ? Icons.star : Icons.star_outline,
          color: Colors.amber,
          size: size,
        ),
      ),
    );
  }
}

// ---- Bottom sheet formulaire ----
class _AvisFormSheet extends StatefulWidget {
  final Avis? existing;
  final Utilisateur? currentUser;
  final VoidCallback onSaved;

  const _AvisFormSheet({this.existing, this.currentUser, required this.onSaved});

  @override
  State<_AvisFormSheet> createState() => _AvisFormSheetState();
}

class _AvisFormSheetState extends State<_AvisFormSheet> {
  final AvisService _service = AvisService();
  final TextEditingController _commentController = TextEditingController();
  int _note = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _note = widget.existing!.note;
      _commentController.text = widget.existing!.commentaire;
    }
  }

  Future<void> _save() async {
    if (_note == 0) {
      alerteMessageWidget(
          context, 'Veuillez sélectionner une note.', AppColors.echec);
      return;
    }
    setState(() => _saving = true);
    try {
      final email = FirebaseAuth.instance.currentUser?.email ?? '';
      if (widget.existing != null) {
        final updated = Avis(
          id: widget.existing!.id,
          userId: widget.existing!.userId,
          prenom: widget.existing!.prenom,
          nom: widget.existing!.nom,
          photo: widget.existing!.photo,
          note: _note,
          commentaire: _commentController.text.trim(),
          createdAt: widget.existing!.createdAt,
          updatedAt: DateTime.now(),
        );
        await _service.updateAvis(updated);
        alerteMessageWidget(context, 'Avis modifié.', AppColors.success);
      } else {
        final avis = Avis(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: email,
          prenom: widget.currentUser?.prenom ?? '',
          nom: widget.currentUser?.nom ?? '',
          photo: widget.currentUser?.photo,
          note: _note,
          commentaire: _commentController.text.trim(),
          createdAt: DateTime.now(),
        );
        await _service.createAvis(avis);
        alerteMessageWidget(context, 'Avis publié !', AppColors.success);
      }
      Navigator.pop(context);
      widget.onSaved();
    } catch (e) {
      alerteMessageWidget(
          context, 'Erreur : $e', AppColors.echec);
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.existing != null ? 'Modifier votre avis' : 'Votre avis',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Sélecteur d'étoiles
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                final selected = i < _note;
                return GestureDetector(
                  onTap: () => setState(() => _note = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      selected ? Icons.star : Icons.star_outline,
                      color: Colors.amber,
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Partagez votre expérience avec PolyApp...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
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
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      widget.existing != null ? 'Enregistrer' : 'Publier',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
