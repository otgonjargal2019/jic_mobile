import 'package:intl/intl.dart';

class Case {
  final String title;
  final String infringementType;
  final String relatedCountries;
  final List<String> chips;
  final String status;
  final String progressStatus;
  final String manager;
  final String date;
  final String id;
  final String number;

  const Case({
    required this.title,
    required this.infringementType,
    required this.relatedCountries,
    required this.chips,
    required this.status,
    required this.progressStatus,
    required this.manager,
    required this.date,
    required this.id,
    required this.number,
  });

  factory Case.fromJson(Map<String, dynamic> json) {
    String nameEn = json['creator']?['nameEn']?.toString() ?? '';
    String nameKr = json['creator']?['nameKr']?.toString() ?? '';
    String name = '';
    if (nameEn.trim().isNotEmpty) {
      name = nameEn;
    } else if (nameKr.trim().isNotEmpty) {
      name = nameKr;
    } else {
      name = '-';
    }

    final assignees = json['assignees'] as List?;
    final count = assignees?.length ?? 0;

    final manager = name + (count > 0 ? ' 외 ${count}명' : '');

    final dateTime = DateTime.parse(json['investigationDate']?.toString() ?? '');
    return Case(
      id: json['id']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      title: json['caseName']?.toString() ?? '',
      manager: manager,
      infringementType: json['infringementType']?.toString() ?? '',
      relatedCountries: json['relatedCountries']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      progressStatus: json['latestRecord']?['progressStatus']?.toString() ?? '',
      date: DateFormat('yyyy.MM.dd').format(dateTime),
      chips: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
