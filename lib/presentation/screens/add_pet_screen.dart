// lib/presentation/screens/add_pet_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:petmaster_app/data/models/pet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:petmaster_app/core/routing/app_router.dart';
import 'package:dotted_border/dotted_border.dart'; // Импортируем пакет для пунктирной границы

class AddPetScreen extends StatefulWidget {
  @override
  _AddPetScreenState createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Переменные для хранения данных
  String _name = '';
  DateTime? _birthDate;
  String _gender = 'Самец';
  String _breed = '';
  String _type = '';
  String? _photoUrl;
  bool _isSterilized = false;
  bool _isChipped = false;
  String? _chipNumber;
  String? _distinctiveMarks;
  String? _allergies;
  String? _weight;

  // Контроллеры для текстовых полей
  final _formKeyStep1 = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _chipNumberController = TextEditingController();
  final _distinctiveMarksController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _chipNumberController.dispose();
    _distinctiveMarksController.dispose();
    _allergiesController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0) {
      if (_formKeyStep1.currentState!.validate()) {
        _formKeyStep1.currentState!.save();
        _pageController.nextPage(
            duration: Duration(milliseconds: 300), curve: Curves.ease);
      }
    } else if (_currentPage == 1) {
      if (_type.isNotEmpty) {
        _pageController.nextPage(
            duration: Duration(milliseconds: 300), curve: Curves.ease);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Пожалуйста, выберите тип питомца')),
        );
      }
    } else if (_currentPage == 2) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void _skipPage() {
    _pageController.nextPage(
        duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  void _savePet() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final pet = Pet(
      name: _nameController.text.trim(),
      birthDate: _birthDate ?? DateTime.now(),
      gender: _gender,
      breed: _breedController.text.trim(),
      type: _type,
      photoUrl: _photoUrl,
      isSterilized: _isSterilized,
      isChipped: _isChipped,
      chipNumber: _isChipped ? _chipNumberController.text.trim() : null,
      distinctiveMarks: _distinctiveMarksController.text.trim(),
      allergies: _allergiesController.text.trim(),
      weight: double.tryParse(_weightController.text.trim()),
    );

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('pets')
          .add(pet.toMap());

      // Возврат на экран списка питомцев
      if (mounted) {
        context.go(AppRoutes.petList);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении питомца: $e')),
      );
    }
  }

  // Функция для выбора и загрузки изображения
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Убираем AppBar
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(), // Запрещаем скроллинг
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: [
            _buildStep1(),
            _buildStep2(),
            _buildStep3(),
            _buildStep4(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKeyStep1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBackButton(),
            Center(
              child:
                  Image.asset('assets/images/PetMasterLogo.png', height: 150),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Это займет полминуты!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
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
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _birthDate = date;
                  });
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Дата рождения',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(
                    text: _birthDate == null
                        ? ''
                        : '${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}',
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
            Text('Пол:', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text('Самец'),
                    selected: _gender == 'Самец',
                    onSelected: (selected) {
                      setState(() {
                        _gender = 'Самец';
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: Text('Самка'),
                    selected: _gender == 'Самка',
                    onSelected: (selected) {
                      setState(() {
                        _gender = 'Самка';
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _breedController,
              decoration: InputDecoration(labelText: 'Порода'),
            ),
            Spacer(),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    final List<Map<String, dynamic>> types = [
      {'type': 'Собака', 'image': 'assets/images/dog.png'},
      {'type': 'Кошка', 'image': 'assets/images/cat.png'},
      {'type': 'Птица', 'image': 'assets/images/bird.png'},
      {'type': 'Грызун', 'image': 'assets/images/rodent.png'},
    ];

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildBackButton(),
          SizedBox(height: 16),
          Text(
            'Выберите вашего питомца',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: types.map((item) {
                final String typeName = item['type'] as String;
                final String imagePath = item['image'] as String;
                final isSelected = _type == typeName;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _type = typeName;
                    });
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: isSelected
                          ? BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2)
                          : BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.asset(imagePath, fit: BoxFit.contain),
                        ),
                        SizedBox(height: 8),
                        Text(typeName),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildBackButton(),
          SizedBox(height: 16),
          Text(
            'Вы можете загрузить фото вашего питомца',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
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
                          Text('Загрузите изображение своего питомца'),
                        ],
                      )
                    : Image.network(_photoUrl!, fit: BoxFit.cover),
              ),
            ),
          ),
          Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _skipPage,
                  child: Text('Пропустить'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text('Далее'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildBackButton(),
          SizedBox(height: 16),
          Text(
            'Вы можете также настроить данные мед карты',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text('Стерилизован:')),
              Text(':'),
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
          Row(
            children: [
              Expanded(child: Text('Чипирован:')),
              Text(':'),
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
          if (_isChipped)
            TextFormField(
              controller: _chipNumberController,
              decoration: InputDecoration(labelText: 'Номер микросхемы'),
            ),
          SizedBox(height: 16),
          TextFormField(
            controller: _distinctiveMarksController,
            decoration: InputDecoration(labelText: 'Отличительные признаки'),
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
          Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      _savePet, // Пропуск сохранит питомца без этих данных
                  child: Text('Пропустить'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _savePet,
                  child: Text('Сохранить'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          if (_currentPage > 0) {
            _pageController.previousPage(
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildNextButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ElevatedButton(
        onPressed: _nextPage,
        child: Text('Далее'),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50),
        ),
      ),
    );
  }
}
