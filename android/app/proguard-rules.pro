# Keep Awesome Notifications classes
-keep class me.carda.awesome_notifications.** { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keep class j2.** { *; } # ป้องกัน sharedPreferences error
