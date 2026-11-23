import 'package:equatable/equatable.dart';
import 'package:mobile/core/location/models/user_location_model.dart';

sealed class LocationState extends Equatable {
  final UserLocationModel? location;
  const LocationState({this.location});

  @override
  List<Object?> get props => [location];
}

final class LocationInitial extends LocationState {
  const LocationInitial({super.location});
}

final class LocationLoading extends LocationState {
  const LocationLoading({super.location});
}

final class LocationSuccess extends LocationState {
  const LocationSuccess(UserLocationModel location) : super(location: location);
}

final class LocationPermissionDenied extends LocationState {
  final bool isPermanent;
  final bool showDialog;

  const LocationPermissionDenied({
    required this.isPermanent,
    required this.showDialog,
    super.location,
  });

  @override
  List<Object?> get props => [isPermanent, showDialog, location];
}

final class LocationError extends LocationState {
  const LocationError({super.location});
}