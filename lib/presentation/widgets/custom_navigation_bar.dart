import 'package:flutter/material.dart';
import 'package:petmaster_app/core/theme/app_colors.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  CustomNavigationBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavBarItem(
            icon: Icons.pets,
            label: 'Питомцы',
            index: 0,
            context: context,
          ),
          _buildNavBarItem(
            icon: Icons.info,
            label: 'Факты',
            index: 1,
            context: context,
          ),
          _buildNavBarItem(
            icon: Icons.settings,
            label: 'Настройки',
            index: 2,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildNavBarItem({
    required IconData icon,
    required String label,
    required int index,
    required BuildContext context,
  }) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        onTap(index);
      },
      child: Container(
        width: (MediaQuery.of(context).size.width / 3) - 16,
        height: 80,
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: isSelected ? 64 : 0,
                width: double.infinity,
                decoration: isSelected
                    ? BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(16.0),
                      )
                    : BoxDecoration(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: AppColors.white,
                      size: 28,
                    ),
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (!isSelected)
              Icon(
                icon,
                color: AppColors.white,
                size: 28,
              )
          ],
        ),
      ),
    );
  }
}
