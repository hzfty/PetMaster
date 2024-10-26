import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:petmaster_app/presentation/blocs/auth_bloc.dart';
import 'package:petmaster_app/presentation/blocs/auth_event.dart';
import 'firebase_options.dart';
import 'core/routing/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AuthBloc(firebaseAuth: FirebaseAuth.instance)..add(AppStarted()),
      child: MaterialApp.router(
        routerConfig: router,
        title: 'PetMaster',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
