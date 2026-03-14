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
  String get navConverter => 'Key Swap';

  @override
  String get navPhrases => 'Phrases';

  @override
  String get dailyCardLoadError => 'Couldn\'t load today\'s card';

  @override
  String get converterTitle => 'Key Swap';

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
  String get converterPaste => 'Paste';

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
      'Customize your theme and unlock\nunlimited favorites';

  @override
  String get conversionTriggerButton => 'View Theme Options';

  @override
  String get conversionTriggerDismiss => 'Later';

  @override
  String get favLimitTitle => 'You really love a lot of phrases!';

  @override
  String favLimitMessage(String price) {
    return 'Buy any theme product to unlock\nunlimited favorites! From $price';
  }

  @override
  String get favLimitButton => 'Unlock Unlimited Favorites';

  @override
  String get favLimitOpenApp => 'Unlock in App';

  @override
  String get favLimitDismiss => 'Later';

  @override
  String honeymoonDaysLeft(int days) {
    return '$days days of free trial left';
  }

  @override
  String get languageLabel => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get reviewLabel => 'Rate this app';

  @override
  String get reviewSubtitle => 'Your review helps other fans find Fangeul';

  @override
  String get contactLabel => 'Contact us';

  @override
  String get contactSubtitle => 'Report bugs or suggest features';

  @override
  String get settingsThemeColor => 'Theme Color';

  @override
  String get settingsThemeColorDesc => 'Customize the app color';

  @override
  String get themePickerTitle => 'Theme Color';

  @override
  String get themePickerSubtitle => 'Make the app yours with your own color';

  @override
  String get paletteDefault => 'Default (Teal)';

  @override
  String get paletteCherryBlossom => 'Cherry Blossom';

  @override
  String get paletteOcean => 'Ocean';

  @override
  String get paletteForest => 'Forest';

  @override
  String get paletteSunset => 'Sunset';

  @override
  String get paletteStarryNight => 'Starry Night';

  @override
  String get paletteDawn => 'Dawn';

  @override
  String get paletteDusk => 'Dusk';

  @override
  String get paletteJewel => 'Jewel';

  @override
  String get themePickerCustom => 'Pick your own';

  @override
  String get themePickerThemeColor => 'Theme color';

  @override
  String get themePickerHue => 'Hue';

  @override
  String get themePickerSaturation => 'Saturation';

  @override
  String get themePickerLightness => 'Lightness';

  @override
  String get themePickerTextColor => 'Text color';

  @override
  String get themePickerTextColorDesc =>
      'Choose your text color (free picker only)';

  @override
  String get themePickerTextColorAuto => 'Auto contrast';

  @override
  String get themePickerPreview => 'Preview';

  @override
  String get themePickerLocked => 'Unlock with Fan Pass';

  @override
  String themePickerPickerLocked(String price) {
    return 'Unlock forever for $price';
  }

  @override
  String get themePickerUnlockAll => 'Unlock all themes';

  @override
  String get themePickerUnlockAllDesc =>
      'Watch an ad to unlock all theme palettes forever';

  @override
  String get themePickerPreviewHint => 'Preview only — purchase to apply';

  @override
  String get themePickerApplyLocked => 'Purchase to apply this theme';

  @override
  String get themePickerUndo => 'Undo';

  @override
  String get themePickerLowContrast => 'Low contrast';

  @override
  String get favoriteLimitReached => 'Favorite limit reached (max 5)';

  @override
  String get choeaeColorTitle => 'My Color';

  @override
  String get choeaeColorSubtitle => 'Make the app yours with your color';

  @override
  String get paletteMidnight => 'Midnight';

  @override
  String get palettePurpleDream => 'Purple Dream';

  @override
  String get paletteOceanBlue => 'Ocean Blue';

  @override
  String get paletteRoseGold => 'Rose Gold';

  @override
  String get paletteConcertEncore => 'Concert Encore';

  @override
  String get paletteGoldenHour => 'Golden Hour';

  @override
  String get paletteNeonNight => 'Neon Night';

  @override
  String get paletteMintBreeze => 'Mint Breeze';

  @override
  String get paletteSunsetCafe => 'Sunset Café';

  @override
  String get themePickerChroma => 'Chroma';

  @override
  String get themePickerTone => 'Tone';

  @override
  String get themePickerHexInput => 'Color code';

  @override
  String get themePickerBrightness => 'Brightness';

  @override
  String get themeModeLocked =>
      'Custom theme controls brightness independently';

  @override
  String get themePickerSlots => 'Theme Slots';

  @override
  String get themePickerSlotSave => 'Save current theme';

  @override
  String get themePickerSlotLocked => 'Unlock slots';

  @override
  String get themePickerCustomSaveLocked =>
      'Purchase custom colors to save this theme';

  @override
  String get themePickerSlotLongPressHint =>
      'Long press a slot to rename or overwrite';

  @override
  String get themePickerSlotName => 'Slot name';

  @override
  String get themePickerRecommended => 'Recommended';

  @override
  String get themePickerFreePickerTitle => 'Custom text color';

  @override
  String get iapThemeCustomColor => 'Custom background & text';

  @override
  String get iapThemeCustomColorSub =>
      'Custom color theme · Unlimited favorites';

  @override
  String get iapThemeSlots => 'Save 3 favorite themes';

  @override
  String get iapThemeSlotsSub => 'Theme slot switching · Unlimited favorites';

  @override
  String get iapThemeBundle => 'Full Bundle (24% off)';

  @override
  String get iapThemeBundleSave => 'Unlimited favorites';

  @override
  String get privacyPolicyLabel => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle =>
      'Information we collect and how we use it';

  @override
  String get termsLabel => 'Terms of Service';

  @override
  String get termsSubtitle => 'Conditions for using the service';
}
