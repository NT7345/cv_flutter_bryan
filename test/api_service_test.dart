import 'dart:convert';
import 'dart:typed_data';

import 'package:cv_flutter_bryan/models/family_member.dart';
import 'package:cv_flutter_bryan/models/user_profile.dart';
import 'package:cv_flutter_bryan/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
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

  test(
    'profile reads and JSON/multipart updates use the account profile route',
    () async {
      final requests = <http.BaseRequest>[];
      final service = ApiService(
        baseUrl: 'https://example.com/api/public',
        client: MockClient((request) async {
          requests.add(request);
          if (request.method == 'GET') {
            return _jsonResponse(200, {
              'success': true,
              'data': {'is_initialized': false, 'image_url': null},
            });
          }
          return _jsonResponse(200, {
            'success': true,
            'data': {
              'is_initialized': true,
              'nom': 'Bryan',
              'titre': 'Développeur',
              'lieu': 'Goma',
              'telephone': '+243900000000',
              'email': 'bryan@example.com',
              'resume': 'Résumé',
              'informations': '',
              'image_url': 'https://example.com/profile.png',
            },
          });
        }),
      );
      const initial = UserProfile(
        nom: 'Bryan initial',
        titre: 'Étudiant',
        lieu: 'Goma',
        telephone: '',
        email: '',
        resume: 'Résumé initial',
        informations: '',
      );
      const draft = UserProfileDraft(
        nom: 'Bryan',
        titre: 'Développeur',
        lieu: 'Goma',
        telephone: '+243900000000',
        email: 'bryan@example.com',
        resume: 'Résumé',
        informations: '',
      );

      final loaded = await service.getProfile(9, initial);
      final updated = await service.updateProfile(9, draft);
      final withPhoto = await service.updateProfile(
        9,
        draft,
        image: XFile.fromData(
          Uint8List.fromList([1, 2, 3]),
          name: 'profile.png',
          mimeType: 'image/png',
        ),
      );

      expect(loaded.nom, 'Bryan initial');
      expect(updated.nom, 'Bryan');
      expect(withPhoto.imageUrl, 'https://example.com/profile.png');
      expect(
        requests.map((request) => '${request.method} ${request.url.path}'),
        [
          'GET /api/public/accounts/9/profile',
          'PUT /api/public/accounts/9/profile',
          'POST /api/public/accounts/9/profile',
        ],
      );
      final upload = requests.last as http.Request;
      expect(upload.headers['content-type'], contains('multipart/form-data'));
      expect(upload.body, contains('name="nom"'));
      expect(upload.body, contains('name="image"'));
      expect(upload.body, contains('filename="photo.jpg"'));
    },
  );

  test(
    'family create and update send selected photos as multipart files',
    () async {
      final requests = <http.BaseRequest>[];
      const draft = FamilyMemberDraft(
        nom: 'Ntambwe',
        postnom: 'Matanda',
        prenom: 'Bryan',
        lieuNaissance: 'Goma',
        dateNaissance: '2000-01-01',
        parente: 'Frère',
      );
      final service = ApiService(
        baseUrl: 'https://example.com/api/public',
        client: MockClient((request) async {
          requests.add(request);
          return _jsonResponse(201, {
            'success': true,
            'data': {
              'id': 1,
              'nom': 'Ntambwe',
              'postnom': 'Matanda',
              'prenom': 'Bryan',
              'lieu_naissance': 'Goma',
              'date_naissance': '2000-01-01',
              'parente': 'Frère',
              'image_url': 'https://example.com/family.png',
            },
          });
        }),
      );
      final image = XFile.fromData(
        Uint8List.fromList([4, 5, 6]),
        name: 'family.png',
        mimeType: 'image/png',
      );

      await service.createFamilyMember(draft, image: image);
      await service.updateFamilyMember(1, draft, image: image);

      expect(
        requests.map((request) => '${request.method} ${request.url.path}'),
        [
          'POST /api/public/famille-membres',
          'POST /api/public/famille-membres/1',
        ],
      );
      final uploads = requests.cast<http.Request>();
      expect(
        uploads.every(
          (request) =>
              request.headers['content-type']!.contains('multipart/form-data'),
        ),
        isTrue,
      );
      expect(uploads.first.body, contains('name="image"'));
      expect(uploads.first.body, contains('filename="photo.jpg"'));
    },
  );
}

http.Response _jsonResponse(int statusCode, Object body) => http.Response(
  jsonEncode(body),
  statusCode,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
