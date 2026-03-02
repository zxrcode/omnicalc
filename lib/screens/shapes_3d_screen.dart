import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/animated_result.dart';

class Shapes3DScreen extends StatefulWidget {
  const Shapes3DScreen({super.key});

  @override
  State<Shapes3DScreen> createState() => _Shapes3DScreenState();
}

class _Shapes3DScreenState extends State<Shapes3DScreen> {
  // Лимит орнатылды ма?
  bool _limitSet = false;
  final _limitCtrl = TextEditingController();
  int _maxQueries = 0;
  int _usedQueries = 0;

  // Таңдалған фигура
  int _selectedShape = 0; // 0=Сфера, 1=Куб, 2=Пирамида, 3=Призма
  final List<_ShapeInfo> _shapes = const [
    _ShapeInfo(
      name: 'Сфера',
      icon: Icons.circle,
      params: ['Радиус (r)'],
      color: Color(0xFFFFB347),
    ),
    _ShapeInfo(
      name: 'Куб',
      icon: Icons.crop_square,
      params: ['Қабырға (a)'],
      color: Color(0xFF8B83FF),
    ),
    _ShapeInfo(
      name: 'Пирамида',
      icon: Icons.change_history,
      params: ['Негіз қабырғасы (a)', 'Биіктік (h)'],
      color: Color(0xFF03DAC6),
    ),
    _ShapeInfo(
      name: 'Призма',
      icon: Icons.view_in_ar,
      params: ['Негіз қабырғасы (a)', 'Биіктік (h)'],
      color: Color(0xFFFF6584),
    ),
  ];

  final List<TextEditingController> _paramCtrls = [
    TextEditingController(),
    TextEditingController(),
  ];
  final _formKey = GlobalKey<FormState>();
  _ShapeResult? _result;
  List<_HistoryEntry> _history = [];

  bool get _limitReached => _usedQueries >= _maxQueries;

