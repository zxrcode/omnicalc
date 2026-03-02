import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/animated_result.dart';

class ProgressionsScreen extends StatefulWidget {
  const ProgressionsScreen({super.key});

  @override
  State<ProgressionsScreen> createState() => _ProgressionsScreenState();
}

class _ProgressionsScreenState extends State<ProgressionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildHeader(),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF03DAC6), Color(0xFF00897B)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF888888),
                  labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Геометриялық'),
                    Tab(text: 'Арифметикалық'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [_GeometricTab(), _ArithmeticTab()],
              ),
            ),
          ],
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
              colors: [Color(0xFF03DAC6), Color(0xFF00897B)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.show_chart, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Прогрессиялар',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Text(
              'A + C деңгей',
              style: TextStyle(color: Color(0xFF03DAC6), fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Геометриялық прогрессия ───────────────────────────────────────────────
class _GeometricTab extends StatefulWidget {
  const _GeometricTab();

  @override
  State<_GeometricTab> createState() => _GeometricTabState();
}

class _GeometricTabState extends State<_GeometricTab> {
  final _b1Ctrl = TextEditingController();
  final _qCtrl = TextEditingController();
  final _nCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<double> _terms = [];
  double? _sum;
  String? _error;

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final b1 = double.parse(_b1Ctrl.text.trim());
    final q = double.parse(_qCtrl.text.trim());
    final n = int.parse(_nCtrl.text.trim());

    if (n < 1 || n > 50) {
      setState(() => _error = 'n мәні 1-ден 50-ге дейін болуы тиіс');
      return;
    }

    // for циклі арқылы мүшелерді есептеу
    final terms = <double>[];
    for (int i = 0; i < n; i++) {
      terms.add(b1 * pow(q, i));
    }

    // Қосынды: Sn = b1*(q^n - 1)/(q - 1)
    double sum;
    if ((q - 1).abs() < 1e-10) {
      sum = b1 * n; // q = 1 болса
    } else {
      sum = b1 * (pow(q, n) - 1) / (q - 1);
    }

    setState(() {
      _terms = terms;
      _sum = sum;
      _error = null;
    });
  }

  void _reset() {
    _b1Ctrl.clear();
    _qCtrl.clear();
    _nCtrl.clear();
    setState(() {
      _terms = [];
      _sum = null;
      _error = null;
    });
  }

  @override
  void dispose() {
    _b1Ctrl.dispose();
    _qCtrl.dispose();
    _nCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildFormulaCard(
            'Геометриялық прогрессия',
            'Sₙ = b₁·(qⁿ − 1) / (q − 1)',
            'bₙ = b₁·qⁿ⁻¹',
            const Color(0xFF03DAC6),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _NumField(
                  ctrl: _b1Ctrl,
                  label: 'Бірінші мүше (b₁)',
                  hint: 'мысалы: 2',
                  allowDecimal: true,
                ),
                const SizedBox(height: 10),
                _NumField(
                  ctrl: _qCtrl,
                  label: 'Еселік (q)',
                  hint: 'мысалы: 3',
                  allowDecimal: true,
                  allowNegative: true,
                ),
                const SizedBox(height: 10),
                _NumField(
                  ctrl: _nCtrl,
                  label: 'Мүшелер саны (n)',
                  hint: 'мысалы: 5',
                  allowDecimal: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ActionButtons(
            onCalc: _calculate,
            onReset: _reset,
            color: const Color(0xFF03DAC6),
          ),
          const SizedBox(height: 16),
          if (_error != null) _ErrorCard(_error!),
          if (_sum != null) ...[
            AnimatedResult(
              title: 'Нәтиже',
              accentColor: const Color(0xFF03DAC6),
              items: [
                ResultItem('n-ші мүше (bₙ):', _terms.last.toStringAsFixed(6)),
                ResultItem('Қосынды (Sₙ):', _sum!.toStringAsFixed(6)),
              ],
            ),
            const SizedBox(height: 12),
            _TermsList(terms: _terms, color: const Color(0xFF03DAC6)),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Арифметикалық прогрессия ──────────────────────────────────────────────
class _ArithmeticTab extends StatefulWidget {
  const _ArithmeticTab();

  @override
  State<_ArithmeticTab> createState() => _ArithmeticTabState();
}

class _ArithmeticTabState extends State<_ArithmeticTab> {
  final _a1Ctrl = TextEditingController();
  final _dCtrl = TextEditingController();
  final _nCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<double> _terms = [];
  double? _sum;
  double? _an;
  String? _error;

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    final a1 = double.parse(_a1Ctrl.text.trim());
    final d = double.parse(_dCtrl.text.trim());
    final n = int.parse(_nCtrl.text.trim());

    if (n < 1 || n > 50) {
      setState(() => _error = 'n мәні 1-ден 50-ге дейін болуы тиіс');
      return;
    }

    // for циклі арқылы мүшелерді есептеу
    final terms = <double>[];
    for (int i = 0; i < n; i++) {
      terms.add(a1 + i * d);
    }

    // Қосынды: Sn = n/2 * (2a1 + (n-1)*d)
    final sum = n / 2 * (2 * a1 + (n - 1) * d);
    // n-ші мүше: an = a1 + (n-1)*d
    final an = a1 + (n - 1) * d;

    setState(() {
      _terms = terms;
      _sum = sum;
      _an = an;
      _error = null;
    });
  }

  void _reset() {
    _a1Ctrl.clear();
    _dCtrl.clear();
    _nCtrl.clear();
    setState(() {
      _terms = [];
      _sum = null;
      _an = null;
      _error = null;
    });
  }

  @override
  void dispose() {
    _a1Ctrl.dispose();
    _dCtrl.dispose();
    _nCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildFormulaCard(
            'Арифметикалық прогрессия',
            'Sₙ = n/2·(2a₁ + (n−1)·d)',
            'aₙ = a₁ + (n−1)·d',
            const Color(0xFF8B83FF),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _NumField(
                  ctrl: _a1Ctrl,
                  label: 'Бірінші мүше (a₁)',
                  hint: 'мысалы: 1',
                  allowDecimal: true,
                  allowNegative: true,
                ),
                const SizedBox(height: 10),
                _NumField(
                  ctrl: _dCtrl,
                  label: 'Айырым (d)',
                  hint: 'мысалы: 2',
                  allowDecimal: true,
                  allowNegative: true,
                ),
                const SizedBox(height: 10),
                _NumField(
                  ctrl: _nCtrl,
                  label: 'Мүшелер саны (n)',
                  hint: 'мысалы: 5',
                  allowDecimal: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ActionButtons(
            onCalc: _calculate,
            onReset: _reset,
            color: const Color(0xFF8B83FF),
          ),
          const SizedBox(height: 16),
          if (_error != null) _ErrorCard(_error!),
          if (_sum != null) ...[
            AnimatedResult(
              title: 'Нәтиже',
              accentColor: const Color(0xFF8B83FF),
              items: [
                ResultItem('n-ші мүше (aₙ):', _an!.toStringAsFixed(4)),
                ResultItem('Қосынды (Sₙ):', _sum!.toStringAsFixed(4)),
              ],
            ),
            const SizedBox(height: 12),
            _TermsList(terms: _terms, color: const Color(0xFF8B83FF)),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Жалпы виджеттер ───────────────────────────────────────────────────────
Widget _buildFormulaCard(String title, String f1, String f2, Color color) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            f1,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            f2,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _NumField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final bool allowDecimal;
  final bool allowNegative;

  const _NumField({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.allowDecimal = true,
    this.allowNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.numberWithOptions(
        decimal: allowDecimal,
        signed: allowNegative,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(allowNegative ? r'[-0-9.]' : r'[0-9.]'),
        ),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.numbers),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Бос қалдырмаңыз';
        if (allowDecimal) {
          if (double.tryParse(v.trim()) == null) return 'Сан енгізіңіз';
        } else {
          if (int.tryParse(v.trim()) == null) return 'Бүтін сан енгізіңіз';
        }
        return null;
      },
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onCalc;
  final VoidCallback onReset;
  final Color color;

  const _ActionButtons({
    required this.onCalc,
    required this.onReset,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onCalc,
            style: ElevatedButton.styleFrom(backgroundColor: color),
            icon: const Icon(Icons.calculate_outlined),
            label: const Text('Есептеу'),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: onReset,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            side: BorderSide(color: color),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Icon(Icons.refresh, color: color),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6584).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFF6584).withOpacity(0.4)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFFFF6584), fontSize: 13),
      ),
    );
  }
}

class _TermsList extends StatelessWidget {
  final List<double> terms;
  final Color color;

  const _TermsList({required this.terms, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Мүшелер тізімі (жалпы ${terms.length} мүше):',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: terms.asMap().entries.map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  'b${e.key + 1}=${e.value.toStringAsFixed(2)}',
                  style: TextStyle(color: color, fontSize: 12),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
