class Case {
  final String title;
  final List<String> chips;
  final String status;
  final String date;
  final String id;

  const Case({
    required this.title,
    required this.chips,
    required this.status,
    required this.date,
    required this.id,
  });

  factory Case.fromJson(Map<String, dynamic> json) {
    return Case(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      chips: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
