// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class AppColors {
  static final brand = _BrandColors();
  static final red = _RedColors();
  static final orange = _OrangeColors();
  static final yellow = _YellowColors();
  static final green = _GreenColors();
  static final blue = _BlueColors();
  static final pink = _PinkColors();
  static final gray = _GrayColors();
  static final semantics = Semantics();
}

class _BrandColors {
  _BrandColors();

  final Color c50 = const Color(0xFFF5F2FA);
  final Color c100 = const Color(0xFFE9E3F4);
  final Color c200 = const Color(0xFFD3C6E9);
  final Color c300 = const Color(0xFFBFAADE);
  final Color c400 = const Color(0xFFAD92D4);
  final Color c500 = const Color(0xFF9975C8);
  final Color c600 = const Color(0xFF8254B7);
  final Color c700 = const Color(0xFF603D88);
  final Color c800 = const Color(0xFF42285F);
  final Color c900 = const Color(0xFF261539);
  final Color c950 = const Color(0xFF1A0D28);
}

class _RedColors {
  _RedColors();

  final Color c50 = const Color(0xFFFEEDEC);
  final Color c100 = const Color(0xFFFDDEDD);
  final Color c200 = const Color(0xFFFCBCBA);
  final Color c300 = const Color(0xFFFB9893);
  final Color c400 = const Color(0xFFFA6F66);
  final Color c500 = const Color(0xFFF63A1E);
  final Color c600 = const Color(0xFFC52D16);
  final Color c700 = const Color(0xFF961F0E);
  final Color c800 = const Color(0xFF691307);
  final Color c900 = const Color(0xFF400802);
  final Color c950 = const Color(0xFF290301);
}

class _OrangeColors {
  _OrangeColors();

  final Color c50 = const Color(0xFFFFF1EA);
  final Color c100 = const Color(0xFFFFE3D3);
  final Color c200 = const Color(0xFFFFC299);
  final Color c300 = const Color(0xFFFFA242);
  final Color c400 = const Color(0xFFDF8600);
  final Color c500 = const Color(0xFFB76D00);
  final Color c600 = const Color(0xFF945700);
  final Color c700 = const Color(0xFF6F4000);
  final Color c800 = const Color(0xFF4C2B00);
  final Color c900 = const Color(0xFF2F1800);
  final Color c950 = const Color(0xFF1D0D00);
}

class _YellowColors {
  _YellowColors();

  final Color c50 = const Color(0xFFFFFDED);
  final Color c100 = const Color(0xFFFEFBD9);
  final Color c200 = const Color(0xFFFEF9C3);
  final Color c300 = const Color(0xFFFDF489);
  final Color c400 = const Color(0xFFF9EF5E);
  final Color c500 = const Color(0xFFF6EC5D);
  final Color c600 = const Color(0xFFBEB746);
  final Color c700 = const Color(0xFF8C8631);
  final Color c800 = const Color(0xFF5D591E);
  final Color c900 = const Color(0xFF2F2D0B);
  final Color c950 = const Color(0xFF1C1A04);
}

class _GreenColors {
  _GreenColors();

  final Color c50 = const Color(0xFFDCFFE9);
  final Color c100 = const Color(0xFFA1FECA);
  final Color c200 = const Color(0xFF2AF8A0);
  final Color c300 = const Color(0xFF25E292);
  final Color c400 = const Color(0xFF21CF85);
  final Color c500 = const Color(0xFF1DBB78);
  final Color c600 = const Color(0xFF15935E);
  final Color c700 = const Color(0xFF0C6C43);
  final Color c800 = const Color(0xFF064A2D);
  final Color c900 = const Color(0xFF022816);
  final Color c950 = const Color(0xFF011A0D);
}

class _BlueColors {
  _BlueColors();

  final Color c50 = const Color(0xFFEFF4FF);
  final Color c100 = const Color(0xFFD8E8FE);
  final Color c200 = const Color(0xFFB8CFFD);
  final Color c300 = const Color(0xFF93BAFD);
  final Color c400 = const Color(0xFF66A5FC);
  final Color c500 = const Color(0xFF1D8EF5);
  final Color c600 = const Color(0xFF1571C5);
  final Color c700 = const Color(0xFF0D5494);
  final Color c800 = const Color(0xFF063866);
  final Color c900 = const Color(0xFF02203F);
  final Color c950 = const Color(0xFF01142A);
}

class _PinkColors {
  _PinkColors();

  final Color c50 = const Color(0xFFFEF0F8);
  final Color c100 = const Color(0xFFFDE4F2);
  final Color c200 = const Color(0xFFFBC5E5);
  final Color c300 = const Color(0xFFF9A8DA);
  final Color c400 = const Color(0xFFF784CE);
  final Color c500 = const Color(0xFFF55DC5);
  final Color c600 = const Color(0xFFD42BA5);
  final Color c700 = const Color(0xFFA21E7D);
  final Color c800 = const Color(0xFF6E1155);
  final Color c900 = const Color(0xFF430732);
  final Color c950 = const Color(0xFF2B031F);
}

class _GrayColors {
  _GrayColors();

  final Color white = const Color(0xFFFFFFFF);
  final Color c50 = const Color(0xFFFCFCFC);
  final Color c100 = const Color(0xFFF6F6F7);
  final Color c200 = const Color(0xFFEEEEEF);
  final Color c300 = const Color(0xFFE6E5E7);
  final Color c400 = const Color(0xFFDDDCDF);
  final Color c500 = const Color(0xFFD5D4D7);
  final Color c600 = const Color(0xFFA7A5AB);
  final Color c700 = const Color(0xFF7B7882);
  final Color c800 = const Color(0xFF514F57);
  final Color c900 = const Color(0xFF2B292E);
  final Color c950 = const Color(0xFF1A191C);
}

class Semantics {
  Semantics();
  final _Text text = _Text();
  final _Surface surface = _Surface();
  final _Border border = _Border();
}

class _Text {
  final Color heading = AppColors.gray.c950;
  final Color body = AppColors.gray.c900;
  final Color secondary = AppColors.gray.c600;
  final Color action = AppColors.brand.c500;
  final Color actionPressed = AppColors.brand.c600;
  final Color information = AppColors.blue.c500;
  final Color success = AppColors.green.c500;
  final Color warning = AppColors.orange.c400;
  final Color error = AppColors.red.c500;
  final Color onAction = AppColors.gray.white;
  final Color onDisabled = AppColors.gray.c700;
}

class _Surface {
  final Color page = AppColors.brand.c50;
  final Color primary = AppColors.gray.white;
  final Color disabled = AppColors.brand.c100;
  final Color information = AppColors.blue.c100;
  final Color success = AppColors.green.c50;
  final Color warning = AppColors.orange.c50;
  final Color error = AppColors.red.c50;
  final Color action = AppColors.brand.c500;
  final Color actionPressed = AppColors.brand.c600;
  final Color secondaryAction = AppColors.brand.c200;
  final Color secondaryActionPressed = AppColors.brand.c300;
  final Color glassFill = const Color.fromARGB(179, 255, 255, 255);
}

class _Border {
  final Color primary = AppColors.gray.c300;
  final Color secondary = AppColors.brand.c500;
  final Color information = AppColors.blue.c400;
  final Color success = AppColors.green.c400;
  final Color warning = AppColors.orange.c300;
  final Color error = AppColors.red.c400;
  final Color disabled = AppColors.brand.c200;
  final Color action = AppColors.brand.c500;
  final Color actionPressed = AppColors.brand.c600;
}
