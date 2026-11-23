class HomeState {
  final int selectedFilterChip;
  final int selectedCategory;
  final bool isListView;
  final bool useCurrentLocation;
  final bool pendingSwitchToMap;
  final String searchQuery;

  const HomeState({
    this.selectedFilterChip = 0,
    this.selectedCategory = 0,
    this.isListView = true,
    this.useCurrentLocation = false,
    this.pendingSwitchToMap = false,
    this.searchQuery = '',
  });

  HomeState copyWith({
    int? selectedFilterChip,
    int? selectedCategory,
    bool? isListView,
    bool? useCurrentLocation,
    bool? pendingSwitchToMap,
    String? searchQuery,
  }) {
    return HomeState(
      selectedFilterChip: selectedFilterChip ?? this.selectedFilterChip,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isListView: isListView ?? this.isListView,
      useCurrentLocation: useCurrentLocation ?? this.useCurrentLocation,
      pendingSwitchToMap: pendingSwitchToMap ?? this.pendingSwitchToMap,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}