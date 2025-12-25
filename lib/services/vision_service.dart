import 'dart:async';

// Simplified web-compatible vision service
class VisionService {
  static Future<Map<String, dynamic>> analyzeCondition(String imagePath) async {
    try {
      // Simplified analysis for web version
      // Returns default good condition scores
      
      final score = 8.5;
      final grade = _scoreToGrade(score);
      
      return {
        'score': score,
        'grade': grade,
        'issues': <String>[],
        'cardName': 'Pokemon Card',
        'setName': 'Modern Set',
        'cardNumber': null,
        'rarity': 'Rare',
        'text': '',
      };
    } catch (e) {
      print('Error in analyzeCondition: $e');
      return {
        'score': 7.0,
        'grade': 'Excellent 7',
        'issues': ['Basic analysis complete'],
        'cardName': 'Pokemon Card',
        'setName': null,
        'cardNumber': null,
        'rarity': null,
        'text': '',
      };
    }
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