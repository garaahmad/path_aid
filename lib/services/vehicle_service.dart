import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VehicleService {
  static const String _baseUrl = 'https://pathaid-backend.onrender.com/api';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<List<Map<String, dynamic>>> getAllVehicles() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/vehicles'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(Duration(seconds: 20));
      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        if (decodedData is List) {
          return decodedData.cast<Map<String, dynamic>>();
        } else if (decodedData is Map) {
          if (decodedData.containsKey('info')) {
            throw Exception('خطأ من السيرفر: ${decodedData['info']}');
          }
          if (decodedData.containsKey('data') && decodedData['data'] is List) {
            return (decodedData['data'] as List).cast<Map<String, dynamic>>();
          }
          throw Exception('تنسيق البيانات غير متوقع: وصل كائن بدلاً من قائمة');
        } else {
          throw Exception('نوع البيانات غير معروف: ${decodedData.runtimeType}');
        }
      } else {
        throw Exception(
          'فشل الخادم: كود ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> createVehicle({
    required String code,
    required int capacity,
    required String status,
  }) async {
    final body = json.encode({
      'code': code,
      'capacity': capacity,
      'status': status,
    });

    final response = await http.post(
      Uri.parse('$_baseUrl/vehicles'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      if (response.body.isNotEmpty) {
        try {
          final error = json.decode(response.body);
          throw Exception(error['info'] ?? 'فشل إنشاء المركبة');
        } catch (e) {
          throw Exception('فشل إنشاء المركبة: كود ${response.statusCode}');
        }
      }
      throw Exception('فشل إنشاء المركبة: كود ${response.statusCode}');
    }
  }

  static Future<void> updateVehicle({
    required int vehicleId,
    required String code,
    required int capacity,
    required String status,
  }) async {
    final body = json.encode({
      'code': code,
      'capacity': capacity,
      'status': status,
    });

    final response = await http.put(
      Uri.parse('$_baseUrl/vehicles/$vehicleId'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204 &&
        response.statusCode != 201) {
      if (response.body.isNotEmpty) {
        try {
          final error = json.decode(response.body);
          throw Exception(error['info'] ?? 'فشل تحديث المركبة');
        } catch (e) {
          throw Exception('فشل تحديث المركبة: كود ${response.statusCode}');
        }
      }
      throw Exception('فشل تحديث المركبة: كود ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> getAvailableVehiclesForRequest(
    int requestId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/vehicles/available-for-request/$requestId'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(Duration(seconds: 20));

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
              throw Exception('لا يمكن تعيين مركبة لطلب في الماضي');
            }
          }
          throw Exception(error['info'] ?? 'فشل جلب المركبات المتاحة');
        } catch (e) {
          if (e.toString().contains('لا يمكن تعيين')) rethrow;
          throw Exception('فشل الخادم: كود ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteVehicle(int vehicleId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/vehicles/$vehicleId'),
      headers: _headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      if (response.body.isNotEmpty) {
        try {
          final error = json.decode(response.body);
          throw Exception(error['info'] ?? 'فشل حذف المركبة');
        } catch (e) {
          throw Exception('فشل حذف المركبة: كود ${response.statusCode}');
        }
      }
      throw Exception('فشل حذف المركبة: كود ${response.statusCode}');
    }
  }

  static String getStatusText(String? status) {
    switch (status) {
      case 'ACTIVE':
        return 'نشطة';
      case 'MAINTENANCE':
        return 'تحت الصيانة';
      default:
        return status ?? 'غير محدد';
    }
  }

  static Color getStatusColor(String? status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'MAINTENANCE':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  static String getType(String? type) {
    switch (type) {
      case 'AMBULANCE':
        return 'سيارة إسعاف';
      case 'TRANSPORT_VAN':
        return 'عربة نقل';
      default:
        return type ?? 'غير محدد';
    }
  }
}
