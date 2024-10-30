import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petmaster_app/core/routing/app_router.dart';
import 'package:petmaster_app/data/models/pet.dart';
import 'package:petmaster_app/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class PetDetailScreen extends StatefulWidget {
  final String petId;

  const PetDetailScreen({Key? key, required this.petId}) : super(key: key);

  @override
  _PetDetailScreenState createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  late Future<Pet> _petFuture;

  @override
  void initState() {
    super.initState();
    _petFuture = _fetchPet();
  }

  Future<Pet> _fetchPet() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('pets')
        .doc(widget.petId)
        .get();

    if (!doc.exists) {
      throw Exception('Pet not found');
    }

    return Pet.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Pet>(
      future: _petFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final pet = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  context.pop();
                },
              ),
              title: Text(
                pet.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Colors.white),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // Функционал редактирования добавим позже
                  },
                ),
              ],
            ),
            body: _buildBody(pet),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text('Ошибка загрузки данных питомца',
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _buildBody(Pet pet) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 16),
          // Фото питомца
          CircleAvatar(
            radius: 100,
            backgroundColor: Colors.grey[300],
            child: pet.photoUrl != null && pet.photoUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      pet.photoUrl!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(Icons.pets, size: 100, color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          // Три блока в ряд
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(child: _buildInfoBlock(_calculateAge(pet.birthDate))),
                SizedBox(width: 8),
                Expanded(child: _buildInfoBlock(pet.type)),
                SizedBox(width: 8),
                Expanded(child: _buildInfoBlock(pet.breed)),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Блок "Мед карта"
          _buildMedCard(pet),
          SizedBox(height: 16),
          // Раздел "Уведомления"
          _buildNotificationsSection(),
          // Кнопка "Удалить питомца"
          SizedBox(height: 16),
          _buildDeletePetButton(),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoBlock(String value) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.gray04,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Center(
        child: Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.w600),
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

  Widget _buildMedCard(Pet pet) {
    List<Widget> badges = [];
    if (pet.isSterilized) {
      badges.add(_buildBadge('Стерилизован'));
    }
    if (pet.isChipped) {
      badges.add(_buildBadge('Чипирован'));
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.gray04,
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Мед карта',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w300),
          ),
          SizedBox(height: 8),
          Text(
            'Вес: ${pet.weight?.toString() ?? '-'} кг',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: badges,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Chip(
      label: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall,
      ),
      backgroundColor: AppColors.gray04,
      shape: StadiumBorder(
        side: BorderSide(
          color: AppColors.gray02,
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Заголовок с "Уведомления" и "Добавить"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Уведомления',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton(
                onPressed: () {
                  // Функционал добавления уведомления будет реализован позже
                },
                child: Text('Добавить'),
              ),
            ],
          ),
          // Список уведомлений (пока заглушка)
          SizedBox(height: 8),
          Text(
            'Уведомления не настроены',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDeletePetButton() {
    return Center(
      child: OutlinedButton.icon(
        onPressed: _deletePet,
        icon: Icon(Icons.close, color: AppColors.primary),
        label: Text(
          'Удалить питомца',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: AppColors.primary),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          minimumSize: Size(150, 40), // Устанавливаем минимальный размер
        ),
      ),
    );
  }

  void _deletePet() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Вы действительно желаете удалить питомца?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Да'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Удаляем питомца из Firestore
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('pets')
            .doc(widget.petId)
            .delete();

        // Возвращаемся на экран списка питомцев
        if (mounted) {
          context.go(AppRoutes.petList);
        }
      }
    }
  }
}
