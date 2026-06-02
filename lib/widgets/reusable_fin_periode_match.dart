import 'package:flutter/material.dart';

Widget finPeriodeMatch(BuildContext context, List<String> periode) {
  String? selectedPeriode;
  TextEditingController score1Controller = TextEditingController();
  TextEditingController score2Controller = TextEditingController();

  return AlertDialog(
    title: Text('Fin de la période'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: 'Période'),
          initialValue: selectedPeriode,
          items: periode
              .map((String periode) =>
                  DropdownMenuItem(value: periode, child: Text(periode)))
              .toList(),
          onChanged: (value) {
            selectedPeriode = value;
          },
        ),
        TextField(
          controller: score1Controller,
          decoration: InputDecoration(labelText: 'Score Équipe 1'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: score2Controller,
          decoration: InputDecoration(labelText: 'Score Équipe 2'),
          keyboardType: TextInputType.number,
        ),
      ],
    ),
    actions: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(<String, dynamic>{});
            },
            child: Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop({
                'periode': selectedPeriode,
                'scoreA': int.tryParse(score1Controller.text) ?? 0,
                'scoreB': int.tryParse(score2Controller.text) ?? 0,
              });
            },
            child: Text('Valider'),
          ),
        ],
      )
    ],
  );
}
