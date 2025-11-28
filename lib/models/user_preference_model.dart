class UserPreferences {
  final int? id;
  final String userId;
  final List<String> selectedCategories;
  final DateTime lastUpdated;

  UserPreferences({
    this.id,
    required this.userId,
    required this.selectedCategories,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      id: map['id'] as int?,
      userId: map['userId'] as String,
      selectedCategories: (map['selectedCategories'] as String)
          .split(',')
          .where((cat) => cat.isNotEmpty)
          .toList(),
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'selectedCategories': selectedCategories.join(','),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  UserPreferences copyWith({
    int? id,
    String? userId,
    List<String>? selectedCategories,
    DateTime? lastUpdated,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool isStale() {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    return difference.inHours >= 24;
  }

  @override
  String toString() {
    return 'UserPreferences(id: $id, userId: $userId, categories: $selectedCategories, lastUpdated: $lastUpdated)';
  }
}

class NewsCategories {
  static const String business = 'business';
  static const String entertainment = 'entertainment';
  static const String general = 'general';
  static const String health = 'health';
  static const String science = 'science';
  static const String sports = 'sports';
  static const String technology = 'technology';

  static const List<String> all = [
    business,
    entertainment,
    general,
    health,
    science,
    sports,
    technology,
  ];

  static const Map<String, String> displayNames = {
    business: 'Business',
    entertainment: 'Entertainment',
    general: 'General',
    health: 'Health',
    science: 'Science',
    sports: 'Sports',
    technology: 'Technology',
  };
}