class Parametre {
  final String id;
  final dynamic valeur;

  Parametre({
    required this.id,
    required this.valeur,
  });

  factory Parametre.fromJson(Map<String, dynamic> json, String docId) {
    return Parametre(
      id: docId,
      valeur: json[docId],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      id: valeur,
    };
  }
}
