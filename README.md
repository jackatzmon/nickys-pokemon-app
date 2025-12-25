# Nicky's Pokémon App™

A beautifully designed Flutter mobile app inspired by official Pokémon aesthetics that uses computer vision to grade Pokémon cards and estimate their value based on condition.

## ⚡ Features

- 📸 **Camera Integration** - Capture front and back of cards
- 🔍 **Automated Condition Analysis** - Using Google ML Kit
- 📊 **Professional Grading** - PSA-style 1-10 scale
- 💰 **Price Estimation** - Based on card and condition
- 🎨 **Authentic Pokémon Design** - Official color scheme and styling
- 🎯 **Card Identification** - Extracts name, set, number, and rarity
- ⚡ **Beautiful UI** - Japanese game design aesthetics

## 🎨 Design Features

The app features authentic Pokémon branding with:
- **Official Color Scheme**: Pokémon Yellow (#FFCB05), Blue (#3D7DCA), and Red (#CC0000)
- **Pokémon-Style Typography**: Retro gaming fonts
- **Gradient Backgrounds**: Blue to white transitions
- **Animated Elements**: Pulsing Pokéball during analysis
- **Bold Borders**: Yellow and red accent borders throughout
- **Professional Cards**: Elevated, shadowed card designs

## 📱 Screenshots

The app includes:
- Vibrant gradient home screen with "Nicky's Pokémon App™" branding
- Interactive card capture areas with color-coded borders (Red for FRONT, Blue for BACK)
- Animated processing screen with pulsing Pokéball
- Detailed results with gold-accented grade display
- Color-coded condition indicators

## 🎮 How It Works

1. **Capture Images**: Take photos of both the front and back of your Pokemon card
2. **Image Analysis**: The app analyzes:
   - Edge wear and whitening
   - Corner condition
   - Surface scratches and damage
   - Centering quality
3. **Card Identification**: Extracts card information using OCR:
   - Card name
   - Set name
   - Card number
   - Rarity
4. **Grading**: Assigns a grade from 1-10 (Poor to Gem Mint)
5. **Price Estimation**: Calculates estimated value using:
   - Pokemon TCG API for market prices (when available)
   - Heuristic pricing based on rarity, set, and Pokemon popularity
   - Grade multipliers

## Installation

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio or Xcode (for mobile development)
- A physical device or emulator with camera support

### Setup

1. Clone or download this project

2. Install dependencies:
```bash
cd pokemon_card_grader
flutter pub get
```

3. **Font Setup** (see FONTS.md for details):
   - Option A: Download Pokemon-style fonts and place in `assets/fonts/`
   - Option B: Comment out font references in pubspec.yaml and main.dart to use system fonts
   - The app works great with either option!

4. **Google Vision API Setup** (Optional - for enhanced OCR):
   
   The app uses Google ML Kit which works on-device without API keys. However, for enhanced functionality with Google Cloud Vision API:
   
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project
   - Enable the Cloud Vision API
   - Download credentials JSON file
   - Add to your project (platform-specific setup)

4. **Pokemon TCG API** (Optional):
   
   The app uses the free Pokemon TCG API (https://pokemontcg.io/). For higher rate limits:
   - Sign up at https://pokemontcg.io/
   - Get your API key
   - Add it to `lib/services/pricing_service.dart`

### Run the App

```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For a specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

## Usage

1. **Launch the app** on your device
2. **Tap "Front"** to capture or select the front image of your card
3. **Tap "Back"** to capture or select the back image
4. **Press "Analyze Card"** to process the images
5. **View Results**: See the grade, estimated value, and detailed condition report

## Grading Scale

- **Gem Mint 10**: Perfect card (9.5-10)
- **Mint 9**: Near perfect (9.0-9.4)
- **Near Mint-Mint 8.5**: Very minor flaws (8.5-8.9)
- **Near Mint 8**: Minor flaws (8.0-8.4)
- **Excellent 7**: Light wear (7.0-7.9)
- **Very Good 5-6**: Moderate wear (5.0-6.9)
- **Good 4**: Heavy wear (4.0-4.9)
- **Poor 1-3**: Damaged (1.0-3.9)

## Condition Analysis

The app checks for:

- **Edge Wear**: Whitening or fraying on card edges
- **Corner Damage**: Bent, rounded, or damaged corners
- **Surface Issues**: Scratches, scuffs, or print defects
- **Centering**: How well the image is centered on the card

## Price Estimation

Pricing is determined by:

1. **Base Value**: 
   - API lookup (Pokemon TCG API) when available
   - Heuristic estimation based on rarity and set
   
2. **Rarity Multipliers**:
   - Secret Rare: ~$150 base
   - Ultra Rare: ~$75 base
   - Rare Holo: ~$25 base
   - Rare: ~$10 base
   - Uncommon: ~$2 base
   - Common: ~$0.50 base

3. **Set Multipliers**:
   - Base Set/1st Edition: 5x
   - Vintage sets (Jungle, Fossil): 2-3x
   - Modern sets: 1x

4. **Pokemon Popularity**:
   - Charizard: 10x
   - Popular legendaries: 3x
   - Fan favorites: 2x

5. **Grade Multipliers**:
   - Gem Mint 10: 2.5x
   - Mint 9: 1.8x
   - Near Mint 8: 1.0x
   - Lower grades: 0.02x - 0.6x

## Limitations

- This is an **automated estimate** - not a substitute for professional grading
- Camera quality and lighting affect accuracy
- For official grading, submit to PSA, BGS, or CGC
- API pricing may not be available for all cards
- Works best with standard-sized Pokemon TCG cards

## Future Enhancements

- [ ] Support for other card games (MTG, Yu-Gi-Oh!, etc.)
- [ ] Save grading history
- [ ] Export reports as PDF
- [ ] Batch grading multiple cards
- [ ] Integration with more pricing APIs
- [ ] Machine learning model for improved accuracy
- [ ] Card collection management

## Dependencies

- `camera`: Camera functionality
- `image_picker`: Gallery image selection
- `google_ml_kit`: On-device ML for text recognition
- `http`: API requests
- `image`: Image processing and analysis
- `path_provider`: File system access

## Troubleshooting

### Camera not working
- Ensure camera permissions are granted in device settings
- Check that camera is not in use by another app

### Poor OCR results
- Ensure good lighting when capturing images
- Hold camera steady and avoid blur
- Capture card flat against a contrasting background

### Pricing seems off
- Pricing is an estimate based on available data
- Rare/vintage cards may need manual price lookup
- Market prices fluctuate frequently

## License

This project is for educational purposes. Pokemon and related trademarks are property of Nintendo/Game Freak/Creatures Inc.

## Contributing

Feel free to fork and submit pull requests for improvements!

## Credits

- Google ML Kit for text recognition
- Pokemon TCG API for pricing data
- Flutter team for the amazing framework
