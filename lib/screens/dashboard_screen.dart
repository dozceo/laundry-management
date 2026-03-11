import 'package:flutter/material.dart';
import '../providers/laundry_provider.dart';
import '../utils/colors.dart';
import '../widgets/add_clothes_button.dart';
import '../widgets/flying_cloth_overlay.dart';
import '../widgets/laundry_basket.dart';

class DashboardScreen extends StatefulWidget {
  final LaundryProvider provider;

  const DashboardScreen({super.key, required this.provider});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Keys for flying animation source & targets
  final GlobalKey _innersButtonKey = GlobalKey();
  final GlobalKey _othersButtonKey = GlobalKey();
  final GlobalKey _innersBasketKey = GlobalKey();
  final GlobalKey _othersBasketKey = GlobalKey();

  void _addClothes(String categoryId) {
    final overlay = FlyingClothOverlay.of(context);
    final cat =
        widget.provider.categories.firstWhere((c) => c.id == categoryId);

    final fromKey =
        categoryId == 'inners' ? _innersButtonKey : _othersButtonKey;
    final toKey =
        categoryId == 'inners' ? _innersBasketKey : _othersBasketKey;

    overlay.fly(
      fromKey: fromKey,
      toKey: toKey,
      emoji: cat.emoji,
      onLanded: () {
        widget.provider.addClothes(categoryId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cats = widget.provider.categories;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          const Text(
            'Welcome back! 👋',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Schedule your pickup for...',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Quick Add Section
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryLight,
                        AppColors.primary,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Quick Add Clothes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          AddClothesButton(
                            buttonKey: _othersButtonKey,
                            emoji: '👕',
                            label: 'T-Shirts / Pants',
                            sublabel: '+1 Item',
                            onTap: () => _addClothes('others'),
                          ),
                          const SizedBox(width: 12),
                          AddClothesButton(
                            buttonKey: _innersButtonKey,
                            emoji: '🩲',
                            label: 'Inners / Socks',
                            sublabel: '+1 Item',
                            onTap: () => _addClothes('inners'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section label
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Your Baskets',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Baskets
          ...cats.map((cat) {
            final basketKey =
                cat.id == 'inners' ? _innersBasketKey : _othersBasketKey;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: LaundryBasketWidget(
                category: cat,
                basketKey: basketKey,
                onWash: () => widget.provider.markWashed(cat.id),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Tips card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.05),
                  AppColors.accent.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💡 Quick Tips',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _tip('Wash inners every 3 days by hand'),
                _tip('Machine wash others every 7 days'),
                _tip('Watch for red baskets — wash ASAP!'),
                _tip('Tap the clothes icon to track worn items'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tip(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('✓ ',
                style: TextStyle(
                    color: AppColors.safe, fontWeight: FontWeight.w600)),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
}
