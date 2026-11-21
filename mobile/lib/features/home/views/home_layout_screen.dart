import 'package:flutter/material.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/buttons/custom_bottom_nav_bar.dart';

import 'package:mobile/generated/style_atoms.dart';

class HomeLayoutScreen extends StatefulWidget {
  const HomeLayoutScreen({super.key});

  @override
  State<HomeLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<HomeLayoutScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final t = context.t.nav;

    final List<Widget> screens = [
      Center(child: Text(t.home, style: context.bold20Primary)),     // 0
      Center(child: Text(t.services, style: context.bold20Primary)), // 1
      Center(child: Text(t.finda_ai, style: context.bold20Primary)), // 2
      Center(child: Text(t.orders, style: context.bold20Primary)),   // 3
      Center(child: Text(t.profile, style: context.bold20Primary)),  // 4
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}