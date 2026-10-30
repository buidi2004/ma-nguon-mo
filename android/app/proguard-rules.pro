# Flutter Wrapper rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep data models and serialization
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# SharedPreferences and SQLite
-keep class com.russhwolf.settings.** { *; }

# Video Player and Media
-keep class com.google.android.exoplayer2.** { *; }
-keep class androidx.media3.** { *; }

