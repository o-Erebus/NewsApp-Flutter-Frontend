import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:finalyear/constants/constants.dart';

class RequestHandler {
  static final RequestHandler _instance = RequestHandler._internal();
  factory RequestHandler() => _instance;
  RequestHandler._internal();

  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    final uri = Uri.parse(url);
    final token = await _getToken();

    final Map<String, String> defaultHeaders = {
      'Content-Type': 'application/json',
      if (token != null)
        'Authorization': 'Bearer $token'
      else
        'Authorization': 'Bearer ${Constants.secretKey}',
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    return http.get(uri, headers: defaultHeaders);
  }

  Future<http.Response> post(
    String url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    final token = await _getToken();

    final Map<String, String> defaultHeaders = {
      'Content-Type': 'application/json',
      if (token != null)
        'Authorization': 'Bearer $token'
      else
        'Authorization': 'Bearer ${Constants.secretKey}',
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    return http.post(uri, headers: defaultHeaders, body: jsonEncode(body));
  }

  Future<http.Response> put(
    String url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    final token = await _getToken();

    final Map<String, String> defaultHeaders = {
      'Content-Type': 'application/json',
      if (token != null)
        'Authorization': 'Bearer $token'
      else
        'Authorization': 'Bearer ${Constants.secretKey}',
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    return http.put(uri, headers: defaultHeaders, body: jsonEncode(body));
  }

  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    final token = await _getToken();

    final Map<String, String> defaultHeaders = {
      'Content-Type': 'application/json',
      if (token != null)
        'Authorization': 'Bearer $token'
      else
        'Authorization': 'Bearer ${Constants.secretKey}',
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    return http.delete(uri, headers: defaultHeaders);
  }

  Future<String?> _getToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }
}
