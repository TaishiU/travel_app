import 'package:flutter/material.dart';

/// アプリで使用する色一覧。
abstract interface class AppColor {
  /// プライマリーの 01 の赤色。
  static const Color primary01 = Color(0xFFFF3159);

  /// プライマリーの 02 の青色。
  static const Color primary02 = Color(0xFF3F9AD1);

  /// プライマリーの 03 の黒色。
  static const Color primary03 = Color(0xFF111111);

  /// セカンダリーの 01 のピンク色。
  static const Color secondary01 = Color(0xFFFE8D8B);

  /// セカンダリーの 02 のオレンジ色。
  static const Color secondary02 = Color(0xFFECC86F);

  /// セカンダリーの 03 の黄色。
  static const Color secondary03 = Color(0xFFF8D91C);

  /// セカンダリーの 04 のベージュ色。
  static const Color secondary04 = Color(0xFFC4AF66);

  /// セカンダリーの 05 の緑色。
  static const Color secondary05 = Color(0xFF3EC215);

  /// セカンダリーの 06 の赤色。
  static const Color secondary06 = Color(0xFFFA6A6A);

  /// セカンダリーの 07 の黄色。
  static const Color secondary07 = Color(0xFFF1B803);

  /// ターシャリーの 01 の青色。
  static const Color tertiary01 = Color(0xFF0C9EF7);

  /// ターシャリーの 02 の緑色。
  static const Color tertiary02 = Color(0xFFB7E23C);

  /// ターシャリーの 03 のグレー色。
  static const Color tertiary03 = Color(0xFFE3E3E3);

  /// ターシャリーの 04 のオレンジ色。
  static const Color tertiary04 = Color(0xFFF8A01C);

  /// ターシャリーの 05 の黄色。
  static const Color tertiary05 = Color(0xFFFBFA76);

  /// ターシャリーの 07 の赤色。
  static const Color tertiary07 = Color(0xFFFF3B30);

  /// テキストの 01 の黒色。
  static const Color text01 = Color(0xFF111111);

  /// テキストの 02 のグレー色。
  static const Color text02 = Color(0xFF707070);

  /// テキストの 03 のグレー色。
  static const Color text03 = Color(0xFFA0A0A0);

  /// テキストの 04 のグレー色。
  static const Color text04 = Color(0xFFCFCFCF);

  /// エラーの赤色。
  static const Color error = Color(0xFFF73F3F);

  /// サーフェスの 01 のグレー色。
  static const Color surface01 = Color(0xFFFAF9F7);

  /// サーフェスの 02 のグレー色。
  static const Color surface02 = Color(0xFFF5F5F5);

  /// サーフェスの 03 のグレー色。
  static const Color surface03 = Color(0xFFE3E3E3);

  /// アウトラインの 01 のグレー色。
  static const Color outline01 = Color(0xFFE3E3E3);

  /// アウトラインの 02 のグレー色。
  static const Color outline02 = Color(0xFFD0D0D0);

  /// アウトラインの 03 のグレー色。
  static const Color outline03 = Color(0xFFA0A0A0);

  /// アイコンなどのオブジェクト用カラー Gray01。
  static const Color gray01 = Color(0xFFE3E3E3);

  /// アイコンなどのオブジェクト用カラー Gray03。
  static const Color gray03 = Color(0xFFA0A0A0);

  /// シルバー。
  static const Color silver = Color(0xFFC0C0C0);

  /// 白色。
  static const Color primaryWhite = Colors.white;

  /// 黒色。
  static const Color primaryBlack = Colors.black;

  /// 透明色。
  static const Color transparent = Colors.transparent;

  /// フレーム背景色。
  static const Color frameBackground = Color(0xFFEEEEEF);
}
