import 'package:cheque_manager/cheque_add_page.dart';
import 'package:cheque_manager/management_page.dart';
import 'package:cheque_manager/cheque_view_page.dart';
import 'package:cheque_manager/utils/colors.dart';
import 'package:flutter/material.dart';

class NavigationBar extends StatefulWidget {
  const NavigationBar({super.key});

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ChequeViewPage(),
    AddChequePage(),
    MainMenuPage(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.list_alt, label: "Flow"),
    _NavItem(icon: Icons.add_box_outlined, label: "Add"),
    _NavItem(icon: Icons.insert_chart_outlined_rounded, label: "Analytics"),
  ];

  void _onTapItem(int index) {
    if (index != _selectedIndex) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final isSelected = _selectedIndex == index;
              final item = _navItems[index];

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTapItem(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? mainColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected ? backgroundColor : Colors.white,
                          size: 26,
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: isSelected
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    item.label,
                                    style: TextStyle(
                                      color: backgroundColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
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

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
