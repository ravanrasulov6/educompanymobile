enum ExamType {
  standard,
  admission,
  block,
  contest
}

extension ExamTypeExtension on ExamType {
  String get name {
    switch (this) {
      case ExamType.standard:
        return 'Sadə Test';
      case ExamType.admission:
        return 'Buraxılış İmtahanı';
      case ExamType.block:
        return 'Blok İmtahanı';
      case ExamType.contest:
        return 'Müsabiqə';
    }
  }

  static ExamType fromString(String val) {
    switch (val) {
      case 'admission':
        return ExamType.admission;
      case 'block':
        return ExamType.block;
      case 'contest':
        return ExamType.contest;
      default:
        return ExamType.standard;
    }
  }
}

enum PenaltyRule {
  none,
  twoForOne,
  threeForOne,
  fourForOne,
}

extension PenaltyRuleExtension on PenaltyRule {
  String get name {
    switch (this) {
      case PenaltyRule.none:
        return 'Silinmə yoxdur';
      case PenaltyRule.twoForOne:
        return '2 səhv 1 düzü silir';
      case PenaltyRule.threeForOne:
        return '3 səhv 1 düzü silir';
      case PenaltyRule.fourForOne:
        return '4 səhv 1 düzü silir';
    }
  }

  double get penaltyMultiplier {
    switch (this) {
      case PenaltyRule.none:
        return 0;
      case PenaltyRule.twoForOne:
        return 0.5;
      case PenaltyRule.threeForOne:
        return 0.3333;
      case PenaltyRule.fourForOne:
        return 0.25;
    }
  }

  static PenaltyRule fromString(String val) {
    switch (val) {
      case 'two_for_one':
        return PenaltyRule.twoForOne;
      case 'three_for_one':
        return PenaltyRule.threeForOne;
      case 'four_for_one':
        return PenaltyRule.fourForOne;
      default:
        return PenaltyRule.none;
    }
  }
}

/// Helper class to calculate score based on settings
class ExamScorer {
  static double calculateNetScore({
    required int correctCount,
    required int wrongCount,
    required PenaltyRule penaltyRule,
  }) {
    if (penaltyRule == PenaltyRule.none) return correctCount.toDouble();
    
    double penalty = wrongCount * penaltyRule.penaltyMultiplier;
    double netResult = correctCount - penalty;
    
    return netResult < 0 ? 0 : netResult; 
  }

  static bool hasPassed({
    required double netScore,
    required int totalQuestions,
    required int passingScorePercentage, 
  }) {
    if (totalQuestions == 0) return false;
    double percentage = (netScore / totalQuestions) * 100;
    return percentage >= passingScorePercentage;
  }
}
