// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Fangeul';

  @override
  String get appVersion => '0.1.0';

  @override
  String get appLegalese => '© 2026 Tiger Room';

  @override
  String get copied => 'Copied';

  @override
  String get errorPrefix => 'Error:';

  @override
  String get copyTooltip => 'Copy';

  @override
  String get favoriteTooltip => 'Favorite';

  @override
  String get complete => 'Done';

  @override
  String get share => 'Share';

  @override
  String streakDays(int streak) {
    return '$streak-day streak';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navConverter => 'Converter';

  @override
  String get navPhrases => 'Phrases';

  @override
  String get dailyCardLoadError => 'Couldn\'t load today\'s card';

  @override
  String get converterTitle => 'Converter';

  @override
  String get converterTabEngToKor => 'Eng→Kor';

  @override
  String get converterTabKorToEng => 'Kor→Eng';

  @override
  String get converterTabRomanize => 'Romanize';

  @override
  String get converterHintEngToKor => 'Type in English (e.g. gksrmf)';

  @override
  String get converterHintKorToEng => 'Type in Korean (e.g. 한글)';

  @override
  String get converterHintRomanize => 'Type in Korean (e.g. 사랑해요)';

  @override
  String get phrasesTitle => 'Phrases';

  @override
  String get phrasesEmpty => 'No phrases available';

  @override
  String get phrasesMyIdolEmpty =>
      'Select your idol in Settings\nto see personalized phrases';

  @override
  String phrasesMyIdolChip(String name) {
    return '♡ $name';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get appInfoTitle => 'App Info';

  @override
  String appInfoSubtitle(String version) {
    return 'Fangeul v$version';
  }

  @override
  String get tagAll => 'All';

  @override
  String get tagLove => 'Love';

  @override
  String get tagCheer => 'Cheer';

  @override
  String get tagDaily => 'Daily';

  @override
  String get tagGreeting => 'Greeting';

  @override
  String get tagEmotional => 'Emotion';

  @override
  String get tagPraise => 'Praise';

  @override
  String get tagFandom => 'Fandom';

  @override
  String get tagBirthday => 'Birthday';

  @override
  String get tagComeback => 'Comeback';

  @override
  String get keyboardSpace => 'Space';

  @override
  String get keyboardModeKorean => 'Korean';

  @override
  String get keyboardModeAbc => 'ABC';

  @override
  String get keyboardModeNumbers => '123';

  @override
  String get keyboardDone => 'Done';

  @override
  String get defaultTranslationLang => 'en';

  @override
  String get bubbleLabel => 'Floating Bubble';

  @override
  String get bubbleDescription => 'Use the converter outside the app';

  @override
  String get bubblePermissionTitle => 'Overlay Permission Required';

  @override
  String get bubblePermissionMessage =>
      'To show the floating bubble, we need permission to display over other apps.';

  @override
  String get bubblePermissionAllow => 'Allow';

  @override
  String get bubblePermissionDeny => 'Cancel';

  @override
  String get bubblePermissionDenied =>
      'You can still use all features inside the app';

  @override
  String get bubbleBatteryTitle => 'Disable Battery Optimization';

  @override
  String get bubbleBatteryMessage =>
      'For the bubble to work reliably, please disable battery optimization.\nOn some devices, battery optimization may close the bubble automatically.';

  @override
  String get bubbleBatteryAllow => 'Open Settings';

  @override
  String get bubbleBatteryDeny => 'Later';

  @override
  String get miniConverterTitle => 'Fangeul';

  @override
  String get miniTabPhrases => 'Phrases';

  @override
  String get miniTabFavorites => 'Favorites';

  @override
  String get miniTabRecent => 'Recent';

  @override
  String get miniChipFavorites => '★Favs';

  @override
  String get miniChipToday => 'Today';

  @override
  String get miniPackLocked =>
      'This pack is locked\nYou\'ll be able to unlock it soon!';

  @override
  String get miniPackEmpty => 'No phrases available';

  @override
  String get miniOpenConverter => 'Open Converter';

  @override
  String get miniBackToCompact => 'Compact Mode';

  @override
  String get miniMenuOpenApp => 'Open Fangeul App';

  @override
  String get miniMenuCloseBubble => 'Hide Popup';

  @override
  String get miniFavoritesEmpty =>
      'Tap ⭐ on a phrase\nto add it to your favorites';

  @override
  String get miniMyIdolEmpty =>
      'Select your idol in Settings\nto see personalized phrases';

  @override
  String get miniTodayEmpty => 'No events related to today';

  @override
  String get miniRecentEmpty => 'No copied text yet';

  @override
  String get idolSelectTitle => 'Choose your favorite group';

  @override
  String get idolSelectSubtitle => 'You can change this anytime in Settings';

  @override
  String get idolSelectSkip => 'Set up later';

  @override
  String get idolSelectOther => 'Other (enter manually)';

  @override
  String get idolSelectOtherHint => 'Enter the group name';

  @override
  String get idolSelectConfirm => 'Confirm';

  @override
  String get idolSettingLabel => 'My Idol';

  @override
  String get idolSettingEmpty => 'Not selected yet';

  @override
  String idolSettingCurrent(String name) {
    return 'Current: $name';
  }

  @override
  String homeGreeting(String name) {
    return 'Hi, $name fan!';
  }

  @override
  String get idolSettingChange => 'Change';

  @override
  String get idolMemberHint => 'Member name (optional)';

  @override
  String get idolMemberLabel => 'Bias';

  @override
  String phrasesMemberChip(String name) {
    return '♡ $name';
  }

  @override
  String phrasesGroupChip(String name) {
    return '$name';
  }

  @override
  String get phrasesMemberEmpty => 'No member-specific phrases';

  @override
  String get fanPassButton => 'Fan Pass';

  @override
  String fanPassRemaining(int current, int max) {
    return '($current/$max)';
  }

  @override
  String get fanPassCooldown => 'Please try again in a moment';

  @override
  String get fanPassAdLoading => 'Loading ad...';

  @override
  String get fanPassLimitReached => 'All done for today';

  @override
  String get fanPassPopupTitle => 'Fan Pass earned!';

  @override
  String get fanPassPopupConfirm => 'OK';

  @override
  String fanPassUnlockRemaining(String time) {
    return '$time remaining';
  }

  @override
  String unlockRemaining(String time) {
    return '$time remaining';
  }

  @override
  String get unlockMidnightLabel => 'Expires at midnight';

  @override
  String unlockMidnightExpiry(String time) {
    return '$time remaining (expires at midnight)';
  }

  @override
  String get shopTitle => 'Color Vibe Packs';

  @override
  String get shopRestore => 'Restore Purchases';

  @override
  String get shopBuyButton => 'Buy';

  @override
  String get shopPurchased => 'Purchased';

  @override
  String shopPhraseCount(int count) {
    return '$count phrases';
  }

  @override
  String shopPronunciationCount(int count) {
    return '$count pronunciations';
  }

  @override
  String get shopRestoreSuccess => 'Purchases restored';

  @override
  String get shopRestoreFailed => 'No purchases to restore';

  @override
  String ddayGiftTitle(String eventName) {
    return 'Happy $eventName!';
  }

  @override
  String get ddayGiftMessage => 'All content is free for today';

  @override
  String get ddayGiftButton => 'Claim Gift';

  @override
  String get ttsLimitTitle => 'That\'s all for today\'s listening!';

  @override
  String ttsLimitMessage(int limit) {
    return 'You\'ll get $limit more listens tomorrow';
  }

  @override
  String get ttsLimitAdButton => 'Listen more with Fan Pass';

  @override
  String get conversionTriggerTitle => 'Enjoy even more content';

  @override
  String get conversionTriggerMessage =>
      'Unlock everything with a Color Vibe Pack\nand start a special experience';

  @override
  String get conversionTriggerButton => 'View Color Vibe Packs';

  @override
  String get conversionTriggerDismiss => 'Later';

  @override
  String get favLimitTitle => 'You really love a lot of phrases!';

  @override
  String get favLimitMessage =>
      'Save more phrases with a Fan Pass\nor keep unlimited with a Color Vibe Pack';

  @override
  String get favLimitAdButton => 'Get Fan Pass';

  @override
  String get favLimitIapButton => 'Browse Color Vibe Packs';

  @override
  String get shopPurchaseSuccess => 'Purchase complete! Content unlocked';

  @override
  String get shopPurchaseFailed => 'Purchase failed. Please try again';

  @override
  String get shopPurchasePending => 'Processing payment...';

  @override
  String honeymoonDaysLeft(int days) {
    return '$days days of free trial left';
  }
}
