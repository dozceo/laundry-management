import 'dart:math';
import 'package:flutter/material.dart';
import '../models/laundry_model.dart';
import '../utils/colors.dart';
import 'basket_painter.dart';

class LaundryBasketWidget extends StatefulWidget {
  final LaundryCategory category;
  final VoidCallback onWash;
  final GlobalKey basketKey;

  const LaundryBasketWidget({
    super.key,
    required this.category,
    required this.onWash,
    required this.basketKey,
  });

  @override
  State<LaundryBasketWidget> createState() => _LaundryBasketWidgetState();
}

class _LaundryBasketWidgetState extends State<LaundryBasketWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LaundryBasketWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.category.pileCount != oldWidget.category.pileCount &&
        widget.category.pileCount > oldWidget.category.pileCount) {
      _shakeController.forward(from: 0);
    }
  }

  Color get _statusColor {
    switch (widget.category.riskLevel) {
      case 'critical':
        return AppColors.critical;
      case 'warning':
        return AppColors.warning;
      default:
        return AppColors.safe;
    }
  }

  String get _statusLabel {
    switch (widget.category.riskLevel) {
      case 'critical':
        return '🔴 Full! Wash now';
      case 'warning':
        return '🟡 Filling up';
      default:
        return '🟢 Looking good';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          cat.washMethod == 'machine'
                              ? Icons.local_laundry_service
                              : Icons.back_hand_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cat.washMethod == 'machine'
                              ? 'Machine Wash'
                              : 'Manual Wash',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${cat.pileCount} items',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: _statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Basket
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final shake =
                    sin(_shakeController.value * pi * 4) *
                    (1 - _shakeController.value) *
                    3;
                return Transform.translate(
                  offset: Offset(shake, 0),
                  child: child,
                );
              },
              child: SizedBox(
                key: widget.basketKey,
                height: 180,
                width: double.infinity,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: cat.fillPercentage),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return CustomPaint(
                      painter: LaundryBasketPainter(
                        fillPercent: value,
                        riskLevel: cat.riskLevel,
                        pileCount: cat.pileCount,
                        emoji: cat.emoji,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Status
            Text(
              _statusLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _statusColor,
              ),
            ),
            const SizedBox(height: 16),

            // Wash button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onWash,
                icon: const Icon(Icons.water_drop, size: 20),
                label: Text(
                  cat.washMethod == 'machine'
                      ? 'Start Machine Wash'
                      : 'Start Manual Wash',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
