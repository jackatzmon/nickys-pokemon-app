import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PokemonCardGraderApp());
}

class PokemonCardGraderApp extends StatelessWidget {
  const PokemonCardGraderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Nicky's Pokémon App™",
      theme: ThemeData(
        primaryColor: const Color(0xFFFFCB05), // Pokemon Yellow
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFCB05),
          primary: const Color(0xFFFFCB05), // Pokemon Yellow
          secondary: const Color(0xFF3D7DCA), // Pokemon Blue
          tertiary: const Color(0xFFCC0000), // Pokemon Red
        ),
        useMaterial3: true,
        fontFamily: 'PokemonSolid',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3D7DCA),
            shadows: [
              Shadow(
                color: Color(0xFFFFCB05),
                offset: Offset(2, 2),
                blurRadius: 0,
              ),
            ],
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3D7DCA),
          ),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCC0000),
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: Colors.black45,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: const BorderSide(color: Color(0xFFFFCB05), width: 3),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 8,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFFFCB05), width: 2),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
