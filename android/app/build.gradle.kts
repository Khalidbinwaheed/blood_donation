plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Firebase
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.blood_donation"
    compileSdk = 34 // Use explicit version instead of flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        coreLibraryDesugaringEnabled = true // For Java 8+ features
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.blood_donation"
        minSdk = 23
        targetSdk = 34 // Use explicit version
        versionCode = 1 // Set explicit version
        versionName = "1.0.0" // Set explicit version
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.debug // Temporary for testing
            minifyEnabled = true
            shrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            minifyEnabled = false
            shrinkResources = false
        }
    }

    // Enable view binding if needed
    buildFeatures {
        viewBinding = true
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4") // For Java 8+ features
    implementation(platform("com.google.firebase:firebase-bom:32.7.2")) // Firebase BoM
}

flutter {
    source = "../.."
}