import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../competitions/screens/competitions_screen.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../matches/screens/matches_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'home_screen.dart';

/// Bottom-nav shell. The gradient pill nav bar is a direct evolution of
/// v1's `CustomBottomNavigationBar` (same gradient, same rounded
/// container), just restyled for the 2.0 look and IndexedStack instead
/// of manual screen swapping.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    MatchesScreen(),
    CompetitionsScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  static const _items = [
    (icon: Icons.home_rounded, label: "Home"),
    (icon: Icons.sports_soccer, label: "Matches"),
    (icon: Icons.emoji_events_outlined, label: "Leagues"),
    (icon: Icons.star_rounded, label: "Favorites"),
    (icon: Icons.person_rounded, label: "Profile"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: AppColors.brandGradient,
          ),
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = i == _index;
              final item = _items[i];
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: () => setState(() => _index = i),
                  child: AnimatedContainer(
                    duration: AppDurations.fast,
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: selected ? Colors.white.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: selected ? Colors.white : AppColors.brandNavyDark,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : AppColors.brandNavyDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
