import 'dart:convert';

import 'package:cv_flutter_bryan/models/family_member.dart';
import 'package:cv_flutter_bryan/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('normalizes and validates the API base URL', () {
    expect(
      ApiService.normalizeBaseUrl('  https://example.com/api/public/  '),
      'https://example.com/api/public',
    );
    expect(ApiService.isValidBaseUrl('ftp://example.com/api'), isFalse);
    expect(ApiService.isValidBaseUrl('not a URL'), isFalse);
  });

  test('login sends email and password to the account endpoint', () async {
    late http.Request request;
    final service = ApiService(
      baseUrl: 'https://example.com/api/public',
      client: MockClient((value) async {
        request = value;
        return _jsonResponse(200, {
          'success': true,
          'message': 'Connexion réussie',
          'data': {'id': 42, 'email': 'bryan@example.com'},
        });
      }),
    );

    final account = await service.login('bryan@example.com', 'password123');

    expect(request.method, 'POST');
    expect(request.url.path, '/api/public/accounts/login');
    expect(jsonDecode(request.body), {
      'email': 'bryan@example.com',
      'password': 'password123',
    });
    expect(account.id, 42);
    expect(account.email, 'bryan@example.com');
  });

  test(
    'family listing and CRUD use the documented routes and payload',
    () async {
      final requests = <http.Request>[];
      final memberJson = {
        'id': 1,
        'nom': 'Kabila',
        'postnom': 'Mwamba',
        'prenom': 'Jean',
        'lieu_naissance': 'Goma',
        'date_naissance': '1990-05-12',
        'parente': 'Frère',
        'image_url': null,
      };
      final service = ApiService(
        baseUrl: 'https://example.com/api/public',
        client: MockClient((request) async {
          requests.add(request);
          if (request.method == 'GET') {
            return _jsonResponse(200, {
              'success': true,
              'data': [memberJson],
            });
          }
          if (request.method == 'DELETE') {
            return _jsonResponse(200, {
              'success': true,
              'message': 'Membre supprimé',
            });
          }
          return _jsonResponse(request.method == 'POST' ? 201 : 200, {
            'success': true,
            'data': memberJson,
          });
        }),
      );
      const draft = FamilyMemberDraft(
        nom: 'Kabila',
        postnom: 'Mwamba',
        prenom: 'Jean',
        lieuNaissance: 'Goma',
        dateNaissance: '1990-05-12',
        parente: 'Frère',
      );

      final listed = await service.listFamilyMembers();
      final created = await service.createFamilyMember(draft);
      final updated = await service.updateFamilyMember(1, draft);
      await service.deleteFamilyMember(1);

      expect(listed, hasLength(1));
      expect(listed.single.fullName, 'Jean Kabila Mwamba');
      expect(created.id, 1);
      expect(updated.parente, 'Frère');
      expect(
        requests.map((request) => '${request.method} ${request.url.path}'),
        [
          'GET /api/public/famille-membres',
          'POST /api/public/famille-membres',
          'PUT /api/public/famille-membres/1',
          'DELETE /api/public/famille-membres/1',
        ],
      );
      expect(jsonDecode(requests[1].body), draft.toJson());
      expect(requests[1].headers['content-type'], 'application/json');
    },
  );

  test('API errors are surfaced with their validation details', () async {
    final service = ApiService(
      baseUrl: 'https://example.com/api/public',
      client: MockClient(
        (_) async => _jsonResponse(422, {
          'success': false,
          'message': 'Données invalides',
          'errors': {'nom': 'Le champ nom est obligatoire'},
        }),
      ),
    );

    await expectLater(
      service.register('bryan@example.com', 'password123'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 422)
            .having(
              (error) => error.message,
              'message',
              'Données invalides : Le champ nom est obligatoire',
            )
            .having(
              (error) => error.fieldErrors['nom'],
              'field error',
              'Le champ nom est obligatoire',
            ),
      ),
    );
  });
}

http.Response _jsonResponse(int statusCode, Object body) => http.Response(
  jsonEncode(body),
  statusCode,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
