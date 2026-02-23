import 'package:flutter/material.dart';

class AppShadows {
  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x57C6B8D8), 
      offset: Offset(0, 0),
      blurRadius: 4.8,
      spreadRadius: 3,
    ),
  ];

  static List<BoxShadow> containerShadow = [
    const BoxShadow(
      color: Color(0xD3D7C3F1), 
      offset: Offset(0, 2),
      blurRadius: 7,
      spreadRadius: 1,
    ),
  ];

  static List<BoxShadow> elementFocusShadow = [ 
    const BoxShadow(
      color: Color(0x66D7C3F1), // #D7C3F1 con 40% de opacidad (0x66 en Hex)
      offset: Offset(1, 1), // X: 1, Y: 1
      blurRadius: 11, // Blur: 11
      spreadRadius: 3, // Spread: 3
    ),
  ];

  static List<BoxShadow> textButtonPressedShadow = [
    const BoxShadow(
      color: Color(0xFFC6B8D8), 
      offset: Offset(0, 0),
      blurRadius: 4.8,
      spreadRadius: 3,
    ),
  ];

}