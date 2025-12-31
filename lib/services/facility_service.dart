import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FacilityService {
  static const String _baseUrl = 'https://pathaid-backend.onrender.com/api';
  static const String _cacheKey = 'cached_facilities';
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static final Map<String, List<String>> _areaCityMap = {
    'NORTH': ['JABALIA', 'BEIT_LAHIA', 'BEIT_HANOUN'],
    'GAZA': ['WEST_GAZA', 'CENTRAL_GAZA', 'EAST_GAZA', 'GAZA'],
    'CENTER': ['NUSEIRAT', 'MAGHAZI', 'BUREIJ', 'DEIR_AL_BALAH', 'ZAWAIDA'],
    'SOUTH': ['KHAN_YOUNIS', 'RAFAH'],
  };

  static Future<List<Map<String, dynamic>>> getAllFacilities() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);

    try {
      final response = await http.get(Uri.parse('$_baseUrl/facilties'));

      if (response.statusCode == 200) {
        await prefs.setString(_cacheKey, response.body);
        List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (cachedData != null) {
        List<dynamic> data = json.decode(cachedData);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
          'فشل تحميل المنشآت. كود الحالة: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (cachedData != null) {
        List<dynamic> data = json.decode(cachedData);
        return data.cast<Map<String, dynamic>>();
      }
      throw Exception('فشل تحميل المنشآت: $e');
    }
  }

  static Future<void> createFacility({
    required String name,
    required String type,
    required String area,
    required String city,
  }) async {
    final url = Uri.parse('$_baseUrl/facilties');
    final body = json.encode({
      'name': name,
      'type': type,
      'area': area,
      'city': city,
    });

    try {
      final response = await http.post(url, headers: _headers, body: body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_cacheKey);
      } else {
        if (response.body.isNotEmpty) {
          try {
            final error = json.decode(response.body);
            throw Exception(error['info'] ?? 'فشل إنشاء المنشأة');
          } catch (_) {
            throw Exception('فشل إنشاء المنشأة: كود ${response.statusCode}');
          }
        }
        throw Exception('فشل إنشاء المنشأة: كود ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateFacility({
    required int facilityId,
    required String name,
    required String type,
    required String area,
    required String city,
  }) async {
    final url = Uri.parse('$_baseUrl/facilties/$facilityId');
    final body = json.encode({
      'name': name,
      'type': type,
      'area': area,
      'city': city,
    });

    try {
      final response = await http.put(url, headers: _headers, body: body);
      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_cacheKey);
      } else {
        if (response.body.isNotEmpty) {
          try {
            final error = json.decode(response.body);
            throw Exception(error['info'] ?? 'فشل تحديث المنشأة');
          } catch (_) {
            throw Exception('فشل تحديث المنشأة: كود ${response.statusCode}');
          }
        }
        throw Exception('فشل تحديث المنشأة: كود ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteFacility(int facilityId) async {
    final url = Uri.parse('$_baseUrl/facilties/$facilityId');
    try {
      final response = await http.delete(url, headers: _headers);
      if (response.statusCode == 204 || response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_cacheKey);
      } else {
        if (response.body.isNotEmpty) {
          try {
            final error = json.decode(response.body);
            throw Exception(
              error['info'] ?? 'فشل حذف المنشأة: ${response.statusCode}',
            );
          } catch (_) {
            throw Exception('فشل حذف المنشأة: كود ${response.statusCode}');
          }
        }
        throw Exception('فشل حذف المنشأة: كود ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<String>> getAreaCities(String area) async {
    final url = Uri.parse('$_baseUrl/$area/cities');
    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<String>();
      } else {
        print(
          'API failed for cities: ${response.statusCode}, falling back to local map',
        );
        return _areaCityMap[area] ?? [];
      }
    } catch (e) {
      print('Error fetching cities: $e, falling back to local map');
      return _areaCityMap[area] ?? [];
    }
  }

  static String getCityText(String? city) {
    switch (city) {
      case 'BEIT_HANOUN':
        return 'بيت حانون';
      case 'BEIT_LAHIA':
        return 'بيت لاهيا';
      case 'NUSEIRAT':
        return 'النصيرات';
      case 'DEIR_AL_BALAH':
        return 'دير البلح';
      case 'MAGHAZI':
        return 'المغازي';
      case 'BUREIJ':
        return 'البريج';
      case 'ZAWAIDA':
        return 'الزوايدة';
      case 'WEST_GAZA':
        return 'غرب غزة';
      case 'CENTRAL_GAZA':
        return 'وسط غزة';
      case 'EAST_GAZA':
        return 'شرق غزة';
      case 'KHAN_YOUNIS':
        return 'خانيونس';
      case 'RAFAH':
        return 'رفح';
      case 'JABALIA':
        return 'جباليا';
      case 'GAZA':
        return 'غزة';
      default:
        return city ?? 'غير محدد';
    }
  }

  static String getAreaText(String? area) {
    switch (area) {
      case 'NORTH':
        return 'الشمال';
      case 'GAZA':
        return 'غزة';
      case 'CENTER':
        return 'الوسطى';
      case 'SOUTH':
        return 'الجنوب';
      default:
        return area ?? 'غير محدد';
    }
  }
}
