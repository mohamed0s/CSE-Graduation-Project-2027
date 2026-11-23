import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show Locale;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/location/models/user_location_model.dart';

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

abstract class LocationRepository {
  Future<LocationPermissionStatus> checkAndRequestPermission();
  Future<UserLocationModel?> getCurrentLocation();
  double calculateDistanceInKm(
      double startLat, double startLng, double endLat, double endLng);
  Future<void> openAppSettings();
}

class LocationRepositoryImpl implements LocationRepository {
  final Dio _dio;

  LocationRepositoryImpl({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 8),
              ),
            );

  @override
  Future<LocationPermissionStatus> checkAndRequestPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionStatus.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }

    return LocationPermissionStatus.granted;
  }

  @override
  Future<UserLocationModel?> getCurrentLocation() async {
    try {
      final bool isAr = LocaleSettings.currentLocale == AppLocale.ar;

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      String country = '';
      String city = '';
      String fullAddress = '';

      // 1. المحاولة الأساسية: تمرير Locale في الـ Constructor الخاص بـ Geocoding
      try {
        final geocoding = Geocoding(
          locale: isAr ? const Locale('ar', 'EG') : const Locale('en', 'US'),
        );

        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          country = place.country ?? '';
          city = (place.locality != null && place.locality!.isNotEmpty)
              ? place.locality!
              : (place.subAdministrativeArea ?? place.administrativeArea ?? '');
          fullAddress = [place.street, city, country]
              .where((e) => e != null && e.isNotEmpty)
              .join('، ');
        }
      } catch (_) {
        // ننتقل للـ Fallback تلقائياً
      }

      // 2. Fallback باستخدام OpenStreetMap Nominatim عبر Dio
      if (city.isEmpty || country.isEmpty) {
        final osmData = await _getAddressFromOSM(
          position.latitude,
          position.longitude,
          langCode: isAr ? 'ar' : 'en',
        );
        if (osmData != null) {
          city = city.isEmpty ? osmData.city : city;
          country = country.isEmpty ? osmData.country : country;
          fullAddress = fullAddress.isEmpty ? osmData.displayName : fullAddress;
        }
      }

      return UserLocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        city: city,
        country: country,
        fullAddress: fullAddress,
      );
    } catch (_) {
      return null;
    }
  }

  Future<({String city, String country, String displayName})?>
      _getAddressFromOSM(
    double lat,
    double lon, {
    required String langCode,
  }) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': lat,
          'lon': lon,
          'zoom': 16,
          'addressdetails': 1,
          'accept-language': langCode,
        },
        options: Options(
          headers: {'User-Agent': 'FindaMobileApp/1.0'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final address =
            response.data['address'] as Map<String, dynamic>? ?? {};
        final city = (address['city'] ??
                address['town'] ??
                address['state'] ??
                '')
            .toString();
        final country = (address['country'] ?? '').toString();
        final displayName = (response.data['display_name'] ?? '').toString();
        return (city: city, country: country, displayName: displayName);
      }
    } catch (_) {}
    return null;
  }

  @override
  double calculateDistanceInKm(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final meters =
        Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
    return double.parse((meters / 1000).toStringAsFixed(1));
  }

  @override
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}