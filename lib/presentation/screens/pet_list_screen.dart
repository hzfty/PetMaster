import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petmaster_app/presentation/blocs/auth_bloc.dart';
import 'package:petmaster_app/presentation/blocs/auth_event.dart';
import 'package:petmaster_app/presentation/blocs/auth_state.dart';
import 'package:go_router/go_router.dart';

class PetListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go('/');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Питомцы'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequested());
              },
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/PetMasterLogo.png',
                    height: 150,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Добавьте вашего первого питомца!',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.add),
                  label: Text('Добавить питомца'),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.pets),
              label: 'Питомцы',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Календарь',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Сообщения',
            ),
          ],
          onTap: (index) {},
        ),
      ),
    );
  }
}
