class Achievement {
  final String id;
  final String title;
  final DateTime receivedAt;

  Achievement({required this.id, required this.title, required this.receivedAt});

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'receivedAt': receivedAt.toIso8601String(),
  };

  factory Achievement.fromMap(Map<String, dynamic> map) => Achievement(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    receivedAt: DateTime.parse(map['receivedAt'] ?? DateTime.now().toIso8601String()),
  );
} 