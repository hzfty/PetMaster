import 'package:go_router/go_router.dart';
import 'package:petmaster_app/presentation/screens/add_notification_screen.dart';
import 'package:petmaster_app/presentation/screens/pet_edit_screen.dart';
import 'package:petmaster_app/presentation/screens/welcome_screen.dart';
import 'package:petmaster_app/presentation/screens/register_screen.dart';
import 'package:petmaster_app/presentation/screens/login_screen.dart';
import 'package:petmaster_app/presentation/screens/pet_list_screen.dart';
import 'package:petmaster_app/presentation/screens/add_pet_screen.dart';
import 'package:petmaster_app/presentation/screens/pet_detail_screen.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String register = '/register';
  static const String login = '/login';
  static const String petList = '/pets';
  static const String addPet = '/pets/add';
  static const String petDetail = '/pets/:petId';
  static const String editPet = '/pets/:petId/edit';
  static const String addNotification = '/pets/:petId/notifications/add';
}

final GoRouter router = GoRouter(
  initialLocation: AppRoutes.welcome,
  routes: [
    GoRoute(
      path: AppRoutes.welcome,
      name: 'welcome',
      builder: (context, state) => WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) => RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.petList,
      name: 'petList',
      builder: (context, state) => PetListScreen(),
    ),
    GoRoute(
      path: AppRoutes.addPet,
      name: 'addPet',
      builder: (context, state) => AddPetScreen(),
    ),
    GoRoute(
      path: AppRoutes.petDetail,
      name: 'petDetail',
      builder: (context, state) {
        final petId = state.pathParameters['petId']!;
        return PetDetailScreen(petId: petId);
      },
    ),
    GoRoute(
      path: AppRoutes.editPet,
      name: 'editPet',
      builder: (context, state) {
        final petId = state.pathParameters['petId']!;
        return PetEditScreen(petId: petId);
      },
    ),
    GoRoute(
      path: AppRoutes.addNotification,
      name: 'addNotification',
      builder: (context, state) {
        final petId = state.pathParameters['petId']!;
        return AddNotificationScreen(petId: petId);
      },
    ),
  ],
);
