import 'package:flutter/material.dart';

const _lightColors = {
  'exercise': Color(0xFFDCC8FF),
  'create': Color(0xFFC9C9FF),
  'communicate': Color(0xFFC5E7FF),
  'discharge': Color(0xFFFFC7C7),
};

const _darkColors = {
  'exercise': Color(0xFF4A3A6B),
  'create': Color(0xFF3A3A6B),
  'communicate': Color(0xFF2F4A5E),
  'discharge': Color(0xFF6B3A3A),
};

Color categoryColor(String category, {Brightness brightness = Brightness.light}) =>
    (brightness == Brightness.dark ? _darkColors : _lightColors)[category]!;

Color checkedItemColor({Brightness brightness = Brightness.light}) =>
    brightness == Brightness.dark
        ? const Color(0xFF1B5E20)
        : const Color(0xFFC8E6C9);

Color checklistTitleColor({Brightness brightness = Brightness.light}) =>
    brightness == Brightness.dark ? Colors.white : Colors.black87;

Color checklistMutedColor({Brightness brightness = Brightness.light}) =>
    brightness == Brightness.dark ? Colors.white70 : Colors.black54;

String categoryLabel(String category) => {
      'exercise': 'Exercise',
      'create': 'Create / Build',
      'communicate': 'Communicate',
      'discharge': 'Discharge',
    }[category]!;
