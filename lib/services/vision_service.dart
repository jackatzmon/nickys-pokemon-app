import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;

class VisionService {
  // Analyze image quality and detect defects
  static Future<Map<String, dynamic>> analyzeCondition(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer();
    
    try {
      // Get text from image for card identification
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      // Analyze image for condition
      final File imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Calculate condition metrics
      final conditionMetrics = _calculateConditionMetrics(image);
      
      // Extract card information from text
      final cardInfo = _extractCardInfo(recognizedText.text);
      
      return {
        'score': conditionMetrics['score'],
        'grade': conditionMetrics['grade'],
        'issues': conditionMetrics['issues'],
        'cardName': cardInfo['name'],
        'setName': cardInfo['set'],
        'cardNumber': cardInfo['number'],
        'rarity': cardInfo['rarity'],
        'text': recognizedText.text,
      };
    } finally {
      textRecognizer.close();
    }
  }

  static Map<String, dynamic> _calculateConditionMetrics(img.Image image) {
    List<String> issues = [];
    double score = 10.0;

    // Check for edge wear (detect brightness variations at edges)
    final edgeQuality = _analyzeEdges(image);
    if (edgeQuality < 0.8) {
      issues.add('Edge wear detected');
      score -= (1.0 - edgeQuality) * 2.0;
    }

    // Check for centering
    final centeringScore = _analyzeCentering(image);
    if (centeringScore < 0.9) {
      issues.add('Off-center printing');
      score -= (1.0 - centeringScore) * 1.5;
    }

    // Check for scratches/surface issues (detect noise)
    final surfaceQuality = _analyzeSurface(image);
    if (surfaceQuality < 0.85) {
      issues.add('Surface wear or scratches');
      score -= (1.0 - surfaceQuality) * 2.5;
    }

    // Check corners (detect damage in corner regions)
    final cornerQuality = _analyzeCorners(image);
    if (cornerQuality < 0.85) {
      issues.add('Corner wear or damage');
      score -= (1.0 - cornerQuality) * 2.0;
    }

    // Ensure score doesn't go below 1.0
    score = score.clamp(1.0, 10.0);

    String grade = _scoreToGrade(score);

    return {
      'score': score,
      'grade': grade,
      'issues': issues,
    };
  }

  static double _analyzeEdges(img.Image image) {
    // Sample edge pixels and check for consistency
    int edgeWidth = (image.width * 0.05).toInt();
    int edgeHeight = (image.height * 0.05).toInt();
    
    List<int> edgeValues = [];
    
    // Top edge
    for (int x = 0; x < image.width; x += 5) {
      for (int y = 0; y < edgeHeight; y++) {
        final pixel = image.getPixel(x, y);
        edgeValues.add(_getGrayscale(pixel));
      }
    }
    
    // Calculate variance (high variance = wear/damage)
    double variance = _calculateVariance(edgeValues);
    return (1.0 - (variance / 10000)).clamp(0.0, 1.0);
  }

  static double _analyzeCentering(img.Image image) {
    // Simplified centering check - would need card border detection for accuracy
    // For now, return high score as placeholder
    return 0.95;
  }

  static double _analyzeSurface(img.Image image) {
    // Sample center region and check for noise/inconsistencies
    int centerX = image.width ~/ 2;
    int centerY = image.height ~/ 2;
    int sampleSize = 100;
    
    List<int> surfaceValues = [];
    
    for (int x = centerX - sampleSize; x < centerX + sampleSize; x += 5) {
      for (int y = centerY - sampleSize; y < centerY + sampleSize; y += 5) {
        if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
          final pixel = image.getPixel(x, y);
          surfaceValues.add(_getGrayscale(pixel));
        }
      }
    }
    
    double variance = _calculateVariance(surfaceValues);
    return (1.0 - (variance / 15000)).clamp(0.0, 1.0);
  }

  static double _analyzeCorners(img.Image image) {
    int cornerSize = 50;
    List<double> cornerScores = [];
    
    // Check all four corners
    List<List<int>> corners = [
      [0, 0], // Top-left
      [image.width - cornerSize, 0], // Top-right
      [0, image.height - cornerSize], // Bottom-left
      [image.width - cornerSize, image.height - cornerSize], // Bottom-right
    ];
    
    for (var corner in corners) {
      List<int> cornerValues = [];
      for (int x = corner[0]; x < corner[0] + cornerSize && x < image.width; x += 3) {
        for (int y = corner[1]; y < corner[1] + cornerSize && y < image.height; y += 3) {
          final pixel = image.getPixel(x, y);
          cornerValues.add(_getGrayscale(pixel));
        }
      }
      double variance = _calculateVariance(cornerValues);
      cornerScores.add((1.0 - (variance / 12000)).clamp(0.0, 1.0));
    }
    
    return cornerScores.reduce((a, b) => a + b) / cornerScores.length;
  }

  static int _getGrayscale(img.Pixel pixel) {
    int r = pixel.r.toInt();
    int g = pixel.g.toInt();
    int b = pixel.b.toInt();
    return ((r + g + b) / 3).round();
  }

  static double _calculateVariance(List<int> values) {
    if (values.isEmpty) return 0.0;
    
    double mean = values.reduce((a, b) => a + b) / values.length;
    double sumSquaredDiff = values.fold(0.0, (sum, val) => sum + ((val - mean) * (val - mean)));
    return sumSquaredDiff / values.length;
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

  static Map<String, String?> _extractCardInfo(String text) {
    String? cardName;
    String? setName;
    String? cardNumber;
    String? rarity;

    final lines = text.split('\n');
    
    // Look for common Pokemon card patterns
    for (var line in lines) {
      // Card numbers usually in format like "025/165" or "#25"
      final numberMatch = RegExp(r'(\d+)[/](\d+)').firstMatch(line);
      if (numberMatch != null && cardNumber == null) {
        cardNumber = numberMatch.group(0);
      }

      // Rarity symbols or text
      if (line.toLowerCase().contains('rare') || 
          line.contains('★') || 
          line.toLowerCase().contains('holo')) {
        rarity = line.trim();
      }

      // Pokemon names are often at the top (capitalized words)
      if (cardName == null && line.length > 2 && line.length < 30) {
        if (RegExp(r'^[A-Z][a-zA-Z\s-]+$').hasMatch(line.trim())) {
          cardName = line.trim();
        }
      }
    }

    // Try to identify set from text patterns
    final commonSets = ['Base Set', 'Jungle', 'Fossil', 'Team Rocket', 'Gym', 
                        'Neo', 'Legendary', 'Expedition', 'Sword & Shield', 
                        'Sun & Moon', 'XY', 'Black & White'];
    
    for (var set in commonSets) {
      if (text.toLowerCase().contains(set.toLowerCase())) {
        setName = set;
        break;
      }
    }

    return {
      'name': cardName,
      'set': setName,
      'number': cardNumber,
      'rarity': rarity,
    };
  }
}
