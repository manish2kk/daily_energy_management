import 'package:flutter/material.dart';

const _lightColors = {
  'exercise': Color(0xFFDCC8FF),
  'create': Color(0xFFC9C9FF),
  'communicate': Color(0xFFC5E7FF),
  'discharge': Color(0xFFFFC7C7),
};

const _darkColors = {
  'exercise': Color(0xFF5AA9D6),
  'create': Color(0xFF3A3A6B),
  'communicate': Color(0xFF2F4A5E),
  'discharge': Color(0xFF6B3A3A),
};

/// Display order: exercise → create → communicate → discharge.
int categoryRank(String category) => {
      'exercise': 0,
      'create': 1,
      'communicate': 2,
      'discharge': 3,
    }[category] ??
    99;

Color categoryColor(String category, {Brightness brightness = Brightness.light}) =>
    (brightness == Brightness.dark ? _darkColors : _lightColors)[category]!;

Color checkedItemColor({Brightness brightness = Brightness.light}) =>
    brightness == Brightness.dark
        ? const Color(0xFF3A3A3A)
        : const Color(0xFFE0E0E0);

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
