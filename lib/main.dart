import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/portfolio_screen.dart';

void main() {
  runApp(CvFlutterApp());
}

class CvFlutterApp extends StatelessWidget {
  CvFlutterApp({
    ApiService Function(String baseUrl)? apiServiceFactory,
    String? initialApiBaseUrl,
    super.key,
  }) : apiServiceFactory = apiServiceFactory ?? _createApiService,
       initialApiBaseUrl = initialApiBaseUrl ?? defaultApiBaseUrl;

  final ApiService Function(String baseUrl) apiServiceFactory;
  final String initialApiBaseUrl;

  static ApiService _createApiService(String baseUrl) =>
      ApiService(baseUrl: baseUrl);

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
      surface: AppColors.canvas,
    );

    return MaterialApp(
      title: 'CV • Bryan Ntambwe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: AppColors.canvas,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.canvas,
          foregroundColor: AppColors.ink,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.green, width: 1.5),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: AppColors.line),
          ),
        ),
      ),
      home: _AuthGate(
        apiServiceFactory: apiServiceFactory,
        initialApiBaseUrl: initialApiBaseUrl,
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate({
    required this.apiServiceFactory,
    required this.initialApiBaseUrl,
  });

  final ApiService Function(String baseUrl) apiServiceFactory;
  final String initialApiBaseUrl;

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  ApiService? _apiService;

  @override
  Widget build(BuildContext context) {
    final apiService = _apiService;
    if (apiService != null) {
      return PortfolioScreen(
        apiService: apiService,
        onSignOut: () => setState(() => _apiService = null),
      );
    }

    return LoginScreen(
      apiServiceFactory: widget.apiServiceFactory,
      initialApiBaseUrl: widget.initialApiBaseUrl,
      onAuthenticated: (service) => setState(() => _apiService = service),
    );
  }
}
