import 'package:flutter/material.dart';
import 'package:petmaster_app/core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Настройки',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: AppColors.white),
          ),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: Text(
          'Здесь будут настройки',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
