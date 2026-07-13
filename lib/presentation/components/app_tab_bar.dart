import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class AppTabBar extends StatelessWidget {
  final List<AppTabItem> tabs;
  final String activeTab;
  final ValueChanged<String> onTabChanged;

  const AppTabBar({
    super.key,
    required this.tabs,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.map((tab) => _buildChip(tab)).toList(),
      ),
    );
  }

  Widget _buildChip(AppTabItem tab) {
    final isSelected = activeTab == tab.id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? AppColors.mossGreen : AppColors.stoneBg,
        borderRadius: AppRadius.smBr,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onTabChanged(tab.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tab.icon != null) ...[
                  Icon(tab.icon, size: 16, color: isSelected ? AppColors.white : AppColors.mossGreen),
                  const SizedBox(width: 6),
                ],
                Text(
                  tab.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.white : AppColors.mossGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppTabItem {
  final String id;
  final String label;
  final IconData? icon;

  const AppTabItem({required this.id, required this.label, this.icon});
}
