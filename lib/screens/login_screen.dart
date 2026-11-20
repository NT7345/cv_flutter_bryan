import 'package:material_ui/material_ui.dart';

import '../app_colors.dart';
import '../widgets/cv_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.onAuthenticated, super.key});

  final VoidCallback onAuthenticated;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _demoUsername = 'bryan';
  static const _demoPassword = 'cvflutter2026';
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;

    if (_usernameController.text.trim() != _demoUsername ||
        _passwordController.text != _demoPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Identifiant ou mot de passe incorrect.')),
      );
      return;
    }

    widget.onAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, _) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 410),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 27,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'BIENVENUE',
                        style: TextStyle(
                          color: AppColors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Un aperçu de\nmon univers.',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          height: 1.08,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Connectez-vous pour découvrir mon parcours, '
                        'ma famille et mes coordonnées.',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 15,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 30),
                      SoftCard(
                        padding: const EdgeInsets.all(22),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Connexion',
                                style: TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Votre espace personnel',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 22),
                              TextFormField(
                                controller: _usernameController,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.username],
                                decoration: const InputDecoration(
                                  labelText: 'Identifiant',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? 'Saisissez votre identifiant.'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _hidePassword,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                onFieldSubmitted: (_) => _signIn(),
                                decoration: InputDecoration(
                                  labelText: 'Mot de passe',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    tooltip: _hidePassword
                                        ? 'Afficher le mot de passe'
                                        : 'Masquer le mot de passe',
                                    onPressed: () => setState(
                                      () => _hidePassword = !_hidePassword,
                                    ),
                                    icon: Icon(
                                      _hidePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Saisissez votre mot de passe.'
                                    : null,
                              ),
                              const SizedBox(height: 22),
                              FilledButton.icon(
                                onPressed: _signIn,
                                icon: const Icon(Icons.arrow_forward_rounded),
                                label: const Text('Se connecter'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.green,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECEFE7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.green,
                              size: 19,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Démo : bryan  ·  cvflutter2026\n'
                                'Connexion locale, sans serveur.',
                                style: TextStyle(
                                  color: AppColors.greenDark,
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
              ),
            );
          },
        ),
      ),
    );
  }
}
