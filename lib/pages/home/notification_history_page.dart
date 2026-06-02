import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:new_app/widgets/empty_state_widget.dart';

class NotificationHistoryPage extends StatelessWidget {
  const NotificationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('NOTIFICATION')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AppLoader());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement.'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return EmptyStateWidget(
              message: 'Aucune notification pour le moment.',
              icon: Icons.notifications_none_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final titre = data['titre'] as String? ?? '';
              final corps = data['corps'] as String? ?? '';
              final date = (data['date'] as Timestamp?)?.toDate();

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: orange.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_outlined,
                          color: orange, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(titre,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          if (corps.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(corps,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[700])),
                          ],
                          if (date != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(date),
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[500]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
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
    } else if (diff.inMinutes > 0) {
      return 'Il y a ${diff.inMinutes}min';
    } else {
      return 'À l\'instant';
    }
  }
}