  void _setLimit() {
    final n = int.tryParse(_limitCtrl.text.trim());
    if (n == null || n < 1 || n > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('1-ден 100-ге дейін сан енгізіңіз!')),
      );
      return;
    }
    setState(() {
      _maxQueries = n;
      _limitSet = true;
    });
  }

  void _calculate() {
    if (_limitReached) return;
    if (!_formKey.currentState!.validate()) return;

    final p0 = double.parse(_paramCtrls[0].text.trim());
    double surface = 0, volume = 0;
    String formula = '';

    // switch-case шарты арқылы фигура таңдау
    switch (_selectedShape) {
      case 0: // Сфера
        surface = 4 * pi * p0 * p0;
        volume = (4 / 3) * pi * pow(p0, 3);
        formula = 'S=4πr², V=4/3·πr³';
        break;
      case 1: // Куб
        surface = 6 * p0 * p0;
        volume = pow(p0, 3).toDouble();
        formula = 'S=6a², V=a³';
        break;
      case 2: // Пирамида (дұрыс төртбұрышты)
        final p1 = double.parse(_paramCtrls[1].text.trim());
        final slant = sqrt(pow(p0 / 2, 2) + pow(p1, 2));
        surface = p0 * p0 + 2 * p0 * slant;
        volume = (1 / 3) * p0 * p0 * p1;
        formula = 'S=a²+2a·l, V=1/3·a²·h';
        break;
      case 3: // Призма (дұрыс төртбұрышты)
        final p1 = double.parse(_paramCtrls[1].text.trim());
        surface = 2 * p0 * p0 + 4 * p0 * p1;
        volume = p0 * p0 * p1;
        formula = 'S=2a²+4ah, V=a²h';
        break;
    }

    final r = _ShapeResult(
      shapeName: _shapes[_selectedShape].name,
      surface: surface,
      volume: volume,
      formula: formula,
    );

    // Тарихты жаңарту (цикл + limit шарты)
    setState(() {
      _result = r;
      _usedQueries++;
      _history.insert(
        0,
        _HistoryEntry(
          number: _usedQueries,
          shapeName: r.shapeName,
          surface: r.surface,
          volume: r.volume,
        ),
      );
    });

    // Параметрлерді тазарту
    for (final c in _paramCtrls) {
      c.clear();
    }
  }

  void _reset() {
    setState(() {
      _limitSet = false;
      _usedQueries = 0;
      _maxQueries = 0;
      _result = null;
      _history = [];
      _limitCtrl.clear();
      for (final c in _paramCtrls) {
        c.clear();
      }
    });
  }

  @override
  void dispose() {
    _limitCtrl.dispose();
    for (final c in _paramCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              if (!_limitSet) _buildLimitSetter() else _buildCalculator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFB347), Color(0xFFFF8C00)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.view_in_ar, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '3D Фигуралар',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Text(
              'C деңгей',
              style: TextStyle(color: Color(0xFFFFB347), fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLimitSetter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFB347).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.lock_outline,
                    color: Color(0xFFFFB347),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Сұраныс лимитін орнату',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Есептеу санын шектеу үшін рұқсат етілген сұраныс санын енгізіңіз (1-100).',
                style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _limitCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Максималды сұраныс саны',
                  prefixIcon: Icon(Icons.pin),
                  hintText: 'мысалы: 5',
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _setLimit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB347),
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('Жалғастыру'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalculator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQueryCounter(),
        const SizedBox(height: 16),
        if (_limitReached)
          _buildLimitReachedCard()
        else ...[
          _buildShapeSelector(),
          const SizedBox(height: 16),
          _buildParamForm(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _calculate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB347),
                  ),
                  icon: const Icon(Icons.calculate_outlined),
                  label: const Text('Есептеу'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _reset,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  side: const BorderSide(color: Color(0xFFFFB347)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Icon(Icons.restart_alt, color: Color(0xFFFFB347)),
              ),
            ],
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            AnimatedResult(
              title: 'Есептеу нәтижелері — ${_result!.shapeName}',
              accentColor: const Color(0xFFFFB347),
              items: [
                ResultItem('Формула:', _result!.formula),
                ResultItem(
                  'Толық бет (S):',
                  '${_result!.surface.toStringAsFixed(4)} бір.²',
                ),
                ResultItem(
                  'Көлем (V):',
                  '${_result!.volume.toStringAsFixed(4)} бір.³',
                ),
              ],
            ),
          ],
        ],
        if (_history.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildHistory(),
        ],
      ],
    );
  }

  Widget _buildQueryCounter() {
    final remaining = _maxQueries - _usedQueries;
    final color = remaining > _maxQueries / 2
        ? const Color(0xFF03DAC6)
        : remaining > 0
        ? const Color(0xFFFFB347)
        : const Color(0xFFFF6584);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.data_usage, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Сұраныстар: $_usedQueries/$_maxQueries',
                  style: GoogleFonts.outfit(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Қалғаны: $remaining',
                  style: TextStyle(color: color.withOpacity(0.7), fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            children: List.generate(_maxQueries.clamp(0, 10), (i) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: i < _usedQueries ? color.withOpacity(0.3) : color,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitReachedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6584).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF6584).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.block, color: Color(0xFFFF6584), size: 40),
          const SizedBox(height: 12),
          Text(
            'Сұраныс лимиті таусылды',
            style: GoogleFonts.outfit(
              color: const Color(0xFFFF6584),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Сіз $_maxQueries сұраныс пайдаландыңыз. Жаңадан бастау үшін лимитті қалпына келтіріңіз.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFFF6584).withOpacity(0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _reset,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6584),
            ),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Қалпына келтіру'),
          ),
        ],
      ),
    );
  }

  Widget _buildShapeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Фигура таңдаңыз:',
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: const Color(0xFFAAAAAA),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: _shapes.asMap().entries.map((e) {
            final selected = e.key == _selectedShape;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedShape = e.key;
                    _result = null;
                    for (final c in _paramCtrls) {
                      c.clear();
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected
                        ? e.value.color.withOpacity(0.2)
                        : const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? e.value.color : const Color(0xFF2A2A4A),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        e.value.icon,
                        color: selected
                            ? e.value.color
                            : const Color(0xFF666680),
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.value.name,
                        style: TextStyle(
                          color: selected
                              ? e.value.color
                              : const Color(0xFF888888),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildParamForm() {
    final shape = _shapes[_selectedShape];
    return Form(
      key: _formKey,
      child: Column(
        children: shape.params.asMap().entries.map((e) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: e.key < shape.params.length - 1 ? 10 : 0,
            ),
            child: TextFormField(
              controller: _paramCtrls[e.key],
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(
                labelText: e.value,
                prefixIcon: Icon(Icons.straighten, color: shape.color),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: shape.color, width: 2),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Бос қалдырмаңыз';
                final n = double.tryParse(v.trim());
                if (n == null || n <= 0) return 'Оң сан енгізіңіз';
                return null;
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHistory() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Есептеу тарихы',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: const Color(0xFFAAAAAA),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          // for цикл арқылы тарихты шығару
          for (int i = 0; i < _history.length; i++) ...[
            if (i > 0) const Divider(color: Color(0xFF2A2A4A), height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB347).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${_history[i].number}',
                      style: const TextStyle(
                        color: Color(0xFFFFB347),
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _history[i].shapeName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'S=${_history[i].surface.toStringAsFixed(2)}  V=${_history[i].volume.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShapeInfo {
  final String name;
  final IconData icon;
  final List<String> params;
  final Color color;

  const _ShapeInfo({
    required this.name,
    required this.icon,
    required this.params,
    required this.color,
  });
}

class _ShapeResult {
  final String shapeName;
  final double surface;
  final double volume;
  final String formula;

  const _ShapeResult({
    required this.shapeName,
    required this.surface,
    required this.volume,
    required this.formula,
  });
}

class _HistoryEntry {
  final int number;
  final String shapeName;
  final double surface;
  final double volume;

  const _HistoryEntry({
    required this.number,
    required this.shapeName,
    required this.surface,
    required this.volume,
  });
}
