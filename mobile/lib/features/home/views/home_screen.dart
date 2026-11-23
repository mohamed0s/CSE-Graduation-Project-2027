import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/location/cubit/location_cubit.dart';
import 'package:mobile/core/location/cubit/location_state.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/widgets/dialogs/permission_dialog.dart';
import 'package:mobile/core/widgets/loaders/three_dots_loading_overlay.dart';
import 'package:mobile/features/home/models/suggestion_item_model.dart';
import 'package:mobile/features/home/widgets/home_app_bar.dart';
import 'package:mobile/features/home/widgets/location/nearby_map_view.dart';
import 'package:mobile/features/home/widgets/nearby_search_card.dart';
import 'package:mobile/features/home/widgets/promo_banner_slider.dart';
import 'package:mobile/features/home/widgets/quick_categories_section.dart';
import 'package:mobile/features/home/widgets/quick_filter_chips.dart';
import 'package:mobile/features/home/widgets/suggestion_card.dart';
import 'package:mobile/generated/style_atoms.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedFilterChip = 0;
  int _selectedCategory = 0;
  bool _isListView = true;
  bool _useCurrentLocation = false;
  bool _pendingSwitchToMap = false;

  List<SuggestionItemModel> _getSuggestionsNear(
    double? userLat,
    double? userLng,
  ) {
    final double baseLat = userLat ?? 30.5870;
    final double baseLng = userLng ?? 31.5015;

    return [
      SuggestionItemModel(
        title: 'مطعم مذاق الشام',
        subtitle: 'مطعم سوري • شاورما ومشويات',
        location: 'شارع المحطة',
        distance: '0.5',
        categoryLabel: 'مطعم',
        categoryEmoji: '🍔',
        badgeBgColor: AppColors.warningLight,
        badgeTextColor: AppColors.warning,
        latitude: baseLat + 0.0035, // قريب جداً (~450 متر)
        longitude: baseLng + 0.0025,
      ),
      SuggestionItemModel(
        title: 'المهندس محمد ناصر للتكييف والتبريد',
        subtitle: 'تبريد وتكييف',
        location: 'القومية',
        distance: '1.4',
        categoryLabel: 'صيانة',
        categoryEmoji: '🔧',
        badgeBgColor: AppColors.primaryLight,
        badgeTextColor: AppColors.primary,
        latitude: baseLat - 0.0090, // قريب (~1.3 كم)
        longitude: baseLng + 0.0080,
      ),
      SuggestionItemModel(
        title: 'دكتور أحمد حسن',
        subtitle: 'استشاري امراض باطنة وسكر',
        location: 'شارع فاروق',
        distance: '3.2',
        categoryLabel: 'عيادة',
        categoryEmoji: '🏥',
        badgeBgColor: const Color(0xFFEFF6FF),
        badgeTextColor: const Color(0xFF3B82F6),
        badgeBorderColor: const Color(0xFFBFDBFE),
        latitude: baseLat + 0.0220, // متوسط البُعد (~3.2 كم)
        longitude: baseLng - 0.0180,
      ),
      SuggestionItemModel(
        title: 'شقة غرفتين_القومية',
        subtitle: '',
        price: '8,000',
        location: 'القومية',
        distance: '4.6',
        categoryLabel: 'ايجارات',
        categoryEmoji: '🏠',
        badgeBgColor: AppColors.successLight,
        badgeTextColor: AppColors.success,
        latitude: baseLat - 0.0310, // بعيد (~4.6 كم)
        longitude: baseLng - 0.0250,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.home;
        final l = context.t.location;


    return BlocConsumer<LocationCubit, LocationState>(
      listener: (context, locationState) {
        if (locationState is LocationSuccess) {
          setState(() {
            _useCurrentLocation = true;
            if (_pendingSwitchToMap) {
              _isListView = false;
              _pendingSwitchToMap = false;
            }
          });
        } else if (locationState is LocationPermissionDenied) {
          setState(() {
            _useCurrentLocation = false;
            _pendingSwitchToMap = false;
            _isListView = true;
          });
          if (locationState.showDialog) {
            PermissionDialog.show(
              context,
              openAppSettings: locationState.isPermanent,
              onConfirmPressed: () {
                if (locationState.isPermanent) {
                  context.read<LocationCubit>().openAppSettings();
                } else {
                  context.read<LocationCubit>().fetchCurrentLocation(
                    showDialogOnDenied: false,
                  );
                }
              },
            );
          }
        } else if (locationState is LocationError) {
          setState(() {
            _pendingSwitchToMap = false;
          });
        }
      },
      builder: (context, locationState) {
        final location = locationState.location;
        final suggestions = _getSuggestionsNear(
          location?.latitude,
          location?.longitude,
        );
        final String? selectedCity = (location?.city.isNotEmpty ?? false)
            ? location!.city
            : null;
        final String? selectedCountry = (location?.country.isNotEmpty ?? false)
            ? location!.country
            : null;
        final String displayCity = selectedCity ?? l.city_Error ;
        final bool isLoadingLocation = locationState is LocationLoading;

        return Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  HomeAppBar(
                    selectedCity: selectedCity,
                    selectedCountry: selectedCountry,
                    onLocationTap: () {
                      _pendingSwitchToMap = false;
                      context.read<LocationCubit>().fetchCurrentLocation(
                        showDialogOnDenied: false,
                      );
                    },
                    onNotificationTap: () {},
                    onMessagesTap: () {},
                  ),

                  QuickFilterChips(
                    selectedIndex: _selectedFilterChip,
                    onSelect: (index) =>
                        setState(() => _selectedFilterChip = index),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(top: 12.h, bottom: 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PromoBannerSlider(cityName: displayCity),
                          SizedBox(height: 18.h),

                          QuickCategoriesSection(
                            selectedCategoryIndex: _selectedCategory,
                            onCategorySelect: (index) =>
                                setState(() => _selectedCategory = index),
                            onViewAllTap: () {},
                          ),
                          SizedBox(height: 18.h),

                          NearbySearchCard(
                            cityName: displayCity,
                            isListView: _isListView,
                            useCurrentLocation: _useCurrentLocation,
                            onToggleView: (isList) {
                              if (isList) {
                                setState(() {
                                  _isListView = true;
                                  _pendingSwitchToMap = false;
                                });
                              } else {
                                if (location != null) {
                                  setState(() {
                                    _isListView = false;
                                    _useCurrentLocation = true;
                                  });
                                } else {
                                  _pendingSwitchToMap = true;
                                  context
                                      .read<LocationCubit>()
                                      .fetchCurrentLocation(
                                        showDialogOnDenied: true,
                                      );
                                }
                              }
                            },
                            onLocationCheckChanged: (val) {
                              if (val == true) {
                                _pendingSwitchToMap = false;
                                context
                                    .read<LocationCubit>()
                                    .fetchCurrentLocation(
                                      showDialogOnDenied: true,
                                    );
                              } else {
                                setState(() {
                                  _useCurrentLocation = false;
                                  _isListView = true;
                                });
                                context
                                    .read<LocationCubit>()
                                    .clearLocationSelection();
                              }
                            },
                            onSearchChanged: (query) {},
                          ),
                          SizedBox(height: 20.h),

                          if (!_isListView && location != null)
                            NearbyMapView(
                              latitude: location.latitude,
                              longitude: location.longitude,
                              suggestions: suggestions,
                            )
                          else ...[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Row(
                                children: [
                                  Text('📍', style: TextStyle(fontSize: 16.sp)),
                                  SizedBox(width: 6.w),
                                  Text(
                                    t.nearby_suggestions,
                                    style: context.bold14TextMain,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8.h),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: suggestions.length,
                              itemBuilder: (context, index) {
                                return SuggestionCard(
                                  item: suggestions[index],
                                  onTap: () {},
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (isLoadingLocation) const ThreeDotsLoadingOverlay(),
          ],
        );
      },
    );
  }
}
