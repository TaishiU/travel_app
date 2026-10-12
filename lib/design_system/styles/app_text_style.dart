import 'package:travel_app/design_system/styles/app_color.dart';
import 'package:flutter/material.dart';

// import '../../gen/fonts.gen.dart';
// import 'color.dart';

/// アプリで使用するテキストスタイルから定義された [TextStyle] を提供する。
///
/// Figmaの指定に準ずるフォントスタイルを定義する。
/// - h: headline
/// - t: text
/// - 数字: フォントサイズ
///
/// 詳しくはこちらの[Figmaのリンク](https://www.figma.com/design/um8YtdOnETZP2mjxnrSZ4f/Omiai-Flutter?node-id=3953-14711&t=MKUZwnznGb2obfqz-4)を参照してください。
///
/// ## 使用例
///
/// ```dart
/// // 見出しテキストの使用
/// Text(
///   'これは見出しです',
///   style: AppTextStyle.h20,
/// );
///
/// // 本文テキストの使用
/// Text(
///   'これは本文です',
///   style: AppTextStyle.t14,
/// );
/// ```
///
/// ## 注意事項
///
/// `copyWith` で値を上書きする際は、**色のみ**に制限してください。
/// fontSize、fontWeight、height などのプロパティを変更すると、
/// デザインシステムの一貫性が損なわれる可能性があります。
///
/// 既存のスタイルで対応できない場合は、以下の手順に従ってください：
/// 1. Figma で定義されているか確認する
/// 2. 定義されている場合は、そのスタイルを新規追加する
/// 3. 定義されていない場合は、デザイナーへ新しいスタイルの作成を依頼する
///
/// ```dart
/// // ❌ 非推奨: 色以外のプロパティを変更
/// AppTextStyle.h16.copyWith(
///   fontSize: 18,  // 避けるべき
///   fontWeight: FontWeight.w800,  // 避けるべき
/// );
///
/// // ✅ 推奨: 色のみを変更
/// AppTextStyle.h16.copyWith(color: AppColor.primary);
///
/// // ✅ 推奨: 新しいスタイルが必要な場合は定義を追加
/// static const h18(figmaの命名に従ってください。) = TextStyle(...);
/// ```

class AppTextStyle {
  AppTextStyle._();

  // static const _fontFamilyFallback = [FontFamily.hiraginoSans];
  static const _fontFamilyFallback = ['hiraginoSans'];

  // ---- Headline styles  ---- //

  /// Headline 28 / 行間36 / Bold の [TextStyle].
  static const h28 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 28,
    height: 36 / 28,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Headline 26 / 行間33 / Bold の [TextStyle].
  static const h26 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 26,
    height: 33 / 26,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Headline 24 / 行間29 / Bold の [TextStyle].
  static const h24 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 29 / 24,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Headline 22 / 行間27 / Bold の [TextStyle].
  static const h22 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 22,
    height: 27 / 22,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Headline 20 / 行間25 / Bold の [TextStyle].
  static const h20 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 25 / 20,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Headline 18 / 行間23 / Bold の [TextStyle].
  static const h18 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 23 / 18,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Headline 16 / 行間20 / Bold の [TextStyle].
  static const h16 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 20 / 16,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Headline 15 / 行間20 / Bold の [TextStyle].
  static const h15 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    height: 20 / 15,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Headline 14 / 行間20 / Bold の [TextStyle].
  static const h14 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 20 / 14,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Headline 13 / 行間18 / Bold の [TextStyle].
  static const h13 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13,
    height: 18 / 13,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Headline 12 / 行間16 / Bold の [TextStyle].
  static const h12 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 16 / 12,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Headline 11 / 行間14 / Bold の [TextStyle].
  static const h11 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 11,
    height: 14 / 11,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Headline 10 / 行間13 / Bold の [TextStyle].
  static const h10 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 10,
    height: 13 / 10,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Headline 8 / 行間8 / Bold の [TextStyle].
  static const h8 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 8,
    height: 8 / 8,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  // ---- Text styles  ---- //

  /// Text 28 / 行間36 / Regular の [TextStyle].
  static const t28 = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 28,
    height: 36 / 28,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Text 26 / 行間33 / Regular の [TextStyle].
  static const t26 = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 26,
    height: 33 / 26,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Text 24 / 行間29 / Regular の [TextStyle].
  static const t24 = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 24,
    height: 29 / 24,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Text 22 / 行間27 / Regular の [TextStyle].
  static const t22 = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 22,
    height: 27 / 22,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Text 20 / 行間25 / Regular の [TextStyle].
  static const t20 = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 20,
    height: 25 / 20,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Text 18 / 行間23 / Regular の [TextStyle].
  static const t18 = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 18,
    height: 23 / 18,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Text 16 / 行間20 / Regular の [TextStyle].
  static const t16 = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 16,
    height: 20 / 16,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Text 15 / 行間20 / Regular の [TextStyle].
  static const t15 = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 15,
    height: 20 / 15,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Text 14 / 行間20 / Regular の [TextStyle].
  static const t14 = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 14,
    height: 20 / 14,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Text 13 / 行間18 / Regular の [TextStyle].
  static const t13 = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 13,
    height: 18 / 13,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Text 12 / 行間16 / Regular の [TextStyle].
  static const t12 = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 12,
    height: 16 / 12,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Text 11 / 行間14 / Regular の [TextStyle].
  static const t11 = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 11,
    height: 14 / 11,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );

  /// Text 10 / 行間13 / Regular の [TextStyle].
  static const t10 = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 10,
    height: 13 / 10,
    fontFamilyFallback: _fontFamilyFallback,
    color: AppColor.text01,
  );
}
