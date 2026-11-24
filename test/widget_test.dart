import 'dart:convert';

import 'package:cv_flutter_bryan/main.dart';
import 'package:cv_flutter_bryan/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('login checks credentials with the API before opening the app', (
    tester,
  ) async {
    _usePhoneViewport(tester);
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['email'] != 'bryan@example.com' ||
          body['password'] != 'password123') {
        return _jsonResponse(401, {
          'success': false,
          'message': 'Email ou mot de passe incorrect',
        });
      }
      return _jsonResponse(200, {
        'success': true,
        'message': 'Connexion réussie',
        'data': {'id': 7, 'email': 'bryan@example.com'},
      });
    });

    await tester.pumpWidget(
      CvFlutterApp(
        initialApiBaseUrl: 'http://api.test/public',
        apiServiceFactory: (url) => ApiService(baseUrl: url, client: client),
      ),
    );

    expect(find.text('Se connecter'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'wrong@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'wrongpass',
    );
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('Email ou mot de passe incorrect'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'bryan@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'password123',
    );
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.text('Mon parcours'), findsOneWidget);
    expect(requests, hasLength(3));
    expect(
      requests.take(2).every((request) => request.method == 'POST'),
      isTrue,
    );
    expect(
      requests
          .take(2)
          .every((request) => request.url.path == '/public/accounts/login'),
      isTrue,
    );
    expect(requests.last.url.path, '/public/famille-membres');
  });

  testWidgets('account registration sends data to the API then logs in', (
    tester,
  ) async {
    _usePhoneViewport(tester);
    final paths = <String>[];
    final client = MockClient((request) async {
      paths.add(request.url.path);
      final data = request.method == 'POST'
          ? {'id': 8, 'email': 'new@example.com'}
          : <String, Object>{};
      return _jsonResponse(request.url.path.endsWith('/register') ? 201 : 200, {
        'success': true,
        'message': 'OK',
        'data': data,
      });
    });

    await tester.pumpWidget(
      CvFlutterApp(
        initialApiBaseUrl: 'http://api.test/public',
        apiServiceFactory: (url) => ApiService(baseUrl: url, client: client),
      ),
    );

    await tester.tap(find.text('Pas encore de compte ? Créer un compte'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'new@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'password123',
    );
    await tester.tap(find.text('Créer mon compte'));
    await tester.pumpAndSettle();

    expect(find.text('Mon parcours'), findsOneWidget);
    expect(paths, [
      '/public/accounts/register',
      '/public/accounts/login',
      '/public/famille-membres',
    ]);
  });

  testWidgets('family page reads and applies CRUD operations through API', (
    tester,
  ) async {
    _usePhoneViewport(tester);
    final calls = <String>[];
    final members = <Map<String, dynamic>>[];
    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      if (request.url.path.endsWith('/accounts/login')) {
        return _jsonResponse(200, {
          'success': true,
          'data': {'id': 7, 'email': 'bryan@example.com'},
        });
      }
      if (request.method == 'GET') {
        return _jsonResponse(200, {'success': true, 'data': members});
      }

      final id = request.url.path.split('/').last;
      final requestBody = request.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(request.body) as Map<String, dynamic>;
      if (request.method == 'POST') {
        final created = {'id': 1, ...requestBody, 'image_url': null};
        members.add(created);
        return _jsonResponse(201, {'success': true, 'data': created});
      }
      if (request.method == 'PUT') {
        final updated = {
          'id': int.parse(id),
          ...requestBody,
          'image_url': null,
        };
        members[0] = updated;
        return _jsonResponse(200, {'success': true, 'data': updated});
      }
      if (request.method == 'DELETE') {
        members.clear();
        return _jsonResponse(200, {
          'success': true,
          'message': 'Membre supprimé',
        });
      }
      return _jsonResponse(405, {
        'success': false,
        'message': 'Méthode non autorisée',
      });
    });

    await tester.pumpWidget(
      CvFlutterApp(
        initialApiBaseUrl: 'http://api.test/public',
        apiServiceFactory: (url) => ApiService(baseUrl: url, client: client),
      ),
    );
    await _signIn(tester);
    await tester.tap(find.text('Famille'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Aucun membre enregistré.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('add-family-member')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('member-prenom')), 'Jean');
    await tester.enterText(find.byKey(const ValueKey('member-nom')), 'Kabila');
    await tester.enterText(
      find.byKey(const ValueKey('member-postnom')),
      'Mwamba',
    );
    await tester.enterText(
      find.byKey(const ValueKey('member-lieu_naissance')),
      'Goma',
    );
    await tester.enterText(
      find.byKey(const ValueKey('member-date_naissance')),
      '1990-05-12',
    );
    await tester.enterText(
      find.byKey(const ValueKey('member-parente')),
      'Frère',
    );
    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();
    expect(find.text('Jean Kabila Mwamba'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('refresh-family')));
    await tester.pumpAndSettle();
    expect(find.text('Jean Kabila Mwamba'), findsOneWidget);

    await tester.tap(find.byTooltip('Actions sur Jean Kabila Mwamba'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('member-lieu_naissance')),
      'Bukavu',
    );
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Bukavu · 1990-05-12'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('refresh-family')));
    await tester.pumpAndSettle();
    expect(find.text('Bukavu · 1990-05-12'), findsOneWidget);

    await tester.tap(find.byTooltip('Actions sur Jean Kabila Mwamba'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Aucun membre enregistré.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('refresh-family')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Aucun membre enregistré.'), findsOneWidget);

    expect(calls, contains('GET /public/famille-membres'));
    expect(calls, contains('POST /public/famille-membres'));
    expect(calls, contains('PUT /public/famille-membres/1'));
    expect(calls, contains('DELETE /public/famille-membres/1'));
  });

  testWidgets('password remains masked on the login screen', (tester) async {
    _usePhoneViewport(tester);
    await tester.pumpWidget(CvFlutterApp());

    final passwordField = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey('login-password')),
        matching: find.byType(TextField),
      ),
    );
    expect(passwordField.obscureText, isTrue);
  });
}

Future<void> _signIn(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const ValueKey('login-email')),
    'bryan@example.com',
  );
  await tester.enterText(
    find.byKey(const ValueKey('login-password')),
    'password123',
  );
  await tester.tap(find.text('Se connecter'));
  await tester.pumpAndSettle();
}

http.Response _jsonResponse(int statusCode, Object body) => http.Response(
  jsonEncode(body),
  statusCode,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void _usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
