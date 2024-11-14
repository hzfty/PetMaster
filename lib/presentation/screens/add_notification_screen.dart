import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:petmaster_app/core/theme/app_colors.dart';
import 'package:petmaster_app/core/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddNotificationScreen extends StatefulWidget {
  final String petId;

  const AddNotificationScreen({Key? key, required this.petId})
      : super(key: key);

  @override
  _AddNotificationScreenState createState() => _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notificationNameController = TextEditingController();
  final _startDateController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String _selectedPeriod = 'Месяц'; // Значение по умолчанию
  bool _isCustomPeriod = false;

  // Переменные для кастомного периода
  final _customPeriodValueController = TextEditingController();
  String _customPeriodUnit = 'День'; // Значение по умолчанию

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru_RU', null);
  }

  @override
  void dispose() {
    _notificationNameController.dispose();
    _startDateController.dispose();
    _customPeriodValueController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDateTime() async {
    // Выбор даты
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('ru', 'RU'), // Устанавливаем локаль
    );

    if (date != null) {
      // Выбор времени
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: Localizations.override(
              context: context,
              locale: const Locale('ru', 'RU'), // Устанавливаем локаль здесь
              child: Theme(
                data: Theme.of(context).copyWith(
                  timePickerTheme: TimePickerThemeData(
                    hourMinuteTextStyle: TextStyle(
                        fontSize: 48), // Уменьшите значение по необходимости
                    dayPeriodTextStyle: TextStyle(fontSize: 16),
                    helpTextStyle: TextStyle(fontSize: 16),
                  ),
                ),
                child: child!,
              ),
            ),
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
          // Форматируем дату и время
          final DateTime combinedDateTime = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          );
          _startDateController.text =
              DateFormat('dd.MM.yyyy HH:mm', 'ru_RU').format(combinedDateTime);
        });
      }
    }
  }

  void _saveNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      String notificationTitle = _notificationNameController.text;

      // Используем выбранную дату и время
      final DateTime startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Генерируем уникальный ID для уведомления
      int notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      print('Планируем уведомление с ID $notificationId на $startDateTime');

      // Планируем уведомление в зависимости от выбранного периода
      if (_isCustomPeriod) {
        // Кастомный период
        int customValue = int.parse(_customPeriodValueController.text);
        String customUnit = _customPeriodUnit;

        Duration repeatInterval;

        switch (customUnit) {
          case 'День':
            repeatInterval = Duration(days: customValue);
            break;
          case 'Неделю':
            repeatInterval = Duration(days: customValue * 7);
            break;
          case 'Месяц':
            repeatInterval = Duration(days: customValue * 30);
            break;
          case 'Год':
            repeatInterval = Duration(days: customValue * 365);
            break;
          default:
            repeatInterval = Duration(days: customValue);
        }

        // Планируем повторяющееся уведомление
        await NotificationService().scheduleRepeatingNotification(
          notificationId,
          notificationTitle,
          'Напоминание: $notificationTitle',
          startDateTime,
          repeatInterval,
        );
      } else {
        // Стандартные периоды: Год, Месяц, Неделя
        Duration repeatInterval;

        switch (_selectedPeriod) {
          case 'Год':
            repeatInterval = Duration(days: 365);
            break;
          case 'Месяц':
            repeatInterval = Duration(days: 30);
            break;
          case 'Неделя':
            repeatInterval = Duration(days: 7);
            break;
          default:
            repeatInterval = Duration(days: 30);
        }

        // Планируем повторяющееся уведомление
        await NotificationService().scheduleRepeatingNotification(
          notificationId,
          notificationTitle,
          'Напоминание: $notificationTitle',
          startDateTime,
          repeatInterval,
        );
      }

      print('Уведомление запланировано');

      // Сохраняем данные уведомления в Firestore
      String userId = FirebaseAuth.instance.currentUser!.uid;

      Map<String, dynamic> notificationData = {
        'id': notificationId,
        'title': notificationTitle,
        'body': 'Напоминание: $notificationTitle',
        'scheduledDate': startDateTime,
        'period': _isCustomPeriod ? 'Кастомный' : _selectedPeriod,
        'customValue': _isCustomPeriod
            ? int.parse(_customPeriodValueController.text)
            : null,
        'customUnit': _isCustomPeriod ? _customPeriodUnit : null,
        'petId': widget.petId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId.toString())
          .set(notificationData);

      // Переходим обратно на экран деталей питомца
      if (mounted) {
        context.goNamed('petDetail', pathParameters: {'petId': widget.petId});
      }
    } catch (e) {
      print('Ошибка при планировании уведомления: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при планировании уведомления: $e')),
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
      // Настройка AppBar
      appBar: AppBar(
        title: Text(
          'Добавить уведомление',
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
                key: _formKey, // Добавляем форму для валидации
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Поле "Название уведомления"
                    TextFormField(
                      controller: _notificationNameController,
                      decoration:
                          InputDecoration(labelText: 'Название уведомления'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите название уведомления';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // Поле "Дата начала"
                    GestureDetector(
                      onTap: _pickStartDateTime,
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _startDateController,
                          decoration: InputDecoration(
                            labelText: 'Дата и время начала',
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color:
                                  AppColors.gray03, // Устанавливаем цвет иконки
                            ),
                          ),
                          validator: (value) {
                            if (_selectedDate == null ||
                                _selectedTime == null) {
                              return 'Пожалуйста, выберите дату и время начала';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    // Заголовок "Период"
                    Text(
                      'Период',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 16),
                    // Segmented Control для выбора периода
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: ['Год', 'Месяц', 'Неделя', 'Настроить']
                            .map((period) => Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedPeriod = period;
                                        _isCustomPeriod = period == 'Настроить';
                                      });
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12.0),
                                      decoration: BoxDecoration(
                                        color: _selectedPeriod == period
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          period,
                                          style: TextStyle(
                                            color: _selectedPeriod == period
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    if (_isCustomPeriod) ...[
                      SizedBox(height: 24),
                      Text(
                        'Повторять каждые:',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          // Поле "Количество"
                          Expanded(
                            child: TextFormField(
                              controller: _customPeriodValueController,
                              decoration:
                                  InputDecoration(labelText: 'Количество'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (_isCustomPeriod) {
                                  if (value == null || value.isEmpty) {
                                    return 'Введите количество';
                                  }
                                  if (int.tryParse(value) == null ||
                                      int.parse(value) <= 0) {
                                    return 'Введите корректное число';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          // Выпадающий список
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _customPeriodUnit,
                              decoration:
                                  InputDecoration(labelText: 'Единица времени'),
                              items: ['День', 'Неделю', 'Месяц', 'Год']
                                  .map((unit) => DropdownMenuItem(
                                        value: unit,
                                        child: Text(unit),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _customPeriodUnit = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 32),
                    // Кнопка "Сохранить"
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveNotification,
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
