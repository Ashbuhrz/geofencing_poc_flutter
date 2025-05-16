#!/bin/bash

# Rename refactored files to replace the original files
mv lib/screens/home_screen_refactored.dart lib/screens/home_screen.dart
mv lib/screens/event_list_screen_refactored.dart lib/screens/event_list_screen.dart

# Update imports in main.dart
sed -i '' 's/home_screen_refactored/home_screen/g' lib/main.dart

echo "Files renamed successfully!"
