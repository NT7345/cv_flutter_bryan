class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.lieuNaissance,
    required this.dateNaissance,
    required this.parente,
    this.imageUrl,
  });

  final int id;
  final String nom;
  final String postnom;
  final String prenom;
  final String lieuNaissance;
  final String dateNaissance;
  final String parente;
  final String? imageUrl;

  String get fullName => '$prenom $nom $postnom'.trim();

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final imageUrl = json['image_url'];
    if (id is! int && id is! String) {
      throw const FormatException('Identifiant de membre invalide.');
    }
    if (imageUrl != null && imageUrl is! String) {
      throw const FormatException('URL de photo de membre invalide.');
    }

    return FamilyMember(
      id: int.parse(id.toString()),
      nom: _requiredString(json, 'nom'),
      postnom: _requiredString(json, 'postnom'),
      prenom: _requiredString(json, 'prenom'),
      lieuNaissance: _requiredString(json, 'lieu_naissance'),
      dateNaissance: _requiredString(json, 'date_naissance'),
      parente: _requiredString(json, 'parente'),
      imageUrl: imageUrl,
    );
  }
}

class FamilyMemberDraft {
  const FamilyMemberDraft({
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.lieuNaissance,
    required this.dateNaissance,
    required this.parente,
  });

  final String nom;
  final String postnom;
  final String prenom;
  final String lieuNaissance;
  final String dateNaissance;
  final String parente;

  Map<String, String> toJson() => {
    'nom': nom,
    'postnom': postnom,
    'prenom': prenom,
    'lieu_naissance': lieuNaissance,
    'date_naissance': dateNaissance,
    'parente': parente,
  };
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw FormatException('Champ API invalide : $key.');
  }
  return value;
}
