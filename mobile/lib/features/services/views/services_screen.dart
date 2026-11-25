import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/location/cubit/location_cubit.dart';
import 'package:mobile/core/location/cubit/location_state.dart';
import 'package:mobile/core/theme/cubit/theme_cubit.dart';
import 'package:mobile/core/utils/extensions.dart';
import 'package:mobile/core/widgets/loaders/three_dots_loading_overlay.dart';
import 'package:mobile/features/home/widgets/home_app_bar.dart';
import 'package:mobile/features/services/models/category_model.dart';
import 'package:mobile/features/services/widgets/emergency_guide_card.dart';
import 'package:mobile/features/services/widgets/service_category_card.dart';
import 'package:mobile/features/services/widgets/services_search_bar.dart';
import 'package:mobile/generated/style_atoms.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final tServices = context.t.services;
    final l = context.t.location;

    return Scaffold(
      body: BlocBuilder<LocationCubit, LocationState>(
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
          final categories = CategoryModel.getCategories(
            context,
            city: selectedCity ?? l.city_Error,
          );
          return SafeArea(
            child: Stack(
              children: [Column(
                children: [
                HomeAppBar(
                  selectedCity: selectedCity,
                  selectedCountry: selectedCountry,
                  onLocationTap: () {
                    context.read<LocationCubit>().fetchCurrentLocation(
                      showDialogOnDenied: false,
                      forceRefresh: true,
                    );
                  },
                  onNotificationTap: () {context.read<ThemeCubit>().toggleTheme();},
                  onMessagesTap: () {},
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            tServices.explore_categories,
                            style: context.bold16.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: categories.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 1.08,
                          ),
                          itemBuilder: (context, index) {
                            final item = categories[index];
                            return ServiceCategoryCard(
                              category: item,
                              onTap: () {},
                            );
                          },
                        ),
                        SizedBox(height: 16.h),
                        EmergencyGuideCard(onTap: () {}, city: displayCity),
                        SizedBox(height: 12.h),
                        ServicesSearchBar(
                          onFilterTap: () {},
                          onChanged: (value) {},
                        ),
                          SizedBox(height:35.h,),
                      ],
                    ),
                  ),
                ),
                if (isLoadingLocation) ThreeDotsLoadingOverlay(),
               
              ],
            ),
              ],
          ),
          );
        },
      ),
    );
  }
}
