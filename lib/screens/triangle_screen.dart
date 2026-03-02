import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/animated_result.dart';

class TriangleScreen extends StatefulWidget {
  const TriangleScreen({super.key});

  @override
  State<TriangleScreen> createState() => _TriangleScreenState();
}

class _TriangleScreenState extends State<TriangleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aCtrl = TextEditingController();
  final _bCtrl = TextEditingController();
  final _cCtrl = TextEditingController();

  String? _errorMessage;
  _TriangleResult? _result;

  double _heron(double a, double b, double c) {
    final p = (a + b + c) / 2;
    return sqrt(p * (p - a) * (p - b) * (p - c));
  }

  double _toDeg(double rad) => rad * 180 / pi;

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final a = double.parse(_aCtrl.text.trim());
    final b = double.parse(_bCtrl.text.trim());
    final c = double.parse(_cCtrl.text.trim());

    final sides = [a, b, c];
    bool valid = true;
    for (int i = 0; i < sides.length; i++) {
      double sum = 0;
      for (int j = 0; j < sides.length; j++) {
        if (j != i) sum += sides[j];
      }
      if (sides[i] >= sum) {
        valid = false;
        break;
      }
    }

    if (!valid) {
      setState(() {
        _errorMessage =
            'Бұл жақтармен үшбұрыш болмайды!\nҮшбұрыш теңсіздігі орындалмады: әрбір жақ қалған екі жақтың қосындысынан аз болуы тиіс.';
        _result = null;
      });
      return;
    }

    // Периметр
    final perimeter = a + b + c;
    final area = _heron(a, b, c);

    // Бұрыштар (косинустар теоремасы)
    final angleA = _toDeg(acos((b * b + c * c - a * a) / (2 * b * c)));
    final angleB = _toDeg(acos((a * a + c * c - b * b) / (2 * a * c)));
    final angleC = 180 - angleA - angleB;

    String type;
    if ((angleA - 90).abs() < 0.001 ||
        (angleB - 90).abs() < 0.001 ||
        (angleC - 90).abs() < 0.001) {
      type = 'Тікбұрышты үшбұрыш ✓';
    } else if (angleA < 90 && angleB < 90 && angleC < 90) {
      type = 'Сүйірбұрышты үшбұрыш';
    } else {
      type = 'Доғалбұрышты үшбұрыш';
    }

    setState(() {
      _errorMessage = null;
      _result = _TriangleResult(
        a: a,
        b: b,
        c: c,
        perimeter: perimeter,
        area: area,
        angleA: angleA,
        angleB: angleB,
        angleC: angleC,
        type: type,
      );
    });
  }

  void _reset() {
    _aCtrl.clear();
    _bCtrl.clear();
    _cCtrl.clear();
    setState(() {
      _result = null;
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _aCtrl.dispose();
    _bCtrl.dispose();
    _cCtrl.dispose();
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
              _buildInfoHint(),
              const SizedBox(height: 20),
              _buildForm(),
              const SizedBox(height: 16),
              _buildButtons(),
              const SizedBox(height: 24),
              if (_errorMessage != null) _buildError(_errorMessage!),
              if (_result != null) _buildResults(_result!),
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
              colors: [Color(0xFF8B83FF), Color(0xFF6C63FF)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.change_history,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Үшбұрыш',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Text(
              'A + B деңгей',
              style: TextStyle(color: Color(0xFF8B83FF), fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoHint() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF8B83FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF8B83FF).withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Color(0xFF8B83FF), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Үш жақтың ұзындығын енгізіңіз. Бағдарлама үшбұрыштың бар-жоқтығын тексереді.',
              style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _SideField(
            label: 'а жағы (a)',
            controller: _aCtrl,
            hint: 'мысалы: 3',
          ),
          const SizedBox(height: 12),
          _SideField(
            label: 'b жағы (b)',
            controller: _bCtrl,
            hint: 'мысалы: 4',
          ),
          const SizedBox(height: 12),
          _SideField(
            label: 'c жағы (c)',
            controller: _cCtrl,
            hint: 'мысалы: 5',
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate_outlined),
            label: const Text('Есептеу'),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: _reset,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            side: const BorderSide(color: Color(0xFF8B83FF)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Icon(Icons.refresh, color: Color(0xFF8B83FF)),
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6584).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF6584).withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel_outlined, color: Color(0xFFFF6584), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFFF6584), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(_TriangleResult r) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF03DAC6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF03DAC6).withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF03DAC6),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Үшбұрыш бар! ${r.type}',
                  style: const TextStyle(
                    color: Color(0xFF03DAC6),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _TrianglePainterWidget(a: r.a, b: r.b, c: r.c),
        const SizedBox(height: 16),
        AnimatedResult(
          title: 'Есептеу нәтижелері',
          accentColor: const Color(0xFF8B83FF),
          items: [
            ResultItem(
              'Периметр (P):',
              'P = ${r.perimeter.toStringAsFixed(4)}',
            ),
            ResultItem('Аудан (S):', 'S = ${r.area.toStringAsFixed(4)}'),
            ResultItem('A бұрышы:', '${r.angleA.toStringAsFixed(2)}°'),
            ResultItem('B бұрышы:', '${r.angleB.toStringAsFixed(2)}°'),
            ResultItem('C бұрышы:', '${r.angleC.toStringAsFixed(2)}°'),
            ResultItem('Үшбұрыш түрі:', r.type),
          ],
        ),
      ],
    );
  }
}

