import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petmaster_app/presentation/blocs/auth_bloc.dart';
import 'package:petmaster_app/presentation/blocs/auth_state.dart';
import 'package:petmaster_app/presentation/screens/login_screen.dart';
import 'package:petmaster_app/presentation/screens/register_screen.dart';
import '../../presentation/screens/welcome_screen.dart';
import '../../presentation/screens/pet_list_screen.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated || authState is GuestState) {
          return PetListScreen();
        } else {
          return WelcomeScreen();
        }
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => PetListScreen(),
    ),
  ],
);
