plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.5.0"))
    implementation("com.google.firebase:firebase-analytics")
    
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.2")
  
  // Core library desugaring for flutter_local_notifications
  coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

android {
    namespace = "com.example.uts_backend"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        // UBAH DARI 11 JADI 1.8 BIAR KONSISTEN DENGAN JAVA
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.uts_backend"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
