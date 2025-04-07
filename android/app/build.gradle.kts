plugins {
    id("com.android.application")
    id("kotlin-android")  // This is necessary for Kotlin integration
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    compileSdk = 33

    defaultConfig {
        applicationId = "com.tuhmews.app"  // Replace with your app's package name
        minSdk = 21
        targetSdk = 33
        versionCode = 1
        versionName = "1.0"
    }

    // Add the 'namespace' property here
    namespace = "com.tuhmews.app"  // Replace with your app's package name

    buildFeatures {
        // Add or remove build features as necessary
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    dependencies {
        implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.22")
    }
}

flutter {
    source = "../.."
}
