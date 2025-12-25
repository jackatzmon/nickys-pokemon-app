import 'package:flutter/material.dart';
import 'dart:io';
import '../models/pokemon_card.dart';

class ResultScreen extends StatelessWidget {
  final PokemonCard card;

  const ResultScreen({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF3D7DCA),
              const Color(0xFF5BA3E8),
              const Color(0xFFF5F5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFCB05), width: 2),
                        ),
                        child: const Icon(Icons.arrow_back, color: Color(0xFFCC0000)),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCC0000),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: const Color(0xFFFFCB05), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, color: Color(0xFFFFCB05), size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Grading Results',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.star, color: Color(0xFFFFCB05), size: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCardInfo(),
                      const SizedBox(height: 16),
                      _buildOverallGrade(),
                      const SizedBox(height: 16),
                      _buildConditionCard('FRONT', card.frontImagePath, 
                        card.frontConditionGrade, card.frontConditionScore,
                        card.frontIssues, const Color(0xFFCC0000)),
                      const SizedBox(height: 16),
                      _buildConditionCard('BACK', card.backImagePath,
                        card.backConditionGrade, card.backConditionScore,
                        card.backIssues, const Color(0xFF3D7DCA)),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                      const SizedBox(height: 12),
                      _buildDisclaimer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFCB05), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.catching_pokemon, color: const Color(0xFFCC0000), size: 28),
              const SizedBox(width: 10),
              const Text(
                'Card Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D7DCA),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFCC0000),
                  const Color(0xFFFFCB05),
                  const Color(0xFF3D7DCA),
                ],
              ),
            ),
          ),
          _buildInfoRow('Name', card.displayName),
          _buildInfoRow('Set', card.displaySet),
          _buildInfoRow('Number', card.displayNumber),
          if (card.rarity != null) _buildInfoRow('Rarity', card.rarity!),
        ],
      ),
    );
  }

  Widget _buildOverallGrade() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFCB05),
            const Color(0xFFFFD700),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFCC0000), width: 4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFCB05).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: const Color(0xFFCC0000), size: 32),
              const SizedBox(width: 8),
              const Text(
                'OVERALL GRADE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D7DCA),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.star, color: const Color(0xFFCC0000), size: 32),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCC0000), width: 3),
            ),
            child: Text(
              card.overallGrade,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _getGradeColor(
                  (card.frontConditionScore + card.backConditionScore) / 2,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFCC0000),
                  const Color(0xFF3D7DCA),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text(
                    'ESTIMATED VALUE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D7DCA),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.attach_money, color: Color(0xFF2E7D32), size: 32),
                      Text(
                        card.estimatedValue.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionCard(
    String label,
    String imagePath,
    String grade,
    double score,
    List<String> issues,
    Color accentColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(17),
                topRight: Radius.circular(17),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.image, color: accentColor, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  '$label CONDITION',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: accentColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.file(
                      File(imagePath),
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor.withOpacity(0.1),
                        accentColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: accentColor, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          grade,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${score.toStringAsFixed(1)}/10',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (issues.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Issues Detected:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...issues.map((issue) => Padding(
                          padding: const EdgeInsets.only(left: 8, top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, size: 6, color: Colors.orange),
                              const SizedBox(width: 8),
                              Expanded(child: Text(issue)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 24),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No major issues detected',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFCB05),
        foregroundColor: const Color(0xFF3D7DCA),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Color(0xFFCC0000), width: 4),
        ),
        elevation: 10,
        shadowColor: Colors.black45,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.refresh, size: 28),
          const SizedBox(width: 12),
          const Text(
            'GRADE ANOTHER CARD!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF3D7DCA), width: 2),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF3D7DCA), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Automated estimate only. For official grading, submit to PSA, BGS, or CGC.',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF3D7DCA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(double score) {
    if (score >= 9.0) return const Color(0xFF2E7D32); // Green
    if (score >= 7.0) return const Color(0xFF1976D2); // Blue
    if (score >= 5.0) return const Color(0xFFF57C00); // Orange
    return const Color(0xFFD32F2F); // Red
  }
}
