import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petmaster_app/core/theme/app_colors.dart';
import 'package:petmaster_app/data/models/pet.dart';
import 'package:go_router/go_router.dart';
import 'package:petmaster_app/core/routing/app_router.dart';

class PetListScreen extends StatefulWidget {
  @override
  _PetListScreenState createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  int _currentIndex = 0; // Для выбора раздела навигации

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Питомцы',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: AppColors.white), // Заголовок теперь белый
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  _buildAddPetButton(), // Кнопка добавления питомца всегда видна
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomNavigationBar(context),
    );
  }

  Widget _buildBody() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<QuerySnapshot>(
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
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount:
                pets.length + 1, // Увеличиваем на 1 для добавления пространства
            itemBuilder: (context, index) {
              if (index == pets.length) {
                // Добавляем нижнее пространство для кнопки
                return SizedBox(height: 80); // Высота пространства под кнопкой
              } else {
                return Column(
                  children: [
                    _buildPetCard(pets[index]),
                    SizedBox(height: 16),
                  ],
                );
              }
            },
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
    );
  }

  Widget _buildCustomNavigationBar(BuildContext context) {
    return Container(
      height: 80, // Высота навигационного бара
      color: AppColors.primary, // Основной цвет навигационного бара
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
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _onNavItemTapped(index);
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

  void _onNavItemTapped(int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.petList);
        break;
      case 1:
        //context.go(AppRoutes.facts);
        break;
      case 2:
        //context.go(AppRoutes.settings);
        break;
    }
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
      color: AppColors.gray04,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          context.pushNamed('petDetail', pathParameters: {'petId': pet.id});
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16.0),
              ),
              child: pet.photoUrl != null
                  ? Image.network(
                      pet.photoUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      height: 200,
                      color: AppColors.gray03,
                      child: Icon(
                        Icons.pets,
                        size: 100,
                        color: AppColors.gray01,
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.black,
                        ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${_calculateAge(pet.birthDate)} • ${pet.type}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray02,
                        ),
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
    return IntrinsicWidth(
      child: OutlinedButton.icon(
        onPressed: () {
          _navigateToAddPetScreen();
        },
        icon: Icon(
          Icons.add,
          color: AppColors.primary,
        ),
        label: Text(
          'Добавить питомца',
          style: TextStyle(
            color: AppColors.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.elevation, // Белый цвет кнопки
          side: BorderSide(color: AppColors.primary),
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
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
