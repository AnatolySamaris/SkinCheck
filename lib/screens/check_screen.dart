import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skin_check/screens/processing_screen.dart';
import 'dart:convert';

class CheckScreen extends StatefulWidget {
  const CheckScreen({super.key});

  @override
  _CheckScreenState createState() => _CheckScreenState();
}

class _CheckScreenState extends State<CheckScreen> {
  String? _selectedLocation;
  File? _image;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _sendDataToServer() async {
    if (_selectedLocation == null || _image == null) return;

    setState(() => _isLoading = true);

    try {
      // Получаем данные пользователя
      final prefs = await SharedPreferences.getInstance();
      final birthDateStr = prefs.getString('birthDate');
      final genderStr =
          prefs.getString('gender') == 'Gender.male' ? 'Мужской' : 'Женский';

      // Подготовка данных
      final request = http.MultipartRequest(
        'POST',
        // Uri.parse('http://127.0.0.1:8000/predict/'),
        Uri.parse('https://skincheckapp-anatolysamaris.amvera.io/predict/')
      );

      // Добавляем файл изображения
      request.files.add(
        await http.MultipartFile.fromPath('image', _image!.path),
      );

      // Добавляем другие данные
      request.fields.addAll({
        'localization': _selectedLocation!,
        'birthdate': birthDateStr ?? '',
        'gender': genderStr,
      });

      // Отправка запроса
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);

      final birthDate = prefs.getString('birthDate');
      final gender = prefs.getString('gender') ?? "Gender.male";

      if (jsonResponse['ok'] == true) {
        // Переход на экран результатов
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProcessingScreen(
                  image: _image!,
                  location: _selectedLocation!,
                  prediction: jsonResponse['data']['prediction'],
                  probability: jsonResponse['data']['probability'].toDouble(),
                  gender: gender,
                  birthDate: birthDate,
                ),
          ),
        );
      } else {
        // Показать ошибку
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${jsonResponse['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка соединения: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final safePadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: safePadding + 20),
        child: ElevatedButton(
          onPressed:
              (_selectedLocation != null && _image != null && !_isLoading)
                  ? () => _sendDataToServer()
                  : null,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(screenWidth * 0.9, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child:
              _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Далее'),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Выбор локализации
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              decoration: InputDecoration(
                labelText: 'Локализация',
                border: OutlineInputBorder(),
              ),
              items:
                  [
                    "Ладонь, подошва или ноготь", "Спина", "Грудь",
                    "Ухо", "Лицо", "Стопа", "Гениталии", "Кисть руки", 
                    "Бедро, колено или голень", "Шея", "Скальп (волосистая часть головы)",
                    "Живот, бока или пах", "Плечо, локоть или предплечье"
                ]
                      .map(
                        (location) => DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedLocation = value),
            ),
            SizedBox(height: 20),

            // Поле для загрузки изображения
            GestureDetector(
              onTap:
                  () => showModalBottomSheet(
                    context: context,
                    builder:
                        (ctx) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(Icons.photo_library),
                              title: Text('Галерея'),
                              onTap: () {
                                Navigator.pop(ctx);
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.camera_alt),
                              title: Text('Камера'),
                              onTap: () {
                                Navigator.pop(ctx);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                          ],
                        ),
                  ),
              child: Container(
                width: screenWidth - 40,
                height: screenWidth - 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child:
                    _image != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                            width: screenWidth,
                            height: screenWidth,
                          ),
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Добавить фото',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
