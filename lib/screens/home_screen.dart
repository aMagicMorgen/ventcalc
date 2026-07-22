import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/calculation.dart';
import '../utils/calculator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _calculator = Calculator();
  final _formKey = GlobalKey<FormState>();
  final _input = CalculationInput();
  CalculationResult? _result;
  bool _isLoading = false;

  final _tempController = TextEditingController(text: '21');
  final _humidityController = TextEditingController(text: '50');
  final _pressureController = TextEditingController();
  final _rarefactionController = TextEditingController();
  final _airSpeedController = TextEditingController();
  final _roomLengthController = TextEditingController(text: '4.5');
  final _roomWidthController = TextEditingController(text: '6');
  final _roomHeightController = TextEditingController(text: '2.7');
  final _channelWidthController = TextEditingController(text: '15');
  final _channelHeightController = TextEditingController(text: '15');
  final _channelDiameterController = TextEditingController(text: '15');

  String _channelShape = 'rectangular';

  @override
  void dispose() {
    _tempController.dispose();
    _humidityController.dispose();
    _pressureController.dispose();
    _rarefactionController.dispose();
    _airSpeedController.dispose();
    _roomLengthController.dispose();
    _roomWidthController.dispose();
    _roomHeightController.dispose();
    _channelWidthController.dispose();
    _channelHeightController.dispose();
    _channelDiameterController.dispose();
    super.dispose();
  }

  void _performCalculation() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      _input.temp = double.parse(_tempController.text);
      _input.humidity = double.parse(_humidityController.text);
      _input.pressure = _pressureController.text.isNotEmpty
          ? double.parse(_pressureController.text)
          : null;
      _input.rarefaction = double.parse(_rarefactionController.text);
      _input.airSpeed = double.parse(_airSpeedController.text);
      _input.channelShape = _channelShape;
      _input.channelWidth = double.parse(_channelWidthController.text);
      _input.channelHeight = double.parse(_channelHeightController.text);
      _input.channelDiameter = double.parse(_channelDiameterController.text);
      _input.roomLength = double.parse(_roomLengthController.text);
      _input.roomWidth = double.parse(_roomWidthController.text);
      _input.roomHeight = double.parse(_roomHeightController.text);

      final result = _calculator.calculate(_input);
      setState(() {
        _result = result;
        _isLoading = false;
      });

      if (result == null) {
        _showError('Проверьте введенные данные');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Ошибка: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildForm(),
                const SizedBox(height: 16),
                if (_result != null) _buildResults(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a73e8), Color(0xFF1557b0)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Text(
              'ООО "ЛиК"',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Калькулятор для Акта проверки',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Параметры помещения
              _buildSectionTitle('1. Параметры помещения', Icons.house_outlined),
              _buildTextField(
                controller: _roomLengthController,
                label: 'Длина помещения (м)',
                icon: Icons.straighten,
                validator: (v) => v != null && double.tryParse(v) != null
                    ? null
                    : 'Введите число',
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _roomWidthController,
                label: 'Ширина помещения (м)',
                icon: Icons.straighten,
                validator: (v) => v != null && double.tryParse(v) != null
                    ? null
                    : 'Введите число',
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _roomHeightController,
                label: 'Высота потолков (м)',
                icon: Icons.height,
                validator: (v) => v != null && double.tryParse(v) != null
                    ? null
                    : 'Введите число',
              ),
              const SizedBox(height: 16),

              // Условия среды
              _buildSectionTitle('2. Условия среды (Testo 622)', Icons.thermostat),
              _buildTextField(
                controller: _tempController,
                label: 'Температура воздуха (°C)',
                icon: Icons.thermostat,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null) return 'Введите значение';
                  final val = double.tryParse(v);
                  if (val == null) return 'Введите число';
                  if (val < -50 || val > 50) return 'Температура от -50 до 50°C';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _humidityController,
                label: 'Относительная влажность (%)',
                icon: Icons.water_drop,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null) return 'Введите значение';
                  final val = double.tryParse(v);
                  if (val == null) return 'Введите число';
                  if (val < 0 || val > 100) return 'Влажность 0-100%';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _pressureController,
                label: 'Атм. давление (мм рт. ст.)',
                icon: Icons.speed,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || v.isEmpty || double.tryParse(v) != null
                    ? null
                    : 'Введите число',
              ),
              const SizedBox(height: 16),

              // Приток воздуха
              _buildSectionTitle('3. Приток воздуха (RGK AM-20)', Icons.wind_power),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _airSpeedController,
                label: 'Ср. скорость воздуха (м/с)',
                icon: Icons.speed,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null) return 'Введите значение';
                  final val = double.tryParse(v);
                  if (val == null) return 'Введите число';
                  if (val < 0) return 'Скорость не может быть отрицательной';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildShapeToggle(),
              const SizedBox(height: 12),
              if (_channelShape == 'rectangular') ...[
                _buildTextField(
                  controller: _channelWidthController,
                  label: 'Ширина сечения (см)',
                  icon: Icons.width_normal,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => v != null && double.tryParse(v) != null
                      ? null
                      : 'Введите число',
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _channelHeightController,
                  label: 'Высота сечения (см)',
                  icon: Icons.height,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => v != null && double.tryParse(v) != null
                      ? null
                      : 'Введите число',
                ),
              ] else ...[
                _buildTextField(
                  controller: _channelDiameterController,
                  label: 'Диаметр канала (см)',
                  icon: Icons.circle_outlined,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => v != null && double.tryParse(v) != null
                      ? null
                      : 'Введите число',
                ),
              ],
              const SizedBox(height: 16),

              // Разрежение
              _buildSectionTitle('4. Разрежение (Verdo MA 1103)', Icons.bar_chart),
              _buildTextField(
                controller: _rarefactionController,
                label: 'Измеренное разрежение (Па)',
                icon: Icons.show_chart,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null) return 'Введите значение';
                  final val = double.tryParse(v);
                  if (val == null) return 'Введите число';
                  if (val < 0) return 'Разрежение не может быть отрицательным';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Кнопка расчёта
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _performCalculation,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF1a73e8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calculate, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Выполнить расчет',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1a73e8), size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a73e8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.numberWithOptions(decimal: true),
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1a73e8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$')),
      ],
    );
  }

  Widget _buildShapeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Форма сечения канала:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildToggleButton(
                title: 'Прямоугольное',
                icon: Icons.square_outlined,
                isActive: _channelShape == 'rectangular',
                onTap: () {
                  setState(() => _channelShape = 'rectangular');
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildToggleButton(
                title: 'Круглое',
                icon: Icons.circle_outlined,
                isActive: _channelShape == 'round',
                onTap: () {
                  setState(() => _channelShape = 'round');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1a73e8) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFF1a73e8) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey.shade700,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final r = _result!;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.checklist, color: Color(0xFF1a73e8)),
                SizedBox(width: 8),
                Text(
                  'Результаты проверки',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a73e8),
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildResultItem(
              'Условия среды',
              'Температура: ${r.temp}°C\nВлажность: ${r.humidity}%\nДавление: ${r.pressure ?? '–'} мм рт. ст.',
              Icons.thermostat,
            ),
            const Divider(),
            _buildResultItem(
              'Разрежение',
              '${r.rarefaction} Па\n${r.rarefactionNorm}',
              Icons.bar_chart,
              isPass: r.rarefaction >= 5,
            ),
            const Divider(),
            _buildResultItem(
              'Сечение канала',
              '${r.channelDescription}\nПлощадь: ${r.channelArea.toStringAsFixed(4)} м²',
              Icons.square,
            ),
            const Divider(),
            _buildResultItem(
              'Помещение',
              'Объем: ${r.Vpom.toStringAsFixed(2)} м³\nПлощадь: ${r.roomArea.toStringAsFixed(2)} м²',
              Icons.house,
            ),
            const Divider(),
            _buildResultItem(
              'Воздухообмен',
              'L = ${r.L.toStringAsFixed(2)} м³/ч\nn = ${r.n.toStringAsFixed(2)} об/ч\n${r.ventNorm}',
              Icons.air,
              isPass: r.n >= 1.0,
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Примечание: Согласно Постановлению №410, если разрежение < 5 Па, а кратность < 1 об/ч, необходимо выдать предписание.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String title, String content, IconData icon,
      {bool? isPass}) {
    final statusColor = isPass == null
        ? null
        : isPass
            ? Colors.green
            : Colors.red;
    final statusText = isPass == null
        ? null
        : isPass
            ? '✅ Соответствует'
            : '❌ Не соответствует';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1a73e8), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          if (statusText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (isPass! ? Colors.green : Colors.red).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isPass ? Colors.green : Colors.red,
                ),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isPass ? Colors.green : Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }
}