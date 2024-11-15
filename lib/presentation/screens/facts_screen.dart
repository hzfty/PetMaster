import 'package:flutter/material.dart';
import 'package:petmaster_app/core/theme/app_colors.dart';

class FactsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Факты',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: AppColors.white),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: Text(
          'Здесь будут интересные факты о животных',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
