// lib/presentation/screens/pet_edit_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petmaster_app/data/models/pet.dart';
import 'package:go_router/go_router.dart';
import 'package:petmaster_app/core/routing/app_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:petmaster_app/core/theme/app_colors.dart'; // Добавил импорт для AppColors

class PetEditScreen extends StatefulWidget {
  final String petId;

  const PetEditScreen({Key? key, required this.petId}) : super(key: key);

  @override
  _PetEditScreenState createState() => _PetEditScreenState();
}

class _PetEditScreenState extends State<PetEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _chipNumberController = TextEditingController();
  final _distinctiveMarksController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _weightController = TextEditingController();

  String _gender = 'Самец'; // Значение по умолчанию
  DateTime? _birthDate;
  String? _photoUrl;
  bool _isSaving = false; // Для отображения прогресс-бара

  // Новые переменные
  bool _isSterilized = false;
  bool _isChipped = false;

  @override
  void initState() {
    super.initState();
    _loadPetData();
  }

  Future<void> _loadPetData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(widget.petId)
          .get();

      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Питомец не найден')),
        );
        context.pop();
        return;
      }

      final pet = Pet.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      setState(() {
        _nameController.text = pet.name;
        _breedController.text = pet.breed;
        _gender = pet.gender;
        _birthDate = pet.birthDate;
        _photoUrl = pet.photoUrl;
        _birthDateController.text = _birthDate != null
            ? '${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}'
            : '';
        // Новые поля
        _isSterilized = pet.isSterilized;
        _isChipped = pet.isChipped;
        _chipNumberController.text = pet.chipNumber ?? '';
        _distinctiveMarksController.text = pet.distinctiveMarks ?? '';
        _allergiesController.text = pet.allergies ?? '';
        _weightController.text =
            pet.weight != null ? pet.weight.toString() : '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки данных питомца: $e')),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _birthDateController.dispose();
    _chipNumberController.dispose();
    _distinctiveMarksController.dispose();
    _allergiesController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

      if (pickedFile != null) {
        // Загрузить изображение в Firebase Storage
        final storageRef = FirebaseStorage.instance.ref();
        final imagesRef = storageRef
            .child('pet_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = imagesRef.putFile(File(pickedFile.path));

        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          _photoUrl = downloadUrl;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при загрузке изображения: $e')),
      );
    }
  }

  void _savePet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(widget.petId)
          .update({
        'name': _nameController.text.trim(),
        'breed': _breedController.text.trim(),
        'gender': _gender,
        'birthDate': _birthDate?.toIso8601String(),
        'photoUrl': _photoUrl,
        'isSterilized': _isSterilized,
        'isChipped': _isChipped,
        'chipNumber': _isChipped ? _chipNumberController.text.trim() : null,
        'distinctiveMarks': _distinctiveMarksController.text.trim(),
        'allergies': _allergiesController.text.trim(),
        'weight': double.tryParse(_weightController.text.trim()),
      });

      // Обновляем данные на предыдущем экране
      context.goNamed('petDetail', pathParameters: {'petId': widget.petId});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении питомца: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Редактировать питомца',
          style: TextStyle(
            fontSize: 20.0, // Увеличиваем размер шрифта заголовка
          ),
        ),
        centerTitle: false, // Выравниваем заголовок по левому краю
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Возвращаемся назад без сохранения
          },
        ),
      ),
      body: _isSaving
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Раздел "Основное"
                    Text(
                      'Основное',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Имя питомца'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите имя питомца';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _birthDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _birthDate = date;
                            _birthDateController.text =
                                '${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}';
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _birthDateController,
                          decoration: InputDecoration(
                            labelText: 'Дата рождения',
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color:
                                  AppColors.gray03, // Устанавливаем цвет иконки
                            ),
                          ),
                          validator: (value) {
                            if (_birthDate == null) {
                              return 'Пожалуйста, выберите дату рождения';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Пол:', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    // Сегментированный контрол для выбора пола
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _gender = 'Самец';
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: _gender == 'Самец'
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16.0),
                                    bottomLeft: Radius.circular(16.0),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Самец',
                                    style: TextStyle(
                                      color: _gender == 'Самец'
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _gender = 'Самка';
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: _gender == 'Самка'
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(16.0),
                                    bottomRight: Radius.circular(16.0),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Самка',
                                    style: TextStyle(
                                      color: _gender == 'Самка'
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _breedController,
                      decoration: InputDecoration(labelText: 'Порода'),
                    ),
                    SizedBox(height: 32),
                    // Раздел "Фото"
                    Text(
                      'Фото',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickImage,
                      child: DottedBorder(
                        color: Colors.grey,
                        strokeWidth: 2,
                        dashPattern: [5, 5],
                        borderType: BorderType.RRect,
                        radius: Radius.circular(12),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: _photoUrl == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cloud_upload,
                                        size: 50, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text(
                                        'Загрузите изображение своего питомца'),
                                  ],
                                )
                              : Image.network(_photoUrl!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    // Раздел "Мед карта"
                    Text(
                      'Мед карта',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 16),
                    // Параметр "Стерилизован"
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Стерилизован',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          ':',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Switch(
                          value: _isSterilized,
                          onChanged: (value) {
                            setState(() {
                              _isSterilized = value;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Параметр "Чипирован"
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Чипирован',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          ':',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Switch(
                          value: _isChipped,
                          onChanged: (value) {
                            setState(() {
                              _isChipped = value;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_isChipped) ...[
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _chipNumberController,
                        decoration:
                            InputDecoration(labelText: 'Номер микросхемы'),
                      ),
                    ],
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _distinctiveMarksController,
                      decoration:
                          InputDecoration(labelText: 'Отличительные признаки'),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _allergiesController,
                      decoration: InputDecoration(labelText: 'Аллергии'),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _weightController,
                      decoration: InputDecoration(labelText: 'Вес'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 32),
                    // Кнопка "Сохранить"
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _savePet,
                        child: Text('Сохранить'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
