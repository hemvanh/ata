import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ata/models/http_exception.dart';

enum FetchType { POST, GET, PUT, PATCH, DELETE }

class Util {
  static Future<String> fetch(FetchType type, String url, [Map<String, dynamic> requestPayload = const {}]) async {
    try {
      http.Response response;
      switch (type) {
        case FetchType.POST:
          response = await http.post(
            url,
            body: json.encode(requestPayload),
          );
          break;
        case FetchType.GET:
          response = await http.get(
            url,
          );
          break;
        case FetchType.PUT:
          response = await http.put(
            url,
            body: json.encode(requestPayload),
          );
          break;
        case FetchType.PATCH:
          response = await http.patch(
            url,
            body: json.encode(requestPayload),
          );
          break;
        case FetchType.DELETE:
          response = await http.delete(
            url,
          );
          break;
      }
      return response.body;
    } catch (error) {
      throw HttpException('Network Error!');
    }
  }

  static Future<Map<String, String>> fetchDeviceIP() async {
    try {
      var responseText = await fetch(FetchType.GET, 'http://ip-api.com/json');
      final responseData = json.decode(responseText);
      return {
        'result': responseData['query'] ?? 'IP inspection service not available!',
      };
    } catch (error) {
      return {'error': error.toString()};
    }
  }
}
