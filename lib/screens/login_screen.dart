import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

import '../app_colors.dart';
import '../services/api_service.dart';
import '../widgets/cv_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.onAuthenticated,
    required this.apiServiceFactory,
    required this.initialApiBaseUrl,
    super.key,
  });

  final ValueChanged<ApiService> onAuthenticated;
  final ApiService Function(String baseUrl) apiServiceFactory;
  final String initialApiBaseUrl;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _apiUrlController = TextEditingController(
    text: widget.initialApiBaseUrl,
  );
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  ApiService? _apiService;
  String? _serviceBaseUrl;
  bool _hidePassword = true;
  bool _isRegistering = false;
  bool _isBusy = false;

  @override
  void dispose() {
    _apiUrlController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  ApiService _serviceForCurrentUrl() {
    final baseUrl = _apiUrlController.text.trim();
    if (_apiService == null || _serviceBaseUrl != baseUrl) {
      _apiService = widget.apiServiceFactory(baseUrl);
      _serviceBaseUrl = baseUrl;
    }
    return _apiService!;
  }

  Future<void> _submit() async {
    if (_isBusy || !_formKey.currentState!.validate()) return;

    setState(() => _isBusy = true);
    try {
      final service = _serviceForCurrentUrl();
      if (_isRegistering) {
        await service.register(_emailController.text, _passwordController.text);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte créé. Connexion en cours…')),
        );
      }

      await service.login(_emailController.text, _passwordController.text);
      if (!mounted) return;
      widget.onAuthenticated(service);
    } on ApiException catch (error) {
      _showError(error.message);
    } on http.ClientException {
      _showError('Impossible de joindre l’API. Vérifiez son URL et son état.');
    } on TimeoutException {
      _showError('Le serveur ne répond pas. Réessayez dans quelques instants.');
    } on FormatException catch (error) {
      _showError(error.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Saisissez votre adresse e-mail.';
    if (email.length > 100 ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Saisissez une adresse e-mail valide.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Saisissez votre mot de passe.';
    }
    if (_isRegistering && value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
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
                  const SizedBox(height: 28),
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
                  const SizedBox(height: 26),
                  SoftCard(
                    padding: const EdgeInsets.all(22),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _isRegistering ? 'Créer un compte' : 'Connexion',
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isRegistering
                                ? 'Votre compte sera enregistré sur le serveur.'
                                : 'Connectez-vous avec votre compte API.',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            key: const ValueKey('login-email'),
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                              labelText: 'Adresse e-mail',
                              prefixIcon: Icon(Icons.alternate_email_rounded),
                            ),
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 13),
                          TextFormField(
                            key: const ValueKey('login-password'),
                            controller: _passwordController,
                            obscureText: _hidePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) => _submit(),
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
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 13),
                          TextFormField(
                            key: const ValueKey('api-base-url'),
                            controller: _apiUrlController,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'URL de base de l’API',
                              prefixIcon: Icon(Icons.dns_outlined),
                              helperText: 'Sur Android, utilisez l’IP du serveur local.',
                              helperMaxLines: 2,
                            ),
                            validator: (value) =>
                                ApiService.isValidBaseUrl(value ?? '')
                                ? null
                                : 'Saisissez une URL HTTP(S) valide.',
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: _isBusy ? null : _submit,
                            icon: _isBusy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    _isRegistering
                                        ? Icons.person_add_alt_1_rounded
                                        : Icons.arrow_forward_rounded,
                                  ),
                            label: Text(
                              _isBusy
                                  ? 'Connexion…'
                                  : _isRegistering
                                  ? 'Créer mon compte'
                                  : 'Se connecter',
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: _isBusy
                                ? null
                                : () => setState(() {
                                    _isRegistering = !_isRegistering;
                                    _formKey.currentState?.reset();
                                  }),
                            child: Text(
                              _isRegistering
                                  ? 'J’ai déjà un compte · Se connecter'
                                  : 'Pas encore de compte ? Créer un compte',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Les opérations sur la famille utilisent la base de données '
                    'de l’API. Le serveur fourni ne protège pas lui-même ses '
                    'routes famille par une session.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
