plugins {
    id("com.android.application")
    id("kotlin-android")
    id("kotlin-kapt") // Untuk dukungan anotasi Kotlin
    id("kotlin-parcelize") // Untuk dukungan Parcelize
    id("com.google.gms.google-services") // Jika menggunakan Firebase
    id("com.google.firebase.crashlytics") // Jika menggunakan Crashlytics
    id("dev.flutter.flutter-gradle-plugin") // Plugin Flutter harus diaplikasikan terakhir
}

android {
    namespace = "com.example.smartone"
    compileSdk = 34 // Versi SDK yang digunakan untuk kompilasi
    ndkVersion = "25.1.8937393" // Versi NDK yang kompatibel

    // Konfigurasi kompilasi Java
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true // Aktifkan desugaring untuk Java 8+ API
    }

    // Konfigurasi Kotlin
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
        freeCompilerArgs = freeCompilerArgs + "-Xjvm-default=all"
    }

    // Aktifkan fitur build
    buildFeatures {
        viewBinding = true
        buildConfig = true
        compose = false // Sesuaikan jika menggunakan Jetpack Compose
    }

    // Aktifkan data binding
    dataBinding {
        isEnabled = true
    }

    defaultConfig {
        applicationId = "com.example.smartone" // Ganti dengan package name aplikasi Anda
        minSdk = 21 // Versi minimum Android yang didukung
        targetSdk = 34 // Target SDK versi terbaru
        versionCode = 1 // Versi kode aplikasi (naikkan setiap update)
        versionName = "1.0.0" // Versi aplikasi
        multiDexEnabled = true // Aktifkan multidex
        vectorDrawables.useSupportLibrary = true // Dukungan untuk vector drawable

        // Konfigurasi tambahan untuk arsitektur
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        
        // Konfigurasi tambahan untuk NDK (opsional)
        ndk {
            abiFilters.addAll(arrayOf("armeabi-v7a", "arm64-v8a", "x86_64"))
        }
    }

    // Konfigurasi untuk build release
    buildTypes {
        release {
            // Aktifkan minify, shrink, dan obfuscation
            isMinifyEnabled = true
            isShrinkResources = true
            
            // Gunakan file aturan ProGuard
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // Konfigurasi signing (ganti dengan konfigurasi release Anda)
            signingConfig = signingConfigs.getByName("debug") // Ganti dengan konfigurasi release
            
            // Nonaktifkan debug untuk build release
            isDebuggable = false
            isJniDebuggable = false
            isRenderscriptDebuggable = false
            isPseudoLocalesEnabled = true
            isCrunchPngs = true // Kompresi otomatis untuk PNG
        }
        
        // Konfigurasi untuk build debug
        debug {
            isDebuggable = true
            isJniDebuggable = true
            isRenderscriptDebuggable = true
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    
    // Konfigurasi flavor (opsional)
    flavorDimensions.add("default")
    productFlavors {
        create("dev") {
            dimension = "default"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "SmartOne Dev")
        }
        create("prod") {
            dimension = "default"
            resValue("string", "app_name", "SmartOne")
        }
    }
    
    // Konfigurasi packaging options
    packagingOptions {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
            excludes += "META-INF/DEPENDENCIES"
            excludes += "META-INF/LICENSE"
            excludes += "META-INF/LICENSE.txt"
            excludes += "META-INF/license.txt"
            excludes += "META-INF/NOTICE"
            excludes += "META-INF/NOTICE.txt"
            excludes += "META-INF/notice.txt"
            excludes += "META-INF/ASL2.0"
            excludes += "META-INF/*.kotlin_module"
            excludes += "META-INF/*.version"
        }
    }
    
    // Konfigurasi test options
    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            isReturnDefaultValues = true
        }
    }
    
    // Konfigurasi lint
    lint {
        checkReleaseBuilds = false
        abortOnError = false
        ignoreWarnings = true
        checkDependencies = true
    }
    
    dependencies {
        // Dependensi inti AndroidX
        implementation("androidx.core:core-ktx:1.12.0")
        implementation("androidx.appcompat:appcompat:1.6.1")
        implementation("com.google.android.material:material:1.11.0")
        implementation("androidx.constraintlayout:constraintlayout:2.1.4")
        
        // Multidex support
        implementation("androidx.multidex:multidex:2.0.1")
        
        // Lifecycle components
        implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.6.2")
        implementation("androidx.lifecycle:lifecycle-livedata-ktx:2.6.2")
        implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.6.2")
        
        // Navigation component
        implementation("androidx.navigation:navigation-fragment-ktx:2.7.6")
        implementation("androidx.navigation:navigation-ui-ktx:2.7.6")
        
        // Coroutines
        implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
        implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
        
        // Retrofit & OkHttp
        implementation("com.squareup.retrofit2:retrofit:2.9.0")
        implementation("com.squareup.retrofit2:converter-gson:2.9.0")
        implementation("com.squareup.okhttp3:logging-interceptor:4.11.0")
        
        // Glide untuk image loading
        implementation("com.github.bumptech.glide:glide:4.16.0")
        kapt("com.github.bumptech.glide:compiler:4.16.0")
        
        // Firebase BoM (Bill of Materials)
        implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
        implementation("com.google.firebase:firebase-analytics")
        implementation("com.google.firebase:firebase-crashlytics")
        implementation("com.google.firebase:firebase-messaging")
        
        // WorkManager
        implementation("androidx.work:work-runtime-ktx:2.8.1")
        
        // Testing
        testImplementation("junit:junit:4.13.2")
        androidTestImplementation("androidx.test.ext:junit:1.1.5")
        androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
        
        // Desugaring untuk Java 8+ API pada perangkat lama
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    }
}

flutter {
    source = "../.."
}
