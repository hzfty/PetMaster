// lib/presentation/screens/welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petmaster_app/presentation/blocs/auth_bloc.dart';
import 'package:petmaster_app/presentation/blocs/auth_event.dart';
import 'package:petmaster_app/core/routing/app_router.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar и body остаются без изменений
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Добро пожаловать в PetMaster',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Image.asset(
                'assets/images/PetMasterLogo.png',
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(Guest());
                  context.go(AppRoutes.home);
                },
                child: Text('Начать без входа'),
              ),
              SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  context.push(AppRoutes.register); // Изменено на push
                },
                child: Text('Создать аккаунт'),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.push(AppRoutes.login); // Изменено на push
                },
                child: Text('У меня уже есть аккаунт'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
