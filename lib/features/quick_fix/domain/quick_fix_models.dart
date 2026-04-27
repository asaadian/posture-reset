// lib/features/quick_fix/domain/quick_fix_models.dart

import '../../sessions/domain/session_models.dart';

enum QuickFixActionType {
  recommendationShown,
  viewDetail,
  startSession;

  String get dbValue {
    switch (this) {
      case QuickFixActionType.recommendationShown:
        return 'recommendationShown';
      case QuickFixActionType.viewDetail:
        return 'viewDetail';
      case QuickFixActionType.startSession:
        return 'startSession';
    }
  }
}

class QuickFixSignal {
  const QuickFixSignal({
    required this.iconName,
    required this.labelKey,
    required this.labelFallback,
  });

  final String iconName;
  final String labelKey;
  final String labelFallback;
}

class QuickFixRecommendation {
  const QuickFixRecommendation({
    required this.session,
    required this.score,
    required this.reasoningTitleKey,
    required this.reasoningTitleFallback,
    required this.reasoningBodyKey,
    required this.reasoningBodyFallback,
    required this.signals,
  });

  final SessionSummary session;
  final double score;
  final String reasoningTitleKey;
  final String reasoningTitleFallback;
  final String reasoningBodyKey;
  final String reasoningBodyFallback;
  final List<QuickFixSignal> signals;
}