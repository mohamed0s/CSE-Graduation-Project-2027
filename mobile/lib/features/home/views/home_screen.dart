import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/location/cubit/location_cubit.dart';
import 'package:mobile/core/location/cubit/location_state.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/theme/cubit/theme_cubit.dart';
import 'package:mobile/core/widgets/dialogs/permission_dialog.dart';
import 'package:mobile/core/widgets/loaders/three_dots_loading_overlay.dart';
import 'package:mobile/features/home/cubit/home_cubit.dart';
import 'package:mobile/features/home/cubit/home_state.dart';
import 'package:mobile/features/home/repo/home_mock_data.dart';
import 'package:mobile/features/home/widgets/home_app_bar.dart';
import 'package:mobile/features/home/widgets/location/nearby_map_view.dart';
import 'package:mobile/features/home/widgets/nearby_search_card.dart';
import 'package:mobile/features/home/widgets/promo_banner_slider.dart';
import 'package:mobile/features/home/widgets/quick_categories_section.dart';
import 'package:mobile/features/home/widgets/suggestion_list_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => HomeCubit(), child: const _HomeView());
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  void _handleLocationListener(BuildContext context, LocationState state) {
    final homeCubit = context.read<HomeCubit>();

    if (state is LocationSuccess) {
      homeCubit.onLocationSuccess();
    } else if (state is LocationPermissionDenied) {
      homeCubit.onLocationDenied();
      if (state.showDialog) {
        PermissionDialog.show(
          context,
          openAppSettings: state.isPermanent,
          onConfirmPressed: () {
            final locationCubit = context.read<LocationCubit>();
            if (state.isPermanent) {
              locationCubit.openAppSettings();
            } else {
              locationCubit.fetchCurrentLocation(showDialogOnDenied: false);
            }
          },
        );
      }
    } else if (state is LocationError) {
      homeCubit.setPendingSwitchToMap(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.home;
    final l = context.t.location;

    return BlocListener<LocationCubit, LocationState>(
      listener: _handleLocationListener,
      child: BlocBuilder<LocationCubit, LocationState>(
        builder: (context, locationState) {
          final location = locationState.location;
          final selectedCity = (location?.city.isNotEmpty ?? false)
              ? location!.city
              : null;
          final selectedCountry = (location?.country.isNotEmpty ?? false)
              ? location!.country
              : null;
          final displayCity = selectedCity ?? l.city_Error;
          final isLoadingLocation = locationState is LocationLoading;

          final allSuggestions = HomeMockData.getSuggestionsNear(
            location?.latitude,
            location?.longitude,
          );

          return BlocBuilder<HomeCubit, HomeState>(
            builder: (context, homeState) {
              final homeCubit = context.read<HomeCubit>();
              final filteredSuggestions = homeCubit.filterSuggestions(
                allSuggestions,
              );

              return Stack(
                children: [
                  SafeArea(
                    child: Column(
                      children: [
                        HomeAppBar(
                          selectedCity: selectedCity,
                          selectedCountry: selectedCountry,
                          onLocationTap: () {
                            homeCubit.setPendingSwitchToMap(false);
                            context.read<LocationCubit>().fetchCurrentLocation(
                              showDialogOnDenied: false,
                            );
                          },
                          onNotificationTap: () { context.read<ThemeCubit>().toggleTheme();},
                          onMessagesTap: () {},
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
                                  selectedCategoryIndex:
                                      homeState.selectedCategory,
                                  onCategorySelect: homeCubit.selectCategory,
                                  
                                ),
                                SizedBox(height: 18.h),
                                KeyedSubtree(
                                  child: NearbySearchCard(
                                    cityName: displayCity,
                                    isListView: homeState.isListView,
                                    useCurrentLocation:
                                        homeState.useCurrentLocation,
                                    onToggleView: (isList) =>
                                        homeCubit.toggleView(
                                          isList: isList,
                                          hasLocation: location != null,
                                          onRequestLocation: () => context
                                              .read<LocationCubit>()
                                              .fetchCurrentLocation(
                                                showDialogOnDenied: true,
                                              ),
                                        ),
                                    onLocationCheckChanged: (val) =>
                                        homeCubit.toggleUseCurrentLocation(
                                          value: val,
                                          onRequestLocation: () => context
                                              .read<LocationCubit>()
                                              .fetchCurrentLocation(
                                                showDialogOnDenied: true,
                                              ),
                                          onClearLocation: () => context
                                              .read<LocationCubit>()
                                              .clearLocationSelection(),
                                        ),
                                    onSearchChanged:
                                        homeCubit.updateSearchQuery,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                if (!homeState.isListView && location != null)
                                  NearbyMapView(
                                    latitude: location.latitude,
                                    longitude: location.longitude,
                                    suggestions: filteredSuggestions,
                                  )
                                else
                                  SuggestionsListSection(
                                    title: t.nearby_suggestions,
                                    suggestions: filteredSuggestions,
                                  ),
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
        },
      ),
    );
  }
}
