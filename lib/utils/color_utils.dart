import 'package:flutter/material.dart';

// Helper function to convert a Color object to a hex string (e.g., #AARRGGBB)
String colorToHex(Color color, {bool leadingHashSign = true}) {
  return '${leadingHashSign ? '#' : ''}'
      '${color.alpha.toRadixString(16).padLeft(2, '0')}'
      '${color.red.toRadixString(16).padLeft(2, '0')}'
      '${color.green.toRadixString(16).padLeft(2, '0')}'
      '${color.blue.toRadixString(16).padLeft(2, '0')}';
}

// Helper function to convert a hex string to a Color object
// Provide a defaultColor in case the hex string is null, empty, or invalid
Color hexToColor(String? hexColorString, Color defaultColor) {
  if (hexColorString == null || hexColorString.isEmpty) {
    return defaultColor;
  }
  try {
    final buffer = StringBuffer();
    // Ensure 8 digits for ARGB. If only 6 (RGB), prepend 'ff' for full opacity.
    if (hexColorString.length == 6 || hexColorString.length == 7) {
      buffer.write('ff'); // Add alpha if it's missing (assuming full opacity)
    }
    buffer.write(hexColorString.replaceFirst('#', '')); // Remove '#' if present
    return Color(int.parse(buffer.toString(), radix: 16));
  } catch (e) {
    print('Error parsing hex color: $hexColorString. Error: $e');
    return defaultColor; // Fallback to default color on error
  }
}
