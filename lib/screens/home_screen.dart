import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/vision_service.dart';
import '../services/pricing_service.dart';
import '../models/pokemon_card.dart';
import '../widgets/web_safe_image.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  String? _frontImagePath;
  String? _backImagePath;
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _captureImage(bool isFront) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          if (isFront) {
            _frontImagePath = photo.path;
          } else {
            _backImagePath = photo.path;
          }
        });
      }
    } catch (e) {
      _showError('Error capturing image: $e');
    }
  }

  Future<void> _pickImage(bool isFront) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (isFront) {
            _frontImagePath = image.path;
          } else {
            _backImagePath = image.path;
          }
        });
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _analyzeCard() async {
    if (_frontImagePath == null || _backImagePath == null) {
      _showError('Please capture both front and back of the card');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Analyze front
      final frontAnalysis = await VisionService.analyzeCondition(_frontImagePath!);
      
      // Analyze back
      final backAnalysis = await VisionService.analyzeCondition(_backImagePath!);

      // Calculate overall grade (average of front and back)
      final avgScore = (frontAnalysis['score'] + backAnalysis['score']) / 2;
      final overallGrade = _scoreToGrade(avgScore);

      // Estimate value
      final estimatedValue = await PricingService.estimateValue(
        cardName: frontAnalysis['cardName'],
        setName: frontAnalysis['setName'],
        cardNumber: frontAnalysis['cardNumber'],
        rarity: frontAnalysis['rarity'],
        grade: overallGrade,
      );

      // Create card object
      final card = PokemonCard(
        name: frontAnalysis['cardName'],
        setName: frontAnalysis['setName'],
        cardNumber: frontAnalysis['cardNumber'],
        rarity: frontAnalysis['rarity'],
        frontConditionScore: frontAnalysis['score'],
        backConditionScore: backAnalysis['score'],
        frontConditionGrade: frontAnalysis['grade'],
        backConditionGrade: backAnalysis['grade'],
        overallGrade: overallGrade,
        estimatedValue: estimatedValue,
        frontImagePath: _frontImagePath!,
        backImagePath: _backImagePath!,
        frontIssues: List<String>.from(frontAnalysis['issues']),
        backIssues: List<String>.from(backAnalysis['issues']),
      );

      // Navigate to results
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(card: card),
          ),
        );
      }

      // Reset for next card
      setState(() {
        _frontImagePath = null;
        _backImagePath = null;
      });
    } catch (e) {
      _showError('Error analyzing card: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  String _scoreToGrade(double score) {
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showImageOptions(bool isFront) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(color: const Color(0xFFFFCB05), width: 4),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 5),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCB05),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Choose Photo Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3D7DCA),
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCC0000),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white),
                ),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _captureImage(isFront);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D7DCA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.white),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(isFront);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF3D7DCA), // Pokemon Blue
              const Color(0xFF5BA3E8),
              const Color(0xFFF5F5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: _isProcessing
              ? _buildProcessingScreen()
              : _buildMainContent(),
        ),
      ),
    );
  }

  Widget _buildProcessingScreen() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFFFCB05), width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFCC0000),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFCB05).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.catching_pokemon,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Analyzing Card...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D7DCA),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Gotta Grade \'Em All!',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFCC0000),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFCC0000),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFFFCB05), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.catching_pokemon, color: Colors.white, size: 30),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nicky's Pokémon App™",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          'Card Grading Master',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFFFCB05),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFCB05), width: 3),
                  ),
                  child: const Text(
                    '⚡ Capture Both Sides ⚡',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3D7DCA),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),

                // Front image card
                Expanded(
                  child: _buildPokemonImageCard(
                    'FRONT',
                    _frontImagePath,
                    () => _showImageOptions(true),
                    const Color(0xFFCC0000),
                  ),
                ),

                const SizedBox(height: 15),

                // Back image card
                Expanded(
                  child: _buildPokemonImageCard(
                    'BACK',
                    _backImagePath,
                    () => _showImageOptions(false),
                    const Color(0xFF3D7DCA),
                  ),
                ),

                const SizedBox(height: 20),

                // Analyze button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton(
                    onPressed: (_frontImagePath != null && _backImagePath != null)
                        ? _analyzeCard
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCB05),
                      foregroundColor: const Color(0xFF3D7DCA),
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: (_frontImagePath != null && _backImagePath != null)
                              ? const Color(0xFFCC0000)
                              : Colors.grey,
                          width: 4,
                        ),
                      ),
                      elevation: 10,
                      shadowColor: Colors.black45,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'ANALYZE CARD!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPokemonImageCard(
    String label,
    String? imagePath,
    VoidCallback onTap,
    Color accentColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor, width: 4),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 250,
                  child: Stack(
                    children: [
                      WebSafeImage(
                        imagePath: imagePath,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFCB05), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: accentColor, width: 2),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: accentColor,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      accentColor.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_rounded,
                      size: 80,
                      color: accentColor.withOpacity(0.6),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFCB05), width: 2),
                      ),
                      child: Text(
                        'TAP TO ADD $label',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    ),
      ),
    );
  }
}
