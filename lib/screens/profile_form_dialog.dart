import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../app_colors.dart';
import '../models/user_profile.dart';
import '../widgets/photo_picker_field.dart';

class ProfileFormResult {
  const ProfileFormResult({required this.profile, this.image});

  final UserProfileDraft profile;
  final XFile? image;
}

class ProfileFormDialog extends StatefulWidget {
  const ProfileFormDialog({required this.profile, super.key});

  final UserProfile profile;

  @override
  State<ProfileFormDialog> createState() => _ProfileFormDialogState();
}

class _ProfileFormDialogState extends State<ProfileFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _controllers = {
      'nom': TextEditingController(text: profile.nom),
      'titre': TextEditingController(text: profile.titre),
      'lieu': TextEditingController(text: profile.lieu),
      'telephone': TextEditingController(text: profile.telephone),
      'email': TextEditingController(text: profile.email),
      'resume': TextEditingController(text: profile.resume),
      'informations': TextEditingController(text: profile.informations),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _required(String? value, int maxLength) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Ce champ est obligatoire.';
    if (text.length > maxLength) return 'Maximum $maxLength caractères.';
    return null;
  }

  String? _optional(String? value, int maxLength) {
    if ((value?.trim().length ?? 0) > maxLength) {
      return 'Maximum $maxLength caractères.';
    }
    return null;
  }

  String? _email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return null;
    if (email.length > 100 ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Saisissez une adresse e-mail valide.';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      ProfileFormResult(
        profile: UserProfileDraft(
          nom: _controllers['nom']!.text.trim(),
          titre: _controllers['titre']!.text.trim(),
          lieu: _controllers['lieu']!.text.trim(),
          telephone: _controllers['telephone']!.text.trim(),
          email: _controllers['email']!.text.trim(),
          resume: _controllers['resume']!.text.trim(),
          informations: _controllers['informations']!.text.trim(),
        ),
        image: _image,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 700),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Modifier mon profil',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                PhotoPickerField(
                  initialImageUrl: widget.profile.imageUrl,
                  onChanged: (image) => _image = image,
                ),
                const SizedBox(height: 16),
                _field('Nom complet', 'nom', 100, required: true),
                const SizedBox(height: 12),
                _field('Titre ou profil', 'titre', 150, required: true),
                const SizedBox(height: 12),
                _field('Lieu', 'lieu', 150),
                const SizedBox(height: 12),
                _field(
                  'Téléphone',
                  'telephone',
                  30,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _field(
                  'E-mail de contact',
                  'email',
                  100,
                  keyboardType: TextInputType.emailAddress,
                  validator: _email,
                ),
                const SizedBox(height: 12),
                _field('Résumé', 'resume', 3000, required: true, maxLines: 4),
                const SizedBox(height: 12),
                _field(
                  'Informations complémentaires',
                  'informations',
                  4000,
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    FilledButton(
                      key: const ValueKey('save-profile'),
                      onPressed: _submit,
                      child: const Text('Enregistrer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    String key,
    int maxLength, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      key: ValueKey('profile-$key'),
      controller: _controllers[key],
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(labelText: label, counterText: ''),
      validator:
          validator ??
          (required
              ? (value) => _required(value, maxLength)
              : (value) => _optional(value, maxLength)),
    );
  }
}
