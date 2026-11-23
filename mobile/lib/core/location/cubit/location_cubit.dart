import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/location/cubit/location_state.dart';
import 'package:mobile/core/location/repository/location_repository.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationRepository _repository;

  LocationCubit(this._repository) : super(const LocationInitial());

  Future<void> fetchCurrentLocation({
    bool showDialogOnDenied = false,
    bool forceRefresh = false,
  }) async {
    // استخدام الكاش لو الموقع متجاب قبل كده ومفيش طلب تحديث إجباري
    if (!forceRefresh && state.location != null) {
      emit(LocationSuccess(state.location!));
      return;
    }

    emit(LocationLoading(location: state.location));

    final status = await _repository.checkAndRequestPermission();

    if (status != LocationPermissionStatus.granted) {
      emit(
        LocationPermissionDenied(
          isPermanent: status == LocationPermissionStatus.deniedForever,
          showDialog: showDialogOnDenied,
          location: state.location,
        ),
      );
      return;
    }

    final userLocation = await _repository.getCurrentLocation();

    if (userLocation != null) {
      emit(LocationSuccess(userLocation));
    } else {
      emit(LocationError(location: state.location));
    }
  }

  void clearLocationSelection() {
    emit(const LocationInitial());
  }

  Future<void> openAppSettings() async {
    await _repository.openAppSettings();
  }
}