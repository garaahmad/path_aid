import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TransportRequestService {
  static const String _baseUrl = 'https://pathaid-backend.onrender.com/api';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<List<Map<String, dynamic>>> getAllTransportRequests() async {
    final url = Uri.parse('$_baseUrl/transportrequests');
    try {
      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        if (decodedData is List) {
          return decodedData.cast<Map<String, dynamic>>();
        }
        if (decodedData is Map && decodedData.containsKey('data')) {
          return (decodedData['data'] as List).cast<Map<String, dynamic>>();
        }
        throw Exception('تنسيق بيانات غير متوقع من الخادم');
      } else {
        throw Exception(
          'فشل تحميل الطلبات: كود ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('فشل جلب طلبات النقل: $e');
    }
  }

  static Future<Map<String, dynamic>> getTransportRequestById(
    int requestId,
  ) async {
    final url = Uri.parse('$_baseUrl/transportrequests/$requestId');
    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'فشل جلب الطلب برقم $requestId: كود ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('فشل جلب الطلب: $e');
    }
  }

  static Future<void> createTransportRequest({
    required int fromFacilityId,
    required int toFacilityId,
    required String patientName,
    required int patientAge,
    required DateTime transportTime,
    required String priority,
    String? notes,
  }) async {
    final body = json.encode({
      'fromFacilityId': fromFacilityId,
      'toFacilityId': toFacilityId,
      'patientName': patientName,
      'patientAge': patientAge,
      'transportTime': transportTime.toUtc().toIso8601String(),
      'priority': priority,
      'notes': notes,
      'status': TransportRequestStatus.PENDING,
    });

    final url = Uri.parse('$_baseUrl/transportrequests');
    try {
      final response = await http
          .post(url, headers: _headers, body: body)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 201) {
        final error = json.decode(response.body);
        throw Exception(error['info'] ?? 'فشل إنشاء طلب النقل');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateTransportRequest({
    required int id,
    required int fromFacilityId,
    required int toFacilityId,
    required String patientName,
    required int patientAge,
    required DateTime transportTime,
    required String priority,
    String? notes,
  }) async {
    final body = json.encode({
      'fromFacilityId': fromFacilityId,
      'toFacilityId': toFacilityId,
      'patientName': patientName,
      'patientAge': patientAge,
      'transportTime': transportTime.toUtc().toIso8601String(),
      'priority': priority,
      'notes': notes,
    });

    final url = Uri.parse('$_baseUrl/transportrequests/$id');
    try {
      final response = await http
          .put(url, headers: _headers, body: body)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['info'] ?? 'فشل تحديث طلب النقل');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateTransportRequestStatus({
    required int requestId,
    required String status,
  }) async {
    final url = Uri.parse('$_baseUrl/transportrequests/$requestId/status');

    final body = json.encode({'status': status});

    try {
      final response = await http
          .patch(url, headers: _headers, body: body)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return; 
      }
      else {
        if (response.body.isNotEmpty) {
          final error = json.decode(response.body);
          print('Full Error Body: ${response.body}');

          throw Exception(
            '${error['info'] ?? error['message'] ?? 'فشل تحديث حالة الطلب'} \n التفاصيل: $error',
          );
        }
        throw Exception(
          'فشل تحديث حالة الطلب: كود ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> assignDriverAndVehicle({
    required int requestId,
    required int driverId,
    required int vehicleId,
  }) async {
    final url = Uri.parse('$_baseUrl/transportrequests/$requestId/assign');
    final body = json.encode({'driverId': driverId, 'vehicleId': vehicleId});

    try {
      final response = await http
          .patch(url, headers: _headers, body: body)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          return json.decode(response.body);
        }
        return {'message': 'تم التعيين بنجاح'};
      } else {
        if (response.body.isNotEmpty) {
          final error = json.decode(response.body);
          throw Exception(error['info'] ?? 'فشل تعيين السائق والمركبة');
        }
        throw Exception(
          'فشل تعيين السائق والمركبة: كود ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> assignAndUpdateStatus({
    required int requestId,
    required int driverId,
    required int vehicleId,
    String status = TransportRequestStatus.ACCEPTED,
  }) async {
    try {
      await assignDriverAndVehicle(
        requestId: requestId,
        driverId: driverId,
        vehicleId: vehicleId,
      );
      if (status != TransportRequestStatus.PENDING) {
        await updateTransportRequestStatus(
          requestId: requestId,
          status: status,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
  static Future<void> assignDriverVehicleAndUpdateStatus({
    required int requestId,
    required int driverId,
    required int vehicleId,
    String status = TransportRequestStatus.ACCEPTED,
  }) async {
    await assignAndUpdateStatus(
      requestId: requestId,
      driverId: driverId,
      vehicleId: vehicleId,
      status: status,
    );
  }
  static Future<void> deleteTransportRequest(int requestId) async {
    final url = Uri.parse('$_baseUrl/transportrequests/$requestId');
    try {
      final response = await http.delete(url, headers: _headers);

      if (response.statusCode != 204 && response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['info'] ?? 'فشل حذف الطلب');
      }
    } catch (e) {
      rethrow;
    }
  }
}

class TransportRequestStatus {
  static const String PENDING = 'PENDING';
  static const String ACCEPTED = 'ACCEPTED'; 
  static const String ON_THE_WAY =
      'ON_THE_WAY';
  static const String ARRIVED_AT_FACILITY = 'ARRIVED_AT_FACILITY';
  static const String TRANSFERRED_TO_DESTINATION = 'TRANSFERRED_TO_DESTINATION';
  static const String COMPLETED = 'COMPLETED';
  static const String CANCELLED = 'CANCELLED';

  static String getArabicStatus(String status) {
    switch (status) {
      case PENDING:
        return 'معلق';
      case ACCEPTED:
        return 'مقبول (مُخصص)';
      case ON_THE_WAY:
        return 'في الطريق';
      case ARRIVED_AT_FACILITY:
        return 'وصل للمنشأة';
      case TRANSFERRED_TO_DESTINATION:
        return 'نُقل إلى الوجهة';
      case COMPLETED:
        return 'مكتمل';
      case CANCELLED:
        return 'ملغى';
      default:
        return 'غير محدد';
    }
  }
}
