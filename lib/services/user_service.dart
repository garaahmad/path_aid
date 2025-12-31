import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const String _baseUrl = 'https://pathaid-backend.onrender.com/api';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final url = Uri.parse('$_baseUrl/users');
    try {
      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        if (decodedData is List) {
          return decodedData.cast<Map<String, dynamic>>();
        } else if (decodedData is Map && decodedData.containsKey('data')) {
          return (decodedData['data'] as List).cast<Map<String, dynamic>>();
        }
        throw Exception('تنسيق البيانات غير متوقع');
      } else {
        throw Exception('فشل تحميل المستخدمين: كود ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('فشل جلب المستخدمين: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAvailableDriversForRequest(
    int requestId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/users/available-for-request/$requestId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        if (decodedData is List) {
          return decodedData.cast<Map<String, dynamic>>();
        } else if (decodedData is Map && decodedData.containsKey('data')) {
          return (decodedData['data'] as List).cast<Map<String, dynamic>>();
        }
        throw Exception('تنسيق البيانات غير متوقع');
      } else {
        try {
          final error = json.decode(response.body);
          if (error['details'] != null &&
              error['details'] is List &&
              error['details'].isNotEmpty) {
            final detail = error['details'][0];
            if (detail['code'] == 'TRANSPORTREQUEST_IN_THE_PAST') {
              throw Exception('لا يمكن تعيين سائق لطلب وقته في الماضي');
            }
          }
          throw Exception(error['info'] ?? 'فشل جلب السائقين المتاحين');
        } catch (e) {
          if (e.toString().contains('لا يمكن تعيين')) rethrow;
          throw Exception('فشل الخادم: كود ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getUserById(int userId) async {
    final url = Uri.parse('$_baseUrl/users/$userId');
    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل جلب بيانات المستخدم');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users'),
        headers: _headers,
        body: json.encode(userData),
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
        String errorMessage = 'فشل إنشاء المستخدم';
        if (response.statusCode == 409) {
          errorMessage =
              'هذا المستخدم موجود مسبقاً (البريد أو الهاتف مستخدم بالفعل)';
        }

        if (response.body.isNotEmpty) {
          try {
            final error = json.decode(response.body);
            errorMessage = error['info'] ?? error['message'] ?? errorMessage;
          } catch (_) {}
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateUser(
    int userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: _headers,
        body: json.encode(userData),
      );
      if (response.statusCode != 200 &&
          response.statusCode != 204 &&
          response.statusCode != 201) {
        if (response.body.isNotEmpty) {
          try {
            final error = json.decode(response.body);
            throw Exception(error['info'] ?? 'فشل تحديث المستخدم');
          } catch (_) {
            throw Exception('فشل تحديث المستخدم: كود ${response.statusCode}');
          }
        }
        throw Exception('فشل تحديث المستخدم: كود ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteUser(int userId) async {
    try {
      print('Deleting user: $userId');
      final response = await http.delete(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: _headers,
      );
      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode != 204 && response.statusCode != 200) {
        if (response.body.isNotEmpty) {
          try {
            final error = json.decode(response.body);
            throw Exception(error['info'] ?? 'فشل حذف المستخدم');
          } catch (_) {
            throw Exception('فشل حذف المستخدم: كود ${response.statusCode}');
          }
        }
        throw Exception('فشل حذف المستخدم: كود ${response.statusCode}');
      }
    } catch (e) {
      print('Delete user error: $e');
      rethrow;
    }
  }
}
