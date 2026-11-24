import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/family_member.dart';

String get defaultApiBaseUrl {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2/api-test/public';
  }
  return 'http://localhost/api-test/public';
}

class ApiAccount {
  const ApiAccount({required this.id, required this.email});

  final int id;
  final String email;

  factory ApiAccount.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final email = json['email'];
    if ((id is! int && id is! String) || email is! String) {
      throw const FormatException('Compte renvoyé par l’API invalide.');
    }
    return ApiAccount(id: int.parse(id.toString()), email: email);
  }
}

class ApiException implements Exception {
  const ApiException({
    required this.message,
    required this.statusCode,
    this.fieldErrors = const {},
  });

  final String message;
  final int statusCode;
  final Map<String, String> fieldErrors;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({required String baseUrl, http.Client? client})
    : baseUrl = normalizeBaseUrl(baseUrl),
      _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  static bool isValidBaseUrl(String value) {
    try {
      normalizeBaseUrl(value);
      return true;
    } on FormatException {
      return false;
    }
  }

  static String normalizeBaseUrl(String value) {
    final url = value.trim();
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !uri.hasScheme ||
        !const ['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw const FormatException('Saisissez une URL HTTP(S) valide.');
    }
    return url.replaceFirst(RegExp(r'/+$'), '');
  }

  Future<ApiAccount> login(String email, String password) async {
    final response = await _request(
      'POST',
      'accounts/login',
      body: {'email': email.trim(), 'password': password},
    );
    return ApiAccount.fromJson(_dataObject(response));
  }

  Future<ApiAccount> register(String email, String password) async {
    final response = await _request(
      'POST',
      'accounts/register',
      body: {'email': email.trim(), 'password': password},
    );
    return ApiAccount.fromJson(_dataObject(response));
  }

  Future<List<FamilyMember>> listFamilyMembers() async {
    final response = await _request('GET', 'famille-membres');
    final data = response['data'];
    if (data is! List) {
      throw const FormatException('La liste de famille renvoyée est invalide.');
    }
    return data.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Un membre de famille est invalide.');
      }
      return FamilyMember.fromJson(item);
    }).toList();
  }

  Future<FamilyMember> createFamilyMember(FamilyMemberDraft member) async {
    final response = await _request(
      'POST',
      'famille-membres',
      body: member.toJson(),
    );
    return FamilyMember.fromJson(_dataObject(response));
  }

  Future<FamilyMember> updateFamilyMember(
    int id,
    FamilyMemberDraft member,
  ) async {
    final response = await _request(
      'PUT',
      'famille-membres/$id',
      body: member.toJson(),
    );
    return FamilyMember.fromJson(_dataObject(response));
  }

  Future<void> deleteFamilyMember(int id) async {
    await _request('DELETE', 'famille-membres/$id');
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, String>? body,
  }) async {
    final uri = Uri.parse('$baseUrl/$path');
    final response = await switch (method) {
      'GET' => _client.get(uri).timeout(const Duration(seconds: 15)),
      'POST' =>
        _client
            .post(uri, headers: _jsonHeaders, body: jsonEncode(body))
            .timeout(const Duration(seconds: 15)),
      'PUT' =>
        _client
            .put(uri, headers: _jsonHeaders, body: jsonEncode(body))
            .timeout(const Duration(seconds: 15)),
      'DELETE' =>
        _client
            .delete(uri, headers: _jsonHeaders)
            .timeout(const Duration(seconds: 15)),
      _ => throw ArgumentError.value(method, 'method'),
    };

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Réponse JSON de l’API invalide.');
    }
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['success'] != true) {
      final message = decoded['message'];
      final fieldErrors = _readFieldErrors(decoded['errors']);
      throw ApiException(
        message: _formatErrorMessage(
          message is String ? message : 'Erreur ${response.statusCode}.',
          fieldErrors,
        ),
        statusCode: response.statusCode,
        fieldErrors: fieldErrors,
      );
    }
    return decoded;
  }

  Map<String, dynamic> _dataObject(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Données renvoyées par l’API invalides.');
    }
    return data;
  }

  Map<String, String> _readFieldErrors(Object? errors) {
    if (errors is! Map<String, dynamic>) return const {};
    return {
      for (final entry in errors.entries)
        if (entry.value is String) entry.key: entry.value as String,
    };
  }

  String _formatErrorMessage(String message, Map<String, String> errors) {
    if (errors.isEmpty) return message;
    return '$message : ${errors.values.join('; ')}';
  }

  static const _jsonHeaders = {'Content-Type': 'application/json'};
}
