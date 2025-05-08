import 'package:flutter/material.dart';
import 'screens/about_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/check_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// void main() => runApp(MyApp());
void main() async {
  // Инициализация локализации
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU', null);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skin Check',
      theme: ThemeData(primarySwatch: Colors.green),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate, // Локализация Material компонентов
        GlobalWidgetsLocalizations.delegate, // Локализация базовых виджетов
        GlobalCupertinoLocalizations.delegate, // Локализация iOS-стиля
      ],
      supportedLocales: const [
        Locale('ru', 'RU'), // Поддерживаемые локали (русский)
      ],
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Skin Check'),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.info), text: 'Информация'),
                Tab(icon: Icon(Icons.person), text: 'Профиль'),
                Tab(icon: Icon(Icons.camera), text: 'Проверка'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              AboutScreen(),
              ProfileScreen(),
              CheckScreen(),
            ],
          ),
        ),
      ),
    );
  }
}