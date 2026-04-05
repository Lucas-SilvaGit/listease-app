import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationFrame extends StatelessWidget {
  const NavigationFrame({
    super.key,
    required this.title,
    required this.currentLocation,
    required this.child,
    this.actions = const [],
    this.floatingActionButton,
  });

  final String title;
  final String currentLocation;
  final Widget child;
  final List<Widget> actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final destinations = [
      const _NavDestination(label: 'Listas', icon: Icons.grid_view_rounded, location: '/lists'),
      const _NavDestination(label: 'Produtos', icon: Icons.inventory_2_rounded, location: '/products'),
      const _NavDestination(label: 'Perfil', icon: Icons.person_rounded, location: '/profile'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 920;
        final body = Scaffold(
          appBar: AppBar(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            actions: actions,
          ),
          floatingActionButton: floatingActionButton,
          body: SafeArea(
            child: Row(
              children: [
                if (useRail)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 0, 16),
                    child: NavigationRail(
                      selectedIndex: _indexFor(currentLocation, destinations),
                      onDestinationSelected: (index) {
                        context.go(destinations[index].location);
                      },
                      backgroundColor: Colors.white,
                      indicatorColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                      labelType: NavigationRailLabelType.all,
                      leading: const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: _BrandBadge(useRail: true),
                      ),
                      destinations: destinations
                          .map(
                            (item) => NavigationRailDestination(
                              icon: Icon(item.icon),
                              label: Text(item.label),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(useRail ? 16 : 16, 8, 16, 16),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: useRail
              ? null
              : NavigationBar(
                  selectedIndex: _indexFor(currentLocation, destinations),
                  onDestinationSelected: (index) {
                    context.go(destinations[index].location);
                  },
                  destinations: destinations
                      .map(
                        (item) => NavigationDestination(
                          icon: Icon(item.icon),
                          label: item.label,
                        ),
                      )
                      .toList(),
                ),
        );

        return body;
      },
    );
  }

  int _indexFor(String location, List<_NavDestination> destinations) {
    final index = destinations.indexWhere((item) => location.startsWith(item.location));
    return index == -1 ? 0 : index;
  }
}

class _BrandBadge extends StatelessWidget {
  const _BrandBadge({this.useRail = false});

  final bool useRail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, color: Color(0xFF2C7BE5)),
          SizedBox(width: 8),
          Text(
            'ListEase',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.label,
    required this.icon,
    required this.location,
  });

  final String label;
  final IconData icon;
  final String location;
}
