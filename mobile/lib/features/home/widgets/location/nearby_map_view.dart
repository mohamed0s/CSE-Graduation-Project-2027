import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/core/di/injection_container.dart';
import 'package:mobile/core/location/repository/location_repository.dart';
import 'package:mobile/core/utils/extensions.dart';
import 'package:mobile/features/home/models/suggestion_item_model.dart';
import 'package:mobile/features/home/widgets/location/place_map_markers.dart';
import 'package:mobile/features/home/widgets/location/pulsing_location_marker.dart';
import 'package:mobile/features/home/widgets/location/selected_place_map_card.dart';

class NearbyMapView extends StatefulWidget {
  final double latitude;
  final double longitude;
  final List<SuggestionItemModel> suggestions;

  const NearbyMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.suggestions,
  });

  @override
  State<NearbyMapView> createState() => _NearbyMapViewState();
}

class _NearbyMapViewState extends State<NearbyMapView>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final LocationRepository _locationRepo = getIt<LocationRepository>();

  late final AnimationController _cameraController;
  late final AnimationController _pulseController;

  SuggestionItemModel? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _cameraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  Future<void> _startCityToUserZoom() async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    _cameraController.reset();

    final target = LatLng(widget.latitude, widget.longitude);
    final cityOverview = LatLng(
      widget.latitude + 0.035,
      widget.longitude + 0.035,
    );

    final latTween = Tween<double>(
      begin: cityOverview.latitude,
      end: target.latitude,
    );
    final lngTween = Tween<double>(
      begin: cityOverview.longitude,
      end: target.longitude,
    );
    final zoomTween = Tween<double>(begin: 11.8, end: 14.5);

    final curved = CurvedAnimation(
      parent: _cameraController,
      curve: Curves.easeInOutCubic,
    );

    void listener() {
      if (!mounted) return;
      _mapController.move(
        LatLng(latTween.evaluate(curved), lngTween.evaluate(curved)),
        zoomTween.evaluate(curved),
      );
    }

    _cameraController.addListener(listener);
    await _cameraController.forward();
    _cameraController.removeListener(listener);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final userPoint = LatLng(widget.latitude, widget.longitude);
    final initialCityPoint = LatLng(
      widget.latitude + 0.035,
      widget.longitude + 0.035,
    );

    return Container(
      height: 400.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: initialCityPoint,
                initialZoom: 11.8,
                onMapReady: () => _startCityToUserZoom(),
                onTap: (x, y) => setState(() => _selectedPlace = null),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.finda.mobile',
                ),
                MarkerLayer(
                  markers: [
                    // 1 user
                    Marker(
                      point: userPoint,
                      width: 70.w,
                      height: 70.w,
                      child: PulsingLocationMarker(
                        controller: _pulseController,
                      ),
                    ),

                    // 2 services
                    ...widget.suggestions.map((place) {
                      final distKm = _locationRepo.calculateDistanceInKm(
                        widget.latitude,
                        widget.longitude,
                        place.latitude,
                        place.longitude,
                      );
                      final bool isNearby = distKm <= 3.0;
                      final bool isSelected = _selectedPlace == place;

                      return Marker(
                        point: LatLng(place.latitude, place.longitude),
                        width: isSelected ? 48.w : 40.w,
                        height: isSelected ? 54.h : 46.h,
                        alignment: Alignment.topCenter,
                        child: PlaceMapMarker(
                          emoji: place.categoryEmoji,
                          isNearby: isNearby,
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedPlace = place),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),

            //card details
            if (_selectedPlace != null)
              SelectedPlaceMapCard(
                place: _selectedPlace!,
                distanceKm: _locationRepo.calculateDistanceInKm(
                  widget.latitude,
                  widget.longitude,
                  _selectedPlace!.latitude,
                  _selectedPlace!.longitude,
                ),
                onClose: () => setState(() => _selectedPlace = null),
              ),
          ],
        ),
      ),
    );
  }
}