# Pokemon Font Installation

The app uses Pokemon-style fonts for authentic branding. Since we can't distribute the official Pokemon fonts due to copyright, you have two options:

## Option 1: Use Similar Free Fonts (Recommended)

Download these free Pokemon-style fonts:

1. **Pokemon Solid** 
   - Download from: https://www.dafont.com/pokemon.font
   - Or search "Pokemon Solid font free download"

2. **Pokemon Hollow**
   - Same source as above
   - Alternative name: "Pokemon GB" or "Press Start 2P"

## Option 2: Use System Fonts (Quick Start)

If you want to run the app immediately without custom fonts:

1. Open `pubspec.yaml`
2. Comment out or remove the fonts section:
```yaml
  # fonts:
  #   - family: PokemonSolid
  #     fonts:
  #       - asset: assets/fonts/pokemon_solid.ttf
  #   - family: PokemonHollow
  #     fonts:
  #       - asset: assets/fonts/pokemon_hollow.ttf
```

3. Open `lib/main.dart`
4. Remove or comment out this line:
```dart
fontFamily: 'PokemonSolid',
```

The app will use system fonts and still look great!

## Installing Custom Fonts

1. Download the .ttf font files
2. Rename them to:
   - `pokemon_solid.ttf`
   - `pokemon_hollow.ttf`
3. Place them in `assets/fonts/` directory
4. Run `flutter pub get`
5. Run the app!

## Alternative Pokemon-Style Fonts

If you can't find the exact fonts, these alternatives work well:
- **Press Start 2P** (retro gaming font)
- **VT323** (terminal style)
- **Bungee** (bold display font)

All available free at https://fonts.google.com
