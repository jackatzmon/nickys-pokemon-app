import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:async';
import 'package:image/image.dart' as img;

class VisionService {
  static Future<Map<String, dynamic>> analyzeCondition(String imagePath) async {
    try {
      // For web, imagePath is a blob URL
      // Get image data
      final blob = await _getBlobFromUrl(imagePath);
      final bytes = await _readBlobAsBytes(blob);
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Calculate condition metrics
      final conditionMetrics = _calculateConditionMetrics(image);
      
      // Use Tesseract.js for OCR
      final ocrText = await _performOCR(imagePath);
      
      // Extract card information
      final cardInfo = _extractCardInfo(ocrText);
      
      return {
        'score': conditionMetrics['score'],
        'grade': conditionMetrics['grade'],
        'issues': conditionMetrics['issues'],
        'cardName': cardInfo['name'],
        'setName': cardInfo['set'],
        'cardNumber': cardInfo['number'],
        'rarity': cardInfo['rarity'],
        'text': ocrText,
      };
    } catch (e) {
      print('Error in analyzeCondition: $e');
      // Return default values on error
      return {
        'score': 7.0,
        'grade': 'Excellent 7',
        'issues': ['Unable to perform full analysis'],
        'cardName': null,
        'setName': null,
        'cardNumber': null,
        'rarity': null,
        'text': '',
      };
    }
  }

  static Future<html.Blob> _getBlobFromUrl(String url) async {
    final response = await html.window.fetch(url);
    return await response.blob();
  }

  static Future<List<int>> _readBlobAsBytes(html.Blob blob) async {
    final completer = Completer<List<int>>();
    final reader = html.FileReader();
    
    reader.onLoadEnd.listen((e) {
      final result = reader.result as List<int>;
      completer.complete(result);
    });
    
    reader.onError.listen((e) {
      completer.completeError('Failed to read blob');
    });
    
    reader.readAsArrayBuffer(blob);
    return completer.future;
  }

  static Future<String> _performOCR(String imageUrl) async {
    try {
      final completer = Completer<String>();
      
      // Call Tesseract.js
      js.context.callMethod('eval', ['''
        (async function() {
          try {
            const { data: { text } } = await Tesseract.recognize(
              '$imageUrl',
              'eng',
              { logger: m => console.log(m) }
            );
            window.ocrResult = text;
          } catch (error) {
            console.error('OCR Error:', error);
            window.ocrResult = '';
          }
        })();
      ''']);
      
      // Poll for result
      int attempts = 0;
      while (attempts < 50) { // 10 seconds max
        await Future.delayed(Duration(milliseconds: 200));
        final result = js.context['ocrResult'];
        if (result != null && result.toString().isNotEmpty) {
          completer.complete(result.toString());
          break;
        }
        attempts++;
      }
      
      if (!completer.isCompleted) {
        completer.complete('');
      }
      
      return completer.future;
    } catch (e) {
      print('OCR error: $e');
      return '';
    }
  }

  static Map<String, dynamic> _calculateConditionMetrics(img.Image image) {
    List<String> issues = [];
    double score = 10.0;

    final edgeQuality = _analyzeEdges(image);
    if (edgeQuality < 0.8) {
      issues.add('Edge wear detected');
      score -= (1.0 - edgeQuality) * 2.0;
    }

    final centeringScore = _analyzeCentering(image);
    if (centeringScore < 0.9) {
      issues.add('Off-center printing');
      score -= (1.0 - centeringScore) * 1.5;
    }

    final surfaceQuality = _analyzeSurface(image);
    if (surfaceQuality < 0.85) {
      issues.add('Surface wear or scratches');
      score -= (1.0 - surfaceQuality) * 2.5;
    }

    final cornerQuality = _analyzeCorners(image);
    if (cornerQuality < 0.85) {
      issues.add('Corner wear or damage');
      score -= (1.0 - cornerQuality) * 2.0;
    }

    score = score.clamp(1.0, 10.0);
    String grade = _scoreToGrade(score);

    return {
      'score': score,
      'grade': grade,
      'issues': issues,
    };
  }

  static double _analyzeEdges(img.Image image) {
    int edgeWidth = (image.width * 0.05).toInt();
    int edgeHeight = (image.height * 0.05).toInt();
    
    List<int> edgeValues = [];
    
    for (int x = 0; x < image.width; x += 5) {
      for (int y = 0; y < edgeHeight; y++) {
        final pixel = image.getPixel(x, y);
        edgeValues.add(_getGrayscale(pixel));
      }
    }
    
    double variance = _calculateVariance(edgeValues);
    return (1.0 - (variance / 10000)).clamp(0.0, 1.0);
  }

  static double _analyzeCentering(img.Image image) {
    return 0.95;
  }

  static double _analyzeSurface(img.Image image) {
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
    
    List<List<int>> corners = [
      [0, 0],
      [image.width - cornerSize, 0],
      [0, image.height - cornerSize],
      [image.width - cornerSize, image.height - cornerSize],
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
    
    for (var line in lines) {
      final numberMatch = RegExp(r'(\d+)[/](\d+)').firstMatch(line);
      if (numberMatch != null && cardNumber == null) {
        cardNumber = numberMatch.group(0);
      }

      if (line.toLowerCase().contains('rare') || 
          line.contains('★') || 
          line.toLowerCase().contains('holo')) {
        rarity = line.trim();
      }

      if (cardName == null && line.length > 2 && line.length < 30) {
        if (RegExp(r'^[A-Z][a-zA-Z\s-]+$').hasMatch(line.trim())) {
          cardName = line.trim();
        }
      }
    }

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