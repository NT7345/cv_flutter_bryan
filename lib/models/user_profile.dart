class UserProfile {
  const UserProfile({
    required this.nom,
    required this.titre,
    required this.lieu,
    required this.telephone,
    required this.email,
    required this.resume,
    required this.informations,
    this.imageUrl,
  });

  final String nom;
  final String titre;
  final String lieu;
  final String telephone;
  final String email;
  final String resume;
  final String informations;
  final String? imageUrl;

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    required UserProfile initial,
  }) {
    if (json['is_initialized'] != true) {
      return initial.copyWith(imageUrl: _optionalString(json, 'image_url'));
    }

    return UserProfile(
      nom: _requiredString(json, 'nom'),
      titre: _requiredString(json, 'titre'),
      lieu: _requiredString(json, 'lieu'),
      telephone: _requiredString(json, 'telephone'),
      email: _requiredString(json, 'email'),
      resume: _requiredString(json, 'resume'),
      informations: _requiredString(json, 'informations'),
      imageUrl: _optionalString(json, 'image_url'),
    );
  }

  UserProfile copyWith({
    String? nom,
    String? titre,
    String? lieu,
    String? telephone,
    String? email,
    String? resume,
    String? informations,
    String? imageUrl,
  }) {
    return UserProfile(
      nom: nom ?? this.nom,
      titre: titre ?? this.titre,
      lieu: lieu ?? this.lieu,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      resume: resume ?? this.resume,
      informations: informations ?? this.informations,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class UserProfileDraft {
  const UserProfileDraft({
    required this.nom,
    required this.titre,
    required this.lieu,
    required this.telephone,
    required this.email,
    required this.resume,
    required this.informations,
  });

  final String nom;
  final String titre;
  final String lieu;
  final String telephone;
  final String email;
  final String resume;
  final String informations;

  UserProfile get asProfile => UserProfile(
    nom: nom,
    titre: titre,
    lieu: lieu,
    telephone: telephone,
    email: email,
    resume: resume,
    informations: informations,
  );

  Map<String, String> toJson() => {
    'nom': nom,
    'titre': titre,
    'lieu': lieu,
    'telephone': telephone,
    'email': email,
    'resume': resume,
    'informations': informations,
  };
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw FormatException('Champ de profil invalide : $key.');
  }
  return value;
}

String? _optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value != null && value is! String) {
    throw FormatException('Champ de profil invalide : $key.');
  }
  return value;
}
