import 'package:flutter/material.dart';
import '../utils/colors.dart';

class AddClothesButton extends StatefulWidget {
  final String emoji;
  final String label;
  final String sublabel;
  final VoidCallback onTap;
  final GlobalKey buttonKey;

  const AddClothesButton({
    super.key,
    required this.emoji,
    required this.label,
    required this.sublabel,
    required this.onTap,
    required this.buttonKey,
  });

  @override
  State<AddClothesButton> createState() => _AddClothesButtonState();
}

class _AddClothesButtonState extends State<AddClothesButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.1), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _bounceController.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _bounceAnim,
          builder: (context, child) {
            return Transform.scale(scale: _bounceAnim.value, child: child);
          },
          child: Container(
            key: widget.buttonKey,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  widget.emoji,
                  style: const TextStyle(fontSize: 44),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child: Text(
                    widget.sublabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
