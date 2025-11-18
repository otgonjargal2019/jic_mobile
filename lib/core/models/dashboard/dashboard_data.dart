import 'package:jic_mob/core/models/case/case.dart';
import 'package:jic_mob/core/models/post/post.dart';

int _asInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

class DashboardCaseSummary {
  final int open;
  final int onHold;
  final int closed;

  const DashboardCaseSummary({
    required this.open,
    required this.onHold,
    required this.closed,
  });

  factory DashboardCaseSummary.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return const DashboardCaseSummary(open: 0, onHold: 0, closed: 0);
    }

    return DashboardCaseSummary(
      open: _asInt(map['OPEN'] ?? map['open']),
      onHold: _asInt(map['ON_HOLD'] ?? map['onHold']),
      closed: _asInt(map['CLOSED'] ?? map['closed']),
    );
  }

  int get total => open + onHold + closed;

  double get resolvedRatio => total == 0 ? 0 : closed / total;
}

class DashboardData {
  final DashboardCaseSummary summary;
  final List<Case> recentCases;
  final List<Post> lastPosts;
  final List<Post> lastResearch;

  const DashboardData({
    required this.summary,
    required this.recentCases,
    this.lastPosts = const [],
    this.lastResearch = const [],
  });

  factory DashboardData.empty() => const DashboardData(
    summary: DashboardCaseSummary(open: 0, onHold: 0, closed: 0),
    recentCases: [],
  );

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final summaryMap = json['caseSummary'] as Map?;
    final recentCaseList = json['recentCases'] as List? ?? const [];
    final lastPostsList = json['lastPosts'] as List? ?? const [];
    final lastResearchsList = json['lastResearchs'] as List? ?? const [];

    return DashboardData(
      summary: DashboardCaseSummary.fromMap(summaryMap),
      recentCases: recentCaseList
          .whereType<Map>()
          .map((e) => Case.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      lastPosts: lastPostsList
          .whereType<Map>()
          .map((e) => Post.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      lastResearch: lastResearchsList
          .whereType<Map>()
          .map((e) => Post.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  DashboardData copyWith({
    DashboardCaseSummary? summary,
    List<Case>? recentCases,
    List<Post>? lastPosts,
    List<Post>? lastResearch,
  }) {
    return DashboardData(
      summary: summary ?? this.summary,
      recentCases: recentCases ?? this.recentCases,
      lastPosts: lastPosts ?? this.lastPosts,
      lastResearch: lastResearch ?? this.lastResearch,
    );
  }
}
