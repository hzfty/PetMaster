import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:petmaster_app/core/theme/app_colors.dart';

class FactsScreen extends StatefulWidget {
  @override
  _FactsScreenState createState() => _FactsScreenState();
}

class _FactsScreenState extends State<FactsScreen>
    with SingleTickerProviderStateMixin {
  String _dogFact = '';
  final String _yandexApiKey = 'AQVN2xDDILBH0zh4gf_kDqmzlUYATnIXmtLEKuBs';
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward(); // Инициализируем анимацию
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Факты',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: AppColors.white),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  _dogFact.isEmpty
                      ? 'Нажмите кнопку, чтобы получить факт о питомцах'
                      : _dogFact,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _getDogFact();
                },
                child: Text('Узнать факт о питомцах'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(0, 50),
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getDogFact() async {
    final url = Uri.parse('https://dogapi.dog/api/v2/facts');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(
            utf8.decode(response.bodyBytes)); // Используем правильную кодировку
        String fact =
            data['data'][0]['attributes']['body'] ?? 'Не удалось получить факт';
        await _translateFact(fact);
        _controller.forward(from: 0); // Запускаем анимацию
      } else {
        setState(() {
          _dogFact = 'Ошибка при получении факта';
        });
      }
    } catch (e) {
      setState(() {
        _dogFact = 'Ошибка: ${e.toString()}';
      });
    }
  }

  Future<void> _translateFact(String fact) async {
    final translateUrl = Uri.parse(
        'https://translate.api.cloud.yandex.net/translate/v2/translate');
    try {
      final response = await http.post(
        translateUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Api-Key $_yandexApiKey',
        },
        body: json.encode({
          'targetLanguageCode': 'ru',
          'texts': [fact],
        }),
      );

      if (response.statusCode == 200) {
        final translatedData = json.decode(
            utf8.decode(response.bodyBytes)); // Используем правильную кодировку
        setState(() {
          _dogFact = translatedData['translations'][0]['text'] ??
              'Не удалось перевести факт';
        });
        _controller.forward(
            from: 0); // Запускаем анимацию для переведенного текста
      } else {
        setState(() {
          _dogFact =
              'Ошибка при переводе факта: ${utf8.decode(response.bodyBytes)}';
        });
      }
    } catch (e) {
      setState(() {
        _dogFact = 'Ошибка при переводе: ${e.toString()}';
      });
    }
  }
}

// Note: Added fade animation for the text when a new fact is displayed and updated text style to be bolder. Fixed initialization issue with late animation by triggering forward on initState.
