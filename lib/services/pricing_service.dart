import 'dart:convert';
import 'package:http/http.dart' as http;

class PricingService {
  // Base prices by grade (multipliers of base card value)
  static const Map<String, double> gradeMultipliers = {
    'Gem Mint 10': 2.5,
    'Mint 9': 1.8,
    'Near Mint-Mint 8.5': 1.4,
    'Near Mint 8': 1.0,
    'Excellent 7': 0.6,
    'Excellent-Mint 6': 0.4,
    'Very Good 5': 0.25,
    'Good 4': 0.15,
    'Fair 3': 0.08,
    'Poor 2': 0.05,
    'Poor 1': 0.02,
  };

  static Future<double> estimateValue({
    String? cardName,
    String? setName,
    String? cardNumber,
    String? rarity,
    required String grade,
  }) async {
    // Base value estimation
    double baseValue = 5.0; // Default base value

    // Try to get actual pricing from Pokemon TCG API (free API)
    try {
      final apiValue = await _fetchFromPokemonTCGAPI(cardName, setName, cardNumber);
      if (apiValue > 0) {
        baseValue = apiValue;
      } else {
        // Fallback to heuristic pricing
        baseValue = _estimateBaseValue(cardName, setName, rarity);
      }
    } catch (e) {
      // Use heuristic if API fails
      baseValue = _estimateBaseValue(cardName, setName, rarity);
    }

    // Apply grade multiplier
    final multiplier = gradeMultipliers[grade] ?? 1.0;
    return baseValue * multiplier;
  }

  static Future<double> _fetchFromPokemonTCGAPI(
    String? cardName,
    String? setName,
    String? cardNumber,
  ) async {
    try {
      // Pokemon TCG API is free but you may want to add an API key for higher limits
      // Get one at https://pokemontcg.io/
      String query = '';
      
      if (cardName != null && cardName.isNotEmpty) {
        query = 'name:"$cardName"';
      }
      
      if (setName != null && setName.isNotEmpty && query.isNotEmpty) {
        query += ' set.name:"$setName"';
      }

      if (query.isEmpty) {
        return 0.0;
      }

      final url = Uri.parse('https://api.pokemontcg.io/v2/cards?q=$query');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cards = data['data'] as List;
        
        if (cards.isNotEmpty) {
          final card = cards[0];
          final cardmarket = card['cardmarket'];
          
          if (cardmarket != null && cardmarket['prices'] != null) {
            // Try to get average sell price
            final prices = cardmarket['prices'];
            double price = 0.0;
            
            if (prices['averageSellPrice'] != null) {
              price = (prices['averageSellPrice'] as num).toDouble();
            } else if (prices['trendPrice'] != null) {
              price = (prices['trendPrice'] as num).toDouble();
            }
            
            return price;
          }
        }
      }
    } catch (e) {
      print('Error fetching from Pokemon TCG API: $e');
    }
    
    return 0.0;
  }

  static double _estimateBaseValue(String? cardName, String? setName, String? rarity) {
    double baseValue = 5.0;

    // Adjust based on rarity
    if (rarity != null) {
      final lowerRarity = rarity.toLowerCase();
      
      if (lowerRarity.contains('secret') || lowerRarity.contains('★★★')) {
        baseValue = 150.0;
      } else if (lowerRarity.contains('ultra rare') || lowerRarity.contains('★★')) {
        baseValue = 75.0;
      } else if (lowerRarity.contains('rare holo') || lowerRarity.contains('holo rare')) {
        baseValue = 25.0;
      } else if (lowerRarity.contains('rare') || lowerRarity.contains('★')) {
        baseValue = 10.0;
      } else if (lowerRarity.contains('uncommon')) {
        baseValue = 2.0;
      } else if (lowerRarity.contains('common')) {
        baseValue = 0.50;
      }
    }

    // Adjust based on set (vintage sets are more valuable)
    if (setName != null) {
      final lowerSet = setName.toLowerCase();
      
      if (lowerSet.contains('base set') || lowerSet.contains('1st edition')) {
        baseValue *= 5.0;
      } else if (lowerSet.contains('jungle') || lowerSet.contains('fossil')) {
        baseValue *= 3.0;
      } else if (lowerSet.contains('team rocket') || lowerSet.contains('gym')) {
        baseValue *= 2.5;
      } else if (lowerSet.contains('neo')) {
        baseValue *= 2.0;
      }
    }

    // Popular Pokemon get a boost
    if (cardName != null) {
      final lowerName = cardName.toLowerCase();
      
      if (lowerName.contains('charizard')) {
        baseValue *= 10.0;
      } else if (lowerName.contains('pikachu') || 
                 lowerName.contains('mewtwo') ||
                 lowerName.contains('lugia') ||
                 lowerName.contains('ho-oh')) {
        baseValue *= 3.0;
      } else if (lowerName.contains('blastoise') ||
                 lowerName.contains('venusaur') ||
                 lowerName.contains('gyarados')) {
        baseValue *= 2.0;
      }
    }

    return baseValue;
  }
}
