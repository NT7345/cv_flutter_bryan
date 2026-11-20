import 'package:material_ui/material_ui.dart';

import '../app_colors.dart';

class PageContent extends StatelessWidget {
  const PageContent({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          child: child,
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({required this.title, this.kicker, super.key});

  final String title;
  final String? kicker;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (kicker != null) ...[
          Text(
            kicker!.toUpperCase(),
            style: const TextStyle(
              color: AppColors.green,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 7),
        ],
        Text(
          title,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 23,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class ProfileIllustration extends StatelessWidget {
  const ProfileIllustration({this.size = 94, this.colorIndex = 0, super.key});

  final double size;
  final int colorIndex;

  static const backgrounds = [
    Color(0xFFE9DACB),
    Color(0xFFDCEBE3),
    Color(0xFFE9E5F0),
    Color(0xFFF2E5CC),
  ];

  static const foregrounds = [
    Color(0xFF7E5F49),
    Color(0xFF356E59),
    Color(0xFF705D8D),
    Color(0xFF987038),
  ];

  @override
  Widget build(BuildContext context) {
    final index = colorIndex % backgrounds.length;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgrounds[index],
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x160D2D25),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Icon(
        Icons.person_rounded,
        size: size * .63,
        color: foregrounds[index],
      ),
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: padding, child: child),
    );
  }
}

class SkillChip extends StatelessWidget {
  const SkillChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
