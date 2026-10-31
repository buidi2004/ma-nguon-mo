# Flutter Wrapper & Engine rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Play Core / Flutter Deferred Components (bỏ qua cảnh báo class không sử dụng)
-dontwarn com.google.android.play.core.**

# Google Sign-in / Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep data models, annotations and serialization
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# SharedPreferences and SQLite
-keep class com.russhwolf.settings.** { *; }

# Video Player and Media (ExoPlayer & Media3)
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**

# Network & Utilities (OkHttp, Okio)
-dontwarn okhttp3.**
-dontwarn okio.**
