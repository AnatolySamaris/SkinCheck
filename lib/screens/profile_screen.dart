import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:skin_check/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nicknameController = TextEditingController();
  String? _birthDateError;
  final User _user = User();
  // final List<Result> _results = [];
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nicknameController.text = prefs.getString('nickname') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _phoneController.text = prefs.getString('phone') ?? '';

      _user.nickname = _nicknameController.text;
      _user.email = _emailController.text;
      _user.phone = _phoneController.text;

      _user.gender = Gender.values.firstWhere(
        (e) => e.toString() == prefs.getString('gender'),
        orElse: () => Gender.male,
      );
      final birthDateStr = prefs.getString('birthDate');
      if (birthDateStr != null) {
        _user.birthDate = DateTime.parse(birthDateStr);
      }
    });
  }

  _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final prefs = await SharedPreferences.getInstance();
      if (_user.birthDate != null) {
        await prefs.setString('birthDate', _user.birthDate!.toIso8601String());
        setState(() => _birthDateError = null);
      } else {
        setState(() => _birthDateError = 'Укажите дату рождения!');
        return;
      }
      if (_user.gender != null) {
        await prefs.setString('gender', _user.gender.toString());
      }
      await prefs.setString('nickname', _nicknameController.text);
      await prefs.setString('email', _emailController.text);
      await prefs.setString('phone', _phoneController.text);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Данные сохранены')));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _user.birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _user.birthDate) {
      setState(() {
        _user.birthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: 'Имя профиля',
                border: OutlineInputBorder(),
                counterText: 'От 5 до 25 символов',
              ),
              maxLength: 25,
              onSaved: (value) => _user.nickname = value!,
              onChanged:
                  (value) =>
                      _user.nickname =
                          value, // Обновляем модель в реальном времени
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите имя профиля';
                }
                if (value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                  return 'Запрещены специальные символы';
                }
                if (value.length < 5) {
                  return 'Минимум 5 символов';
                }
                if (value.length > 25) {
                  return 'Максимум 25 символов';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'example@mail.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => _user.email = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Введите корректный email';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Номер телефона',
                hintText: '+7 (XXX) XXX-XX-XX',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
                _PhoneInputFormatter(),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите номер телефона';
                }
                if (value.length < 18) {
                  return 'Номер слишком короткий';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Text('Пол', style: TextStyle(fontSize: 16)),
            Column(
              children:
                  Gender.values.map((gender) {
                    return RadioListTile<Gender>(
                      title: Text(_genderToString(gender)),
                      value: gender,
                      groupValue: _user.gender,
                      onChanged: (Gender? value) {
                        setState(() {
                          _user.gender = value;
                        });
                      },
                    );
                  }).toList(),
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Дата рождения', style: TextStyle(fontSize: 16)),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      errorText: _birthDateError, // Текст ошибки
                      suffixIcon: Icon(Icons.calendar_today),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      _user.birthDate == null
                          ? 'Выберите дату'
                          : _dateFormat.format(_user.birthDate!),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                // if (_birthDateError != null)
                //   Padding(
                //     padding: EdgeInsets.only(top: 4),
                //     child: Text(
                //       _birthDateError!,
                //       style: TextStyle(color: Colors.red, fontSize: 12),
                //     ),
                //   ),
              ],
            ),
            // Text('Дата рождения', style: TextStyle(fontSize: 16)),
            // ListTile(
            //   title: Text(
            //     _user.birthDate == null
            //         ? 'Не указана'
            //         : _dateFormat.format(_user.birthDate!),
            //   ),
            //   trailing: Icon(Icons.calendar_today),
            //   onTap: () => _selectDate(context),

            // ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: _saveUserData,
                child: Text('Сохранить профиль'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _genderToString(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Мужской';
      case Gender.female:
        return 'Женский';
    }
  }
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final buffer = StringBuffer();
    buffer.write('+7 ');

    if (text.length > 1) {
      buffer.write('(');
      buffer.write(text.substring(1, text.length > 4 ? 4 : text.length));
    }

    if (text.length > 4) {
      buffer.write(') ');
      buffer.write(text.substring(4, text.length > 7 ? 7 : text.length));
    }

    if (text.length > 7) {
      buffer.write('-');
      buffer.write(text.substring(7, text.length > 9 ? 9 : text.length));
    }

    if (text.length > 9) {
      buffer.write('-');
      buffer.write(text.substring(9, text.length > 11 ? 11 : text.length));
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
