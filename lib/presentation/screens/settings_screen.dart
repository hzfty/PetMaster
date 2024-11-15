import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petmaster_app/core/theme/app_colors.dart';
import 'package:petmaster_app/core/routing/app_router.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isCurrentPasswordObscured = true;
  bool _isNewPasswordObscured = true;
  bool _isUsernameChanged = false;
  bool _isNewPasswordChanged = false;

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadUserData();
  }

  void _loadUserData() async {
    if (_currentUser != null) {
      final userId = _currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        setState(() {
          _usernameController.text = data?['username'] ?? '';
          _emailController.text = _currentUser!.email ?? '';
        });
      }
    }
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        context.go(AppRoutes.welcome);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выходе из аккаунта: $e')),
      );
    }
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _currentUser!.uid;

      if (_isUsernameChanged) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'username': _usernameController.text.trim()});
      }

      if (_isNewPasswordChanged) {
        await _reauthenticateUser();
        await _currentUser!.updatePassword(_newPasswordController.text.trim());
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Изменения сохранены')),
      );

      setState(() {
        _isUsernameChanged = false;
        _isNewPasswordChanged = false;
        _currentPasswordController.clear();
        _newPasswordController.clear();
      });
    } on FirebaseAuthException catch (e) {
      String message = 'Произошла ошибка';
      if (e.code == 'weak-password') {
        message = 'Пароль слишком слабый';
      } else if (e.code == 'requires-recent-login') {
        message = 'Пожалуйста, заново войдите в систему и повторите попытку';
      } else if (e.code == 'wrong-password') {
        message = 'Неверный текущий пароль';
      } else {
        message = e.message ?? 'Произошла ошибка';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _reauthenticateUser() async {
    final credential = EmailAuthProvider.credential(
      email: _currentUser!.email!,
      password: _currentPasswordController.text.trim(),
    );
    await _currentUser!.reauthenticateWithCredential(credential);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  String? _validateNewPassword(String? value) {
    if (_isNewPasswordChanged) {
      if (value == null || value.isEmpty) {
        return 'Пожалуйста, введите новый пароль';
      }
      if (!RegExp(r'^(?=.*[A-Za-z]).{6,}$').hasMatch(value)) {
        return 'Пароль должен содержать минимум 6 символов и хотя бы одну букву';
      }
    }
    return null;
  }

  String? _validateCurrentPassword(String? value) {
    if (_isNewPasswordChanged) {
      if (value == null || value.isEmpty) {
        return 'Пожалуйста, введите текущий пароль';
      }
    }
    return null;
  }

  bool get _isSaveButtonEnabled {
    return _isUsernameChanged || _isNewPasswordChanged;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Настройки',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: AppColors.white),
        ),
        centerTitle: false,
      ),
      resizeToAvoidBottomInset: true,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Никнейм',
                            ),
                            onChanged: (value) {
                              setState(() {
                                _isUsernameChanged = true;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Пожалуйста, введите никнейм';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Электронная почта',
                            ),
                            readOnly: true,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _currentPasswordController,
                            obscureText: _isCurrentPasswordObscured,
                            decoration: InputDecoration(
                              labelText: 'Текущий пароль',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isCurrentPasswordObscured
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.gray03,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isCurrentPasswordObscured =
                                        !_isCurrentPasswordObscured;
                                  });
                                },
                              ),
                            ),
                            validator: _validateCurrentPassword,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: _isNewPasswordObscured,
                            decoration: InputDecoration(
                              labelText: 'Новый пароль',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isNewPasswordObscured
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.gray03,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isNewPasswordObscured =
                                        !_isNewPasswordObscured;
                                  });
                                },
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _isNewPasswordChanged = value.isNotEmpty;
                              });
                            },
                            validator: _validateNewPassword,
                          ),
                          if (_isNewPasswordChanged)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Пароль должен содержать минимум 6 символов и хотя бы одну букву',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed:
                                _isSaveButtonEnabled ? _saveChanges : null,
                            child: Text('Сохранить'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: Icon(Icons.logout, color: AppColors.primary),
                    label: Text(
                      'Выход',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
