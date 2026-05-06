import 'dart:async';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: 5000,
      receiveTimeout: 5000,
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  Future<String?> getCurrentLocationLabel() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 8));

      final pretty = await _reverseGeocode(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (pretty != null && pretty.trim().isNotEmpty) {
        return pretty;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> normalizeGpsAddress(String? address) async {
    if (address == null) return null;
    final text = address.trim();
    if (!text.toUpperCase().startsWith('GPS:')) return null;

    final raw = text.substring(4).trim();
    final parts = raw.split(',');
    if (parts.length != 2) return null;

    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;

    return _reverseGeocode(latitude: lat, longitude: lng);
  }

  Future<String?> _reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final fromNominatim = await _reverseWithNominatim(
      latitude: latitude,
      longitude: longitude,
    );
    if (fromNominatim != null && fromNominatim.isNotEmpty) return fromNominatim;

    final fromBigDataCloud = await _reverseWithBigDataCloud(
      latitude: latitude,
      longitude: longitude,
    );
    if (fromBigDataCloud != null && fromBigDataCloud.isNotEmpty) {
      return fromBigDataCloud;
    }

    return null;
  }

  Future<String?> _reverseWithNominatim({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': latitude,
          'lon': longitude,
          'accept-language': 'vi',
        },
        options: Options(
          headers: {
            'User-Agent': 'secondhand-app/1.0 (location reverse geocoding)'
          },
        ),
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) return null;

      final address = data['address'];
      if (address is! Map<String, dynamic>) return null;

      final city = (address['city'] ?? address['town'] ?? address['county'] ?? '')
          .toString()
          .trim();
      final state = (address['state'] ?? '').toString().trim();

      if (city.isNotEmpty && state.isNotEmpty) {
        if (city.toLowerCase() == state.toLowerCase()) return city;
        return '$city, $state';
      }
      if (state.isNotEmpty) return state;
      if (city.isNotEmpty) return city;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _reverseWithBigDataCloud({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get(
        'https://api.bigdatacloud.net/data/reverse-geocode-client',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'localityLanguage': 'vi',
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) return null;

      final city = (data['city'] ?? '').toString().trim();
      final principalSubdivision =
          (data['principalSubdivision'] ?? '').toString().trim();

      // Keep address concise: only city/province for product listing.
      if (city.isNotEmpty && principalSubdivision.isNotEmpty) {
        if (city.toLowerCase() == principalSubdivision.toLowerCase()) {
          return city;
        }
        return '$city, $principalSubdivision';
      }

      if (principalSubdivision.isNotEmpty) return principalSubdivision;
      if (city.isNotEmpty) return city;
      return null;
    } catch (_) {
      return null;
    }
  }
}
