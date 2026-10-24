# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# SharedPreferences plugin
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class io.flutter.plugins.sharedpreferences.SharedPreferencesApiRegistrar { *; }

# Keep Kotlin Coroutines & Continuation
-keepattributes *Annotation*, InnerClasses, Signature, EnclosingMethod
-keepclassmembers class * extends kotlin.coroutines.jvm.internal.ContinuationImpl {
    <fields>;
    <methods>;
}
-keep class kotlin.coroutines.Continuation { *; }

# Play Core suppression
-dontwarn com.google.android.play.core.**
