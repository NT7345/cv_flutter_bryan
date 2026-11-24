import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../app_colors.dart';
import '../models/family_member.dart';
import '../services/api_service.dart';
import '../widgets/cv_widgets.dart';
import '../widgets/photo_picker_field.dart';

class FamilyMemberFormResult {
  const FamilyMemberFormResult({required this.member, this.image});

  final FamilyMemberDraft member;
  final XFile? image;
}

class FamilyPage extends StatefulWidget {
  const FamilyPage({required this.apiService, super.key});

  final ApiService apiService;

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  List<FamilyMember> _members = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final members = await widget.apiService.listFamilyMembers();
      if (!mounted) return;
      setState(() {
        _members = members;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      _setError(error.message);
    } on http.ClientException {
      _setError('Impossible de joindre l’API. Vérifiez le serveur et son URL.');
    } on TimeoutException {
      _setError('Le serveur ne répond pas. Réessayez dans quelques instants.');
    } on FormatException catch (error) {
      _setError(error.message);
    }
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  Future<void> _addMember() async {
    final result = await _showMemberForm();
    if (result == null || !mounted) return;

    setState(() => _isSaving = true);
    try {
      final member = await widget.apiService.createFamilyMember(
        result.member,
        image: result.image,
      );
      if (!mounted) return;
      setState(() {
        _members = [..._members, member];
        _isSaving = false;
      });
      _showMessage('Membre ajouté.');
    } on ApiException catch (error) {
      _finishWithError(error.message);
    } on http.ClientException {
      _finishWithError('Impossible de joindre l’API. Vérifiez votre serveur.');
    } on TimeoutException {
      _finishWithError('Le serveur ne répond pas. Réessayez.');
    } on FormatException catch (error) {
      _finishWithError(error.message);
    }
  }

  Future<void> _editMember(FamilyMember member) async {
    final result = await _showMemberForm(member: member);
    if (result == null || !mounted) return;

    setState(() => _isSaving = true);
    try {
      final updated = await widget.apiService.updateFamilyMember(
        member.id,
        result.member,
        image: result.image,
      );
      if (!mounted) return;
      setState(() {
        _members = [
          for (final item in _members)
            if (item.id == updated.id) updated else item,
        ];
        _isSaving = false;
      });
      _showMessage('Membre modifié.');
    } on ApiException catch (error) {
      _finishWithError(error.message);
    } on http.ClientException {
      _finishWithError('Impossible de joindre l’API. Vérifiez votre serveur.');
    } on TimeoutException {
      _finishWithError('Le serveur ne répond pas. Réessayez.');
    } on FormatException catch (error) {
      _finishWithError(error.message);
    }
  }

  Future<void> _deleteMember(FamilyMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce membre ?'),
        content: Text('Cette action supprimera ${member.fullName} de la base.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);
    try {
      await widget.apiService.deleteFamilyMember(member.id);
      if (!mounted) return;
      setState(() {
        _members = _members.where((item) => item.id != member.id).toList();
        _isSaving = false;
      });
      _showMessage('Membre supprimé.');
    } on ApiException catch (error) {
      _finishWithError(error.message);
    } on http.ClientException {
      _finishWithError('Impossible de joindre l’API. Vérifiez votre serveur.');
    } on TimeoutException {
      _finishWithError('Le serveur ne répond pas. Réessayez.');
    } on FormatException catch (error) {
      _finishWithError(error.message);
    }
  }

  Future<FamilyMemberFormResult?> _showMemberForm({FamilyMember? member}) {
    return showDialog<FamilyMemberFormResult>(
      context: context,
      builder: (context) => FamilyMemberFormDialog(member: member),
    );
  }

  void _finishWithError(String message) {
    if (!mounted) return;
    setState(() => _isSaving = false);
    _showMessage(message);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadMembers,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          PageContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: SectionHeading(
                        kicker: 'Mes proches',
                        title: 'Une famille, un repère.',
                      ),
                    ),
                    IconButton(
                      key: const ValueKey('refresh-family'),
                      tooltip: 'Actualiser la famille',
                      onPressed: _isLoading ? null : _loadMembers,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                const Text(
                  'Les personnes qui comptent et m’accompagnent au quotidien.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const ValueKey('add-family-member'),
                    onPressed: _isSaving ? null : _addMember,
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Ajouter un membre'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading && _members.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_errorMessage != null && _members.isEmpty)
                  _LoadError(message: _errorMessage!, onRetry: _loadMembers)
                else if (_members.isEmpty)
                  const _EmptyFamily()
                else ...[
                  if (_errorMessage != null)
                    _LoadError(message: _errorMessage!, onRetry: _loadMembers),
                  for (var index = 0; index < _members.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FamilyMemberCard(
                        member: _members[index],
                        colorIndex: index,
                        onEdit: () => _editMember(_members[index]),
                        onDelete: () => _deleteMember(_members[index]),
                      ),
                    ),
                ],
                const SizedBox(height: 8),
                const SoftCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppColors.green),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Les données sont chargées et modifiées via l’API. '
                          'Les photos restent facultatives.',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
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

class _FamilyMemberCard extends StatelessWidget {
  const _FamilyMemberCard({
    required this.member,
    required this.colorIndex,
    required this.onEdit,
    required this.onDelete,
  });

  final FamilyMember member;
  final int colorIndex;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _MemberAvatar(member: member, colorIndex: colorIndex),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  member.parente,
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${member.lieuNaissance} · ${member.dateNaissance}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Actions sur ${member.fullName}',
            onSelected: (action) {
              if (action == 'edit') onEdit();
              if (action == 'delete') onDelete();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Modifier')),
              PopupMenuItem(value: 'delete', child: Text('Supprimer')),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member, required this.colorIndex});

  final FamilyMember member;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final imageUrl = member.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return ProfileIllustration(size: 58, colorIndex: colorIndex);
    }
    return ClipOval(
      child: Image.network(
        imageUrl,
        width: 58,
        height: 58,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            ProfileIllustration(size: 58, colorIndex: colorIndex),
      ),
    );
  }
}

class _EmptyFamily extends StatelessWidget {
  const _EmptyFamily();

