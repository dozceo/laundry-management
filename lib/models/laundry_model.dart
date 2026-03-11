import 'dart:convert';

class LaundryCategory {
  final String id;
  final String name;
  final String emoji;
  final String washMethod; // 'manual' or 'machine'
  int washIntervalDays;
  int pileCount;
  DateTime lastWashedDate;

  LaundryCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.washMethod,
    required this.washIntervalDays,
    this.pileCount = 0,
    DateTime? lastWashedDate,
  }) : lastWashedDate = lastWashedDate ?? DateTime.now();

  int get daysSinceWash => DateTime.now().difference(lastWashedDate).inDays;

  int get maxCapacity => washIntervalDays * 3;

  double get fillPercentage =>
      (pileCount / maxCapacity).clamp(0.0, 1.0);

  String get riskLevel {
    final pct = fillPercentage;
    if (pct >= 0.75) return 'critical';
    if (pct >= 0.50) return 'warning';
    return 'safe';
  }

  int get daysUntilWash {
    final next = lastWashedDate.add(Duration(days: washIntervalDays));
    return next.difference(DateTime.now()).inDays;
  }

  void markWashed() {
    lastWashedDate = DateTime.now();
    pileCount = 0;
  }

  void addItem() {
    pileCount++;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'washMethod': washMethod,
        'washIntervalDays': washIntervalDays,
        'pileCount': pileCount,
        'lastWashedDate': lastWashedDate.toIso8601String(),
      };

  factory LaundryCategory.fromJson(Map<String, dynamic> json) => LaundryCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String,
        washMethod: json['washMethod'] as String,
        washIntervalDays: json['washIntervalDays'] as int,
        pileCount: json['pileCount'] as int,
        lastWashedDate: DateTime.parse(json['lastWashedDate'] as String),
      );
}

class AppData {
  List<LaundryCategory> categories;
  bool isDarkMode;

  AppData({required this.categories, this.isDarkMode = false});

  String toJsonString() => jsonEncode({
        'categories': categories.map((c) => c.toJson()).toList(),
        'isDarkMode': isDarkMode,
      });

  factory AppData.fromJsonString(String str) {
    final map = jsonDecode(str) as Map<String, dynamic>;
    return AppData(
      categories: (map['categories'] as List)
          .map((c) => LaundryCategory.fromJson(c as Map<String, dynamic>))
          .toList(),
      isDarkMode: map['isDarkMode'] as bool? ?? false,
    );
  }

  factory AppData.defaults() => AppData(
        categories: [
          LaundryCategory(
            id: 'inners',
            name: 'Inners',
            emoji: '🩲',
            washMethod: 'manual',
            washIntervalDays: 3,
          ),
          LaundryCategory(
            id: 'others',
            name: 'Others',
            emoji: '👕',
            washMethod: 'machine',
            washIntervalDays: 7,
          ),
        ],
      );
}
