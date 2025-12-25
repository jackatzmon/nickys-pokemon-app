class PokemonCard {
  final String? name;
  final String? setName;
  final String? cardNumber;
  final String? rarity;
  final double frontConditionScore;
  final double backConditionScore;
  final String frontConditionGrade;
  final String backConditionGrade;
  final String overallGrade;
  final double estimatedValue;
  final String frontImagePath;
  final String backImagePath;
  final List<String> frontIssues;
  final List<String> backIssues;

  PokemonCard({
    this.name,
    this.setName,
    this.cardNumber,
    this.rarity,
    required this.frontConditionScore,
    required this.backConditionScore,
    required this.frontConditionGrade,
    required this.backConditionGrade,
    required this.overallGrade,
    required this.estimatedValue,
    required this.frontImagePath,
    required this.backImagePath,
    required this.frontIssues,
    required this.backIssues,
  });

  String get displayName => name ?? 'Unknown Card';
  String get displaySet => setName ?? 'Unknown Set';
  String get displayNumber => cardNumber ?? 'N/A';
}
