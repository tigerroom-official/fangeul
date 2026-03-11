## Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

## Google Play Billing (in_app_purchase)
-keep class com.android.vending.billing.** { *; }

## Crashlytics
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

## Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**

## flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

## Google Play Core (deferred components — Flutter engine references these)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