class _SideField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  const _SideField({
    required this.label,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.straighten),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Бос қалдырмаңыз';
        final n = double.tryParse(v.trim());
        if (n == null || n <= 0) return 'Оң сан енгізіңіз';
        return null;
      },
    );
  }
}

class _TriangleResult {
  final double a, b, c, perimeter, area, angleA, angleB, angleC;
  final String type;

  const _TriangleResult({
    required this.a,
    required this.b,
    required this.c,
    required this.perimeter,
    required this.area,
    required this.angleA,
    required this.angleB,
    required this.angleC,
    required this.type,
  });
}

class _TrianglePainterWidget extends StatelessWidget {
  final double a, b, c;
  const _TrianglePainterWidget({
    required this.a,
    required this.b,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8B83FF).withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _TrianglePainter(a: a, b: b, c: c),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final double a, b, c;
  _TrianglePainter({required this.a, required this.b, required this.c});

  @override
  void paint(Canvas canvas, Size size) {
    // Координаталарды есептеу
    double cosA = (b * b + c * c - a * a) / (2 * b * c);
    cosA = cosA.clamp(-1.0, 1.0);
    final sinA = sqrt(1 - cosA * cosA);

    // Үшбұрыш төбелері (масштабталмаған)
    final minX = min(0.0, b * cosA);
    final maxX = max(c, b * cosA);
    final minY = -b * sinA;
    final maxY = 0.0;

    final triangleWidth = maxX - minX;
    final triangleHeight = maxY - minY;

    // Масштабты есептеу
    const padding = 35.0;
    final availableWidth = size.width - padding * 2;
    final availableHeight = size.height - padding * 2;

    double scale = 1.0;
    if (triangleWidth > 0 && triangleHeight > 0) {
      scale = min(
        availableWidth / triangleWidth,
        availableHeight / triangleHeight,
      );
    }

    // Ортаға келтіру
    final offsetX = (size.width - triangleWidth * scale) / 2 - minX * scale;
    final offsetY = (size.height + triangleHeight * scale) / 2;

    final p1 = Offset(offsetX, offsetY);
    final p2 = Offset(offsetX + c * scale, offsetY);
    final p3 = Offset(offsetX + b * cosA * scale, offsetY - b * sinA * scale);

    final paint = Paint()
      ..color = const Color(0xFF8B83FF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF8B83FF).withOpacity(0.15)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(path, paint);

    // Жақтардың белгілері
    final tp = TextPainter(textDirection: TextDirection.ltr);
    void label(Offset pos, String text, Color color) {
      tp.text = TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
      tp.layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    label(
      Offset((p1.dx + p2.dx) / 2, p1.dy + 14),
      'c=${c.toStringAsFixed(1)}',
      const Color(0xFFFF6584),
    );
    label(
      Offset((p1.dx + p3.dx) / 2 - 20, (p1.dy + p3.dy) / 2),
      'b=${b.toStringAsFixed(1)}',
      const Color(0xFF03DAC6),
    );
    label(
      Offset((p2.dx + p3.dx) / 2 + 20, (p2.dy + p3.dy) / 2),
      'a=${a.toStringAsFixed(1)}',
      const Color(0xFFFFB347),
    );
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter old) =>
      old.a != a || old.b != b || old.c != c;
}
