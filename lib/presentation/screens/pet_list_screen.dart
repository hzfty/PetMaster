// lib/presentation/screens/pet_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petmaster_app/data/models/pet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:petmaster_app/core/routing/app_router.dart';

class PetListScreen extends StatefulWidget {
  @override
  _PetListScreenState createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  int _currentIndex = 0; // Для BottomNavigationBar

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Питомцы'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('pets')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final pets = snapshot.data!.docs
                .map((doc) =>
                    Pet.fromMap(doc.id, doc.data() as Map<String, dynamic>))
                .toList();

            if (pets.isEmpty) {
              // Отображаем заглушку
              return _buildEmptyState(context);
            }

            // Отображаем список питомцев
            return ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                ...pets.map((pet) => _buildPetCard(pet)).toList(),
                SizedBox(height: 16),
                _buildAddPetButton(),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Ошибка загрузки питомцев'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Питомцы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Факты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
        onTap: (index) {
          // Пока кнопки некликабельны
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/PetMasterLogo.png', height: 200),
              SizedBox(height: 20),
              Text(
                'Добавьте вашего первого питомца!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              _buildAddPetButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          context.pushNamed('petDetail', pathParameters: {'petId': pet.id});
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pet.photoUrl != null
                ? Image.network(
                    pet.photoUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: Icon(Icons.pets, size: 100, color: Colors.grey[600]),
                  ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${_calculateAge(pet.birthDate)}, ${pet.type}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPetButton() {
    return OutlinedButton.icon(
      onPressed: () {
        _navigateToAddPetScreen();
      },
      icon: Icon(Icons.add),
      label: Text('Добавить питомца'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
    );
  }

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    if (months < 0) {
      years--;
      months += 12;
    }
    if (years > 0) {
      return '$years лет';
    } else {
      return '$months месяцев';
    }
  }

  void _navigateToAddPetScreen() {
    context.go(AppRoutes.addPet);
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      context.go(AppRoutes.welcome);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выходе из аккаунта: $e')),
      );
    }
  }
}
