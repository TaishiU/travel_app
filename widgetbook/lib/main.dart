import 'package:travel_app/design_system/styles/app_color.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'main.directories.g.dart';

void main() {
  runApp(const WidgetbookApp());
}

/// Widgetbookのエントリポイント。
///
/// このクラスはWidgetbookのアプリケーションを定義します。
/// 以下の設定を行っています：
/// - テーマの設定
/// - デバイスの設定
/// - アドオンの設定
/// - ディレクトリの設定
///
/// NOTE: 以下のcloudAddonsConfigsでは[ZoomAddon]と[ZoomAddonConfig]を用いて、
/// ズーム倍率の設定を行っています。
///
/// この設定を行うことで、小さいサイズのWidgetを指定した倍率まで拡大して表示することができます。
@App(
  cloudAddonsConfigs: {
    'x1': [ZoomAddonConfig(1)],
    'x2': [ZoomAddonConfig(2)],
    'x3': [ZoomAddonConfig(3)],
  },
)
class WidgetbookApp extends StatelessWidget {
  /// [WidgetbookApp]を生成する。
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(
              name: 'Default',
              data: ThemeData(
                // textTheme: appTextTheme,
                scaffoldBackgroundColor: AppColor.primaryWhite,
                appBarTheme: AppBarTheme(
                  centerTitle: true,
                  surfaceTintColor: AppColor.transparent,
                  elevation: 0,
                  backgroundColor: AppColor.primaryWhite,
                  // titleTextStyle: appTextTheme.titleMedium,
                ),
              ),
            ),
            // NOTE: ウィジェットの背景色がデフォルトの背景色（白）と同一の場合、
            // 境界や透過度が視認できないため、コントラストのある背景色のテーマを追加しています。
            // これにより、白背景のウィジェットや透過処理の動作確認が容易になります。
            WidgetbookTheme(
              name: 'Background: Outline03',
              data: ThemeData(
                scaffoldBackgroundColor: AppColor.outline03,
                appBarTheme: AppBarTheme(
                  centerTitle: true,
                  surfaceTintColor: AppColor.transparent,
                  elevation: 0,
                  backgroundColor: AppColor.outline03,
                  // titleTextStyle: appTextTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
        TextScaleAddon(),
        InspectorAddon(),
        ZoomAddon(),
        ViewportAddon([
          const ViewportData(
            pixelRatio: 1,
            platform: TargetPlatform.iOS,
            name: 'iPhoneSE 1st',
            width: 320,
            height: 568,
          ),
          const ViewportData(
            pixelRatio: 1,
            platform: TargetPlatform.iOS,
            name: 'iPhoneSE 3rd',
            width: 375,
            height: 667,
          ),
          const ViewportData(
            pixelRatio: 1,
            platform: TargetPlatform.iOS,
            name: 'iPhone14',
            width: 390,
            height: 844,
          ),
          const ViewportData(
            pixelRatio: 1,
            platform: TargetPlatform.iOS,
            name: 'iPhone15 ProMax',
            width: 430,
            height: 932,
          ),
          const ViewportData(
            pixelRatio: 1,
            platform: TargetPlatform.android,
            name: 'Pixel 9 Pro XL',
            width: 443,
            height: 997,
          ),
        ]),
      ],
    );
  }
}
