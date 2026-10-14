plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// --dart-define で渡された値を Map<String, String> に展開する。
// Flutter は dart-defines を Base64 エンコードしたカンマ区切り文字列として Gradle に渡す。
val dartDefines: Map<String, String> = if (project.hasProperty("dart-defines")) {
    (project.property("dart-defines") as String)
        .split(",")
        .filter { it.isNotEmpty() }
        .associate { encoded ->
            val decoded = String(java.util.Base64.getDecoder().decode(encoded))
            val eqIndex = decoded.indexOf('=')
            if (eqIndex >= 0) decoded.substring(0, eqIndex) to decoded.substring(eqIndex + 1)
            else decoded to ""
        }
} else {
    emptyMap()
}

val flavorName = dartDefines["FLAVOR"] ?: "dev"

val brazeAndroidApiKey = when (flavorName) {
    "prod"    -> "YOUR_PROD_ANDROID_API_KEY"
    "staging" -> "YOUR_STG_ANDROID_API_KEY"
    else      -> "YOUR_DEV_ANDROID_API_KEY"
}

val brazeEndpoint = when (flavorName) {
    "prod"    -> "YOUR_PROD_BRAZE_ENDPOINT"
    "staging" -> "YOUR_STG_BRAZE_ENDPOINT"
    else      -> "YOUR_DEV_BRAZE_ENDPOINT"
}

android {
    namespace = "com.example.travel_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.travel_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // FLAVOR ごとに Braze 設定を切り替える（braze.xml から移管）。
        resValue("string", "com_braze_api_key", brazeAndroidApiKey)
        resValue("string", "com_braze_custom_endpoint", brazeEndpoint)
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
