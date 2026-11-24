import '../models/user_profile.dart';

class EducationItem {
  const EducationItem({
    required this.period,
    required this.title,
    required this.place,
    this.detail,
  });

  final String period;
  final String title;
  final String place;
  final String? detail;
}

class ProjectItem {
  const ProjectItem({
    required this.name,
    required this.role,
    required this.description,
    required this.icon,
  });

  final String name;
  final String role;
  final String description;
  final String icon;
}

abstract final class CvData {
  static const name = 'NTAMBWE MATANDA BRYAN';
  static const shortName = 'Bryan Ntambwe';
  static const title =
      'Étudiant en Informatique Appliquée à la Gestion des Entreprises';
  static const city = 'Goma, République démocratique du Congo';
  static const phone = '+243 971 023 985';
  static const email = 'bryanntambwe07@gmail.com';
  static const github = 'https://github.com/NT7345';

  static const initialProfile = UserProfile(
    nom: name,
    titre: title,
    lieu: city,
    telephone: phone,
    email: email,
    resume:
        'Étudiant en dernière année de Licence à l’ISIG-Goma, passionné par '
        'les technologies de l’information, le développement d’applications et '
        'les solutions numériques au service des entreprises. Entrepreneur et '
        'responsable associatif, j’aime transformer les idées en projets concrets.',
    informations: '',
  );

  static const summary =
      'Étudiant en dernière année de Licence à l’ISIG-Goma, passionné par '
      'les technologies de l’information, le développement d’applications et '
      'les solutions numériques au service des entreprises. Entrepreneur et '
      'responsable associatif, j’aime transformer les idées en projets concrets.';

  static const education = [
    EducationItem(
      period: '2023 — Présent',
      title: 'Licence en Informatique Appliquée à la Gestion des Entreprises',
      place: 'Institut Supérieur d’Informatique et de Gestion · ISIG-Goma',
    ),
    EducationItem(
      period: 'Août — Novembre 2023',
      title: 'Formation en anglais',
      place: 'Aldeg Vision',
    ),
    EducationItem(
      period: '2017 — 2023',
      title: 'Diplôme d’État · Sciences',
      place: 'Études secondaires',
    ),
    EducationItem(
      period: '2017',
      title: 'Certificat de fin d’études primaires',
      place: 'Complexe Scolaire Maman Sophie',
    ),
  ];

  static const projects = [
    ProjectItem(
      name: 'RAFIKI',
      role: 'Fondateur · marque de vêtements',
      description:
          'Développement de la marque, identité visuelle, conception de '
          'produits et réflexion sur la stratégie commerciale.',
      icon: '✳',
    ),
    ProjectItem(
      name: 'GoMove',
      role: 'Initiateur · livraison et courses',
      description:
          'Conception d’un service de livraison et réflexion sur son '
          'organisation et ses solutions numériques.',
      icon: '↗',
    ),
    ProjectItem(
      name: 'Applications de gestion',
      role: 'Projets informatiques',
      description:
          'Applications de gestion pour une agence de voyages, un hôpital '
          'et un supermarché.',
      icon: '</>',
    ),
    ProjectItem(
      name: 'REDEMPTORIS MATER',
      role: 'Directeur de chœur · depuis 2022',
      description:
          'Direction de plus de 200 jeunes choristes, coordination des '
          'répétitions et organisation de concerts.',
      icon: '♫',
    ),
  ];

  static const skillGroups = [
    ('Développement', ['C#', 'C++', 'Python', 'HTML', 'CSS', 'Laravel']),
    ('Bases de données', ['MySQL', 'MongoDB']),
    (
      'Outils créatifs et bureautiques',
      ['Word', 'Excel', 'Canva', 'Photoshop', 'Lightroom'],
    ),
  ];

  static const languages = [
    ('Français', 'Très bon'),
    ('Anglais', 'Intermédiaire'),
    ('Swahili', 'Intermédiaire'),
  ];

  static const interests = [
    'Technologies',
    'Innovation numérique',
    'Entrepreneuriat',
    'Analyse de données',
    'Musique',
    'Direction chorale',
  ];
}
