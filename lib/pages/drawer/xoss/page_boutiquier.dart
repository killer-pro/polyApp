import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/xoss.dart';
import 'package:new_app/pages/drawer/xoss/detail_xoss.dart';
import 'package:new_app/services/xoss_service.dart';
import 'package:new_app/widgets/app_loader.dart';

class XossListPage extends StatefulWidget {
  const XossListPage({Key? key}) : super(key: key);

  @override
  _XossListPageState createState() => _XossListPageState();
}

class _XossListPageState extends State<XossListPage> {
  final XossService _xossService = XossService();
  List<Xoss> _xossList = [];
  List<Xoss> _filteredXossList = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _loadXossList();
  }

  Color _getStatutColor(String statut) {
    switch (statut) {
      case "ATTENTE":
        return const Color.fromARGB(255, 157, 144, 24);
      case "PAYEE":
        return Colors.green;
      case "IMPAYEE":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _sortXossList() {
    _xossList.sort((a, b) {
      const statusOrder = {"ATTENTE": 1, "IMPAYEE": 2, "PAYEE": 3};

      int aOrder = statusOrder[a.statut.toString().split('.').last] ?? 4;
      int bOrder = statusOrder[b.statut.toString().split('.').last] ?? 4;

      return aOrder.compareTo(bOrder);
    });
  }

  Future<void> _loadXossList() async {
    try {
      List<Xoss> xoss = await _xossService.getAllXoss();
      setState(() {
        _xossList = xoss;
        _sortXossList();
        _filteredXossList = _xossList;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Une erreur est survenue : $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterXossList(String searchText) {
    setState(() {
      _filteredXossList = _xossList.where((xoss) {
        final fullName =
            "${xoss.user?.prenom ?? ''} ${xoss.user?.nom ?? ''}".toLowerCase();
        return fullName.contains(searchText.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liste des Prêts"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                _searchText = value;
                _filterXossList(_searchText);
              },
              decoration: InputDecoration(
                labelText: "Rechercher par nom ou prénom",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _buildXossList(),
          ),
        ],
      ),
    );
  }

  Widget _buildXossList() {
    if (_isLoading) {
      return Center(
        child: AppLoader(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!),
      );
    }

    if (_filteredXossList.isEmpty) {
      return Center(
        child: Text("Aucun prêt trouvé."),
      );
    }

    return ListView.builder(
      itemCount: _filteredXossList.length,
      itemBuilder: (context, index) {
        final xoss = _filteredXossList[index];
        return GestureDetector(
            onTap: () {
              changerPage(context, DetailXoss(xoss.id));
            },
            child: _buildXossItem(xoss));
      },
    );
  }

  Widget _buildXossItem(Xoss xoss) {
    String statut = xoss.statut.toString().split('.').last; // Obtenir le statut

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(Icons.person), // Icône utilisateur
        ),
        title: Text(
          "${xoss.user?.prenom ?? 'Prénom inconnu'} ${xoss.user?.nom ?? 'Nom inconnu'}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text("Montant: ${xoss.montant.toString()} FCFA"),
            Text(
              "Statut: $statut",
              style: TextStyle(
                color: _getStatutColor(statut), // Appliquer la couleur ici
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
