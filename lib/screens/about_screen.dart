import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('О приложении'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SkinCheck - ваш персональный помощник для мониторинга здоровья кожи',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Приложение разработано для раннего выявления потенциальных проблем с кожей. '
              'Современные алгоритмы анализа изображений на основе искусственных нейронных сетей '
              'помогают пользователям обратить внимание на подозрительные новообразования '
              'и своевременно обратиться к специалисту.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            
            const Text(
              'Как пользоваться приложением:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildStep('1. Заполните данные о себе в разделе "Профиль" - данные о том, какого Вы пола и возраста, влияют на точность анализа.'),
            _buildStep('2. В разделе "Проверка" из выпадающего списка выберите место, на котором находится ваше образование на коже.'),
            _buildStep('3. Добавьте фотографию образования - либо выбрав из галереи, либо сделав новое фото.'),
            _buildStep('4. Получите предварительную оценку и рекомендации.'),
            const SizedBox(height: 15),
            
            const Text(
              'Приложение анализирует следующие виды образований:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildClassItem('• Актинический кератоз'),
            _buildClassItem('• Базальноклеточная карцинома'),
            _buildClassItem('• Доброкачественный кератоз'),
            _buildClassItem('• Дерматофиброма'),
            _buildClassItem('• Меланома'),
            _buildClassItem('• Родинка (невус)'),
            _buildClassItem('• Сосудистые поражения'),
            const SizedBox(height: 15),
            
            const Text(
              'Важно понимать:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Приложение определяет лишь общий класс образований из ограниченного набора возможных вариантов '
              'и не может заменить полноценную диагностику у специалиста. Точный диагноз может поставить '
              'только врач-дерматолог на основании комплексного обследования.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 25),
            
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text(
                    'Помните:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Алгоритм может ошибаться. Это приложение не заменяет профессиональное '
                    'медицинское обследование! При обнаружении подозрительных образований, '
                    'особенно быстро меняющихся, болезненных или кровоточащих, немедленно '
                    'обратитесь к врачу.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            const Center(
              child: Text(
                'Берегите свое здоровье!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}