  @override
  Widget build(BuildContext context) {
    return const SoftCard(
      child: Row(
        children: [
          Icon(Icons.diversity_3_outlined, color: AppColors.green, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Aucun membre enregistré. Ajoutez-en un pour commencer.',
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(color: AppColors.ink, height: 1.4),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

class FamilyMemberFormDialog extends StatefulWidget {
  const FamilyMemberFormDialog({this.member, super.key});

  final FamilyMember? member;

  @override
  State<FamilyMemberFormDialog> createState() => _FamilyMemberFormDialogState();
}

class _FamilyMemberFormDialogState extends State<FamilyMemberFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;

  bool get _isEditing => widget.member != null;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    _controllers = {
      'nom': TextEditingController(text: member?.nom ?? ''),
      'postnom': TextEditingController(text: member?.postnom ?? ''),
      'prenom': TextEditingController(text: member?.prenom ?? ''),
      'lieu_naissance': TextEditingController(
        text: member?.lieuNaissance ?? '',
      ),
      'date_naissance': TextEditingController(
        text: member?.dateNaissance ?? '',
      ),
      'parente': TextEditingController(text: member?.parente ?? ''),
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
    if (text.length > maxLength) {
      return 'Maximum $maxLength caractères.';
    }
    return null;
  }

  String? _validateDate(String? value) {
    final required = _required(value, 10);
    if (required != null) return required;
    final text = value!.trim();
    final date = DateTime.tryParse(text);
    if (date == null ||
        '${date.year.toString().padLeft(4, '0')}-'
                '${date.month.toString().padLeft(2, '0')}-'
                '${date.day.toString().padLeft(2, '0')}' !=
            text) {
      return 'Utilisez le format AAAA-MM-JJ.';
    }
    if (date.isAfter(DateTime.now())) {
      return 'La date ne peut pas être dans le futur.';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      FamilyMemberFormResult(
        member: FamilyMemberDraft(
          nom: _controllers['nom']!.text.trim(),
          postnom: _controllers['postnom']!.text.trim(),
          prenom: _controllers['prenom']!.text.trim(),
          lieuNaissance: _controllers['lieu_naissance']!.text.trim(),
          dateNaissance: _controllers['date_naissance']!.text.trim(),
          parente: _controllers['parente']!.text.trim(),
        ),
        image: _image,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 650),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isEditing ? 'Modifier le membre' : 'Ajouter un membre',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                PhotoPickerField(
                  initialImageUrl: widget.member?.imageUrl,
                  onChanged: (image) => _image = image,
                ),
                const SizedBox(height: 16),
                _textField('Prénom', 'prenom', 50),
                const SizedBox(height: 12),
                _textField('Nom', 'nom', 50),
                const SizedBox(height: 12),
                _textField('Postnom', 'postnom', 50),
                const SizedBox(height: 12),
                _textField('Lieu de naissance', 'lieu_naissance', 100),
                const SizedBox(height: 12),
                _textField(
                  'Date de naissance (AAAA-MM-JJ)',
                  'date_naissance',
                  10,
                  validator: _validateDate,
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 12),
                _textField('Lien de parenté', 'parente', 50),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _submit,
                      child: Text(_isEditing ? 'Enregistrer' : 'Ajouter'),
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

  Widget _textField(
    String label,
    String key,
    int maxLength, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      key: ValueKey('member-$key'),
      controller: _controllers[key],
      maxLength: maxLength,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(labelText: label, counterText: ''),
      validator: validator ?? (value) => _required(value, maxLength),
    );
  }
}
