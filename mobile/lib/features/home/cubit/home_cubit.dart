import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/home/models/suggestion_item_model.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  static const Map<int, String> _categoryMap = {
    1: 'مطعم',
    2: 'صيانة',
    3: 'عيادة',
    4: 'ايجارات',
  };

  void selectFilterChip(int index) =>
      emit(state.copyWith(selectedFilterChip: index));

  void selectCategory(int index) =>
      emit(state.copyWith(selectedCategory: index));

  void updateSearchQuery(String query) =>
      emit(state.copyWith(searchQuery: query.trim().toLowerCase()));

  void setListView(bool isList, {bool pendingMap = false}) {
    emit(state.copyWith(
      isListView: isList,
      pendingSwitchToMap: pendingMap,
      useCurrentLocation: isList ? state.useCurrentLocation : true,
    ));
  }

  void setPendingSwitchToMap(bool pending) =>
      emit(state.copyWith(pendingSwitchToMap: pending));

  void onLocationSuccess() {
    emit(state.copyWith(
      useCurrentLocation: true,
      isListView: state.pendingSwitchToMap ? false : state.isListView,
      pendingSwitchToMap: false,
    ));
  }

  void onLocationDenied() {
    emit(state.copyWith(
      useCurrentLocation: false,
      pendingSwitchToMap: false,
      isListView: true,
    ));
  }

  void clearLocation() {
    emit(state.copyWith(
      useCurrentLocation: false,
      isListView: true,
    ));
  }

  List<SuggestionItemModel> filterSuggestions(
    List<SuggestionItemModel> allSuggestions,
  ) {
    final targetCategory =
        state.selectedCategory == 0 ? null : _categoryMap[state.selectedCategory];

    return allSuggestions.where((item) {
      final matchesCategory =
          targetCategory == null || item.categoryLabel == targetCategory;
      final matchesSearch = state.searchQuery.isEmpty ||
          item.title.toLowerCase().contains(state.searchQuery) ||
          item.subtitle.toLowerCase().contains(state.searchQuery);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  // بدل ما الـ UI يقرر يعمل إيه، الـ Cubit هو اللي يقرر
void toggleView({
  required bool isList,
  required bool hasLocation,
  required VoidCallback onRequestLocation,
}) {
  if (isList) {
    emit(state.copyWith(isListView: true, pendingSwitchToMap: false));
    return;
  }

  if (hasLocation) {
    emit(state.copyWith(isListView: false, useCurrentLocation: true));
  } else {
    emit(state.copyWith(pendingSwitchToMap: true));
    onRequestLocation();
  }
}

void toggleUseCurrentLocation({
  required bool? value,
  required VoidCallback onRequestLocation,
  required VoidCallback onClearLocation,
}) {
  if (value == true) {
    emit(state.copyWith(pendingSwitchToMap: false));
    onRequestLocation();
  } else {
    emit(state.copyWith(useCurrentLocation: false, isListView: true));
    onClearLocation();
  }
}
}