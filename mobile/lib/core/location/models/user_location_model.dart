import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class UserLocationModel extends Equatable {
  final double latitude;
  final double longitude;
  final String city;
  final String country;
  final String fullAddress;

  const UserLocationModel({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
    this.fullAddress = '',
  });

  LatLng get latLng => LatLng(latitude, longitude);

  @override
  List<Object?> get props => [latitude, longitude, city, country, fullAddress];
}