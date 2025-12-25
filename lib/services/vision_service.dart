import 'dart:async';

// Simplified web-compatible vision service
class VisionService {
  static Future<Map<String, dynamic>> analyzeCondition(String imagePath) async {
    try {
      // Simulate realistic grading with variation
      final random = DateTime.now().millisecondsSinceEpoch % 100;
      final conditionScore = 7.0 + (random / 100 * 2.5);
      final grade = _scoreToGrade(conditionScore);
      final issues = _detectIssues(conditionScore);
      
      return {
        'score': conditionScore,
        'grade': grade,
        'issues': issues,
        'cardName': 'Pikachu',
        'setName': 'Base Set',
        'cardNumber': '025/102',
        'rarity': 'Rare Holo',
        'text': '',
      };
    } catch (e) {
      print('Error in analyzeCondition: $e');
      return {
        'score': 8.0,
        'grade': 'Near Mint 8',
        'issues': [],
        'cardName': 'Pokemon Card',
        'setName': 'Modern Set',
        'cardNumber': null,
        'rarity': 'Rare',
        'text': '',
      };
    }
  }

  static List<String> _detectIssues(double score) {
    List<String> issues = [];
    
    if (score < 9.5) {
      issues.add('Minor edge wear detected');
    }
    if (score < 9.0) {
      issues.add('Slight corner wear');
    }
    if (score < 8.0) {
      issues.add('Surface scratches visible');
    }
    if (score < 7.0) {
      issues.add('Centering issues');
    }
    
    return issues;
  }

  static String _scoreToGrade(double score) {
    if (score >= 9.5) return 'Gem Mint 10';
    if (score >= 9.0) return 'Mint 9';
    if (score >= 8.5) return 'Near Mint-Mint 8.5';
    if (score >= 8.0) return 'Near Mint 8';
    if (score >= 7.0) return 'Excellent 7';
    if (score >= 6.0) return 'Excellent-Mint 6';
    if (score >= 5.0) return 'Very Good 5';
    if (score >= 4.0) return 'Good 4';
    if (score >= 3.0) return 'Fair 3';
    if (score >= 2.0) return 'Poor 2';
    return 'Poor 1';
  }
}