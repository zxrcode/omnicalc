import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gradient_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<_ModuleInfo> _modules = [
    _ModuleInfo(
      icon: Icons.change_history,
      title: 'Үшбұрыш',
      description: 'Жақтарын енгізіп, периметр, аудан және бұрыштарды есепте',
      colors: [Color(0xFF8B83FF), Color(0xFF6C63FF)],
      level: 'A + B деңгей',
    ),
    _ModuleInfo(
      icon: Icons.sports_esports,
      title: 'Санды тап',
      description: '1-ден 20-ға дейін санды 5 қадамда тап',
      colors: [Color(0xFFFF6584), Color(0xFFFF4757)],
      level: 'B деңгей',
    ),
    _ModuleInfo(
      icon: Icons.show_chart,
      title: 'Прогрессиялар',
      description: 'Геометриялық және арифметикалық прогрессиялардың қосындысы',
      colors: [Color(0xFF03DAC6), Color(0xFF00897B)],
      level: 'A + C деңгей',
    ),
    _ModuleInfo(
      icon: Icons.view_in_ar,
      title: '3D Фигуралар',
      description: 'Сфера, куб, пирамида, призманың беті мен көлемі',
      colors: [Color(0xFFFFB347), Color(0xFFFF8C00)],
      level: 'C деңгей',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildHeader(),
            const SizedBox(height: 28),
            Text(
              'Модульдер',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFAAAAAA),
              ),
            ),
            const SizedBox(height: 14),
            ..._modules.asMap().entries.map((entry) {
              final delay = entry.key * 0.15;
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final start = delay;
                  final end = (delay + 0.5).clamp(0.0, 1.0);
                  final t = ((_controller.value - start) / (end - start)).clamp(
                    0.0,
                    1.0,
                  );
                  return Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - t)),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _ModuleCard(module: entry.value),
                ),
              );
            }),
            const SizedBox(height: 10),
            _buildInfoBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return GradientCard(
      colors: const [Color(0xFF8B83FF), Color(0xFF5C4DFF)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OmniCalc',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Математикалық қосымша',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '4 модуль · A, B, C деңгейлер · Қазақ тілінде',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A4A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF8B83FF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Мәзірдегі белгішелерге басу арқылы қажетті модульге өтіңіз',
              style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatefulWidget {
  final _ModuleInfo module;
  const _ModuleCard({required this.module});

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.module.colors.first.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.module.colors.first.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.module.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.module.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.module.title,
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.module.description,
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: widget.module.colors.first.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.module.level,
                        style: TextStyle(
                          color: widget.module.colors.first,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleInfo {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> colors;
  final String level;

  const _ModuleInfo({
    required this.icon,
    required this.title,
    required this.description,
    required this.colors,
    required this.level,
  });
}
