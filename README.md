# GeoAttendance

A Flutter application for geofence-based attendance tracking.

## Project Structure

The project follows a clean architecture pattern with the following structure:

```
lib/
├── core/                  # Core utilities and constants
│   ├── constants/         # App-wide constants
│   └── utils/             # Utility functions
├── models/                # Data models
├── screens/               # UI screens
├── services/              # Business logic and services
├── theme/                 # Theming system
│   ├── app_colors.dart    # Color palette
│   ├── app_dimensions.dart # Spacing and sizing
│   ├── app_text_styles.dart # Typography
│   ├── app_theme.dart     # Theme data
│   └── theme.dart         # Barrel file for exports
└── widgets/               # Reusable UI components
```

## Theming System

The application uses a comprehensive theming system for a consistent and professional look:

### Colors

The color system is defined in `lib/theme/app_colors.dart` and includes:

- Primary colors (dark blue, medium blue, light blue)
- Secondary/accent colors (amber variants)
- Neutral colors (black, grays, white)
- Semantic colors (success, error, warning, info)
- Background colors

### Typography

Typography is defined in `lib/theme/app_text_styles.dart` with consistent text styles for:

- Headings (h1-h4)
- Body text (large, medium, small)
- Button text
- Captions and labels
- Status text

### Dimensions

Standardized spacing and sizing in `lib/theme/app_dimensions.dart` includes:

- Padding and margin values
- Border radius values
- Elevation values
- Icon sizes
- Button and input field heights

### Theme Data

The `lib/theme/app_theme.dart` file provides complete ThemeData objects for both light and dark themes, ensuring consistent styling across the application.

## Getting Started

1. Ensure Flutter is installed on your machine
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the application

## Features

- Geofence-based attendance tracking
- Check-in/check-out functionality
- Break time tracking
- Activity history
- Configurable geofence settings
