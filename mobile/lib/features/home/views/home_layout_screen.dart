import 'package:flutter/material.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/utils/extensions.dart';
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
      Center(
        child: Text(
          t.home,
          style: context.bold20.copyWith(color: context.colorScheme.primary),
        ),
      ),
      Center(
        child: Text(
          t.services,
          style: context.bold20.copyWith(color: context.colorScheme.primary),
        ),
      ),
      Center(
        child: Text(
          t.finda_ai,
          style: context.bold20.copyWith(color: context.colorScheme.primary),
        ),
      ),
      Center(
        child: Text(
          t.orders,
          style: context.bold20.copyWith(color: context.colorScheme.primary),
        ),
      ),
      Center(
        child: Text(
          t.profile,
          style: context.bold20.copyWith(color: context.colorScheme.primary),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(index: _currentIndex, children: screens),
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
