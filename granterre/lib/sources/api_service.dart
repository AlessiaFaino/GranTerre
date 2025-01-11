import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' ;

class ApiService {
  static const String baseUrl = 'https://appy-rpyutgfo7a-uc.a.run.app';
  static const String bearerToken = 'GranTerreToken';

  static Future<Response> callApi({
    required String path,
    required String method,
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    Uint8List? fileBytes,
  }) async {
    final uri = Uri.parse('$baseUrl/$path').replace(queryParameters: queryParameters);
    final headers = {
      'Authorization': 'Bearer $bearerToken',
      'Content-Type': 'application/json',
    };

    try {
      if (fileBytes != null && (method.toUpperCase() == 'POST' || method.toUpperCase() == 'PUT')) {
        final request = MultipartRequest(method.toUpperCase(), uri);
        request.headers.addAll(headers);
        request.files.add(MultipartFile.fromBytes("file", fileBytes, filename: "${body?["machine"]}.csv"));
        if (body != null) {
          request.fields.addAll(body.map((key, value) => MapEntry(key, value.toString())));
        }
        final streamedResponse = await request.send();
        return await Response.fromStream(streamedResponse);
      } else {
        switch (method.toUpperCase()) {
        case 'GET':
          return await get(uri, headers: headers);
        case 'POST':
          return await post(uri, headers: headers, body: json.encode(body));
        case 'PUT':
          return await put(uri, headers: headers, body: json.encode(body));
        case 'DELETE':
          return await delete(uri, headers: headers);
        default:
          throw Exception('Unsupported HTTP method: $method');
        }
      }
    } catch (e) {
      throw Exception('API call failed: $e');
    }
  }
}