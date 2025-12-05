# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Flavor
-keep class [YOUR_APP_PACKAGE].BuildConfig { *; }

# Retrofit 2
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.jetbrains.annotations.**
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-keep class com.google.gson.** { *; }
-keep class com.google.gson.examples.android.model.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# OkHttp
-keepattributes Signature
-keepattributes *Annotation*
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

# Glide
-keep public class * implements com.bumptech.glide.module.GlideModule
-keep public class * extends com.bumptech.glide.module.AppGlideModule
-keep public enum com.bumptech.glide.load.ImageHeaderParser$** {
    **[] $VALUES;
    public *;
}
-keep class com.bumptech.glide.load.data.ParcelFileDescriptorRewinder$InternalRewinder {
  *** rewind();
}

# WorkManager
-keep class androidx.work.** { *; }
-keepclassmembers class * extends androidx.work.Worker {
    public <init>(android.content.Context,androidx.work.WorkerParameters);
}

# Room
-keep class * extends androidx.room.RoomDatabase
-keep class * extends androidx.room.Entity
-keep class * {
    @androidx.room.* <methods>;
}

# Lifecycle components
-keep class * implements androidx.lifecycle.GeneratedAdapter
-keep class * extends androidx.lifecycle.Lifecycle
-keepclassmembers class * extends androidx.lifecycle.Lifecycle {
    void on*(androidx.lifecycle.LifecycleOwner, androidx.lifecycle.Lifecycle$Event);
}

# Navigation Component
-keep class * extends androidx.navigation.fragment.NavHostFragment
-keep class * extends androidx.navigation.fragment.FragmentNavigator$Destination
-keep class * extends androidx.navigation.fragment.DialogFragmentNavigator$Destination
-keep class * extends androidx.navigation.ActivityNavigator$Destination

# Keep AndroidX
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-dontwarn androidx.**

# Keep Android Support Library
-keep class android.support.v4.app.** { *; }
-keep interface android.support.v4.app.** { *; }
-keep class android.support.v7.app.** { *; }
-keep interface android.support.v7.app.** { *; }
-dontwarn android.support.**

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Keep resource classes
-keep class **.R
-keep class **.R$* {
    <fields>;
}

# Keep view bindings
-keep class * implements butterknife.Unbinder { *; }
-keep class * extends java.lang.Exception { *; }
-keep class * {
    @butterknife.* <fields>;
}
-keepclasseswithmembernames class * {
    @butterknife.* <methods>;
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep Serializable implementations
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep the application class
-keep public class * extends android.app.Application {
    public <init>();
    public void attachBaseContext(android.content.Context);
}

# Keep all classes that have @Keep annotation
-keep class * {
    @androidx.annotation.Keep *;
    @android.support.annotation.Keep *;
}

# Keep @Keep annotation
-keep @interface android.support.annotation.Keep
-keep @interface androidx.annotation.Keep
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <fields>;
}
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <methods>;
}
-keepclasseswithmembers class * {
    @android.support.annotation.Keep <fields>;
}
-keepclasseswithmembers class * {
    @android.support.annotation.Keep <methods>;
}

# Keep all activities, services, and broadcast receivers
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgent
-keep public class * extends android.preference.Preference

# For custom rules
# -keep class your.package.name.** { *; }
