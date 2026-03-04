import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_th.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ko'),
    Locale('en'),
    Locale('es'),
    Locale('id'),
    Locale('pt'),
    Locale('th'),
    Locale('vi')
  ];

  /// No description provided for @appName.
  ///
  /// In ko, this message translates to:
  /// **'Fangeul'**
  String get appName;

  /// No description provided for @appVersion.
  ///
  /// In ko, this message translates to:
  /// **'0.1.0'**
  String get appVersion;

  /// No description provided for @appLegalese.
  ///
  /// In ko, this message translates to:
  /// **'© 2026 Tiger Room'**
  String get appLegalese;

  /// No description provided for @copied.
  ///
  /// In ko, this message translates to:
  /// **'복사되었습니다'**
  String get copied;

  /// No description provided for @errorPrefix.
  ///
  /// In ko, this message translates to:
  /// **'오류:'**
  String get errorPrefix;

  /// No description provided for @copyTooltip.
  ///
  /// In ko, this message translates to:
  /// **'복사'**
  String get copyTooltip;

  /// No description provided for @favoriteTooltip.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기'**
  String get favoriteTooltip;

  /// No description provided for @complete.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get complete;

  /// No description provided for @share.
  ///
  /// In ko, this message translates to:
  /// **'공유'**
  String get share;

  /// No description provided for @streakDays.
  ///
  /// In ko, this message translates to:
  /// **'{streak}일 연속'**
  String streakDays(int streak);

  /// No description provided for @navHome.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get navHome;

  /// No description provided for @navConverter.
  ///
  /// In ko, this message translates to:
  /// **'변환기'**
  String get navConverter;

  /// No description provided for @navPhrases.
  ///
  /// In ko, this message translates to:
  /// **'문구'**
  String get navPhrases;

  /// No description provided for @dailyCardLoadError.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 카드를 불러올 수 없습니다'**
  String get dailyCardLoadError;

  /// No description provided for @converterTitle.
  ///
  /// In ko, this message translates to:
  /// **'변환기'**
  String get converterTitle;

  /// No description provided for @converterTabEngToKor.
  ///
  /// In ko, this message translates to:
  /// **'영->한'**
  String get converterTabEngToKor;

  /// No description provided for @converterTabKorToEng.
  ///
  /// In ko, this message translates to:
  /// **'한->영'**
  String get converterTabKorToEng;

  /// No description provided for @converterTabRomanize.
  ///
  /// In ko, this message translates to:
  /// **'발음'**
  String get converterTabRomanize;

  /// No description provided for @converterHintEngToKor.
  ///
  /// In ko, this message translates to:
  /// **'영문을 입력하세요 (예: gksrmf)'**
  String get converterHintEngToKor;

  /// No description provided for @converterHintKorToEng.
  ///
  /// In ko, this message translates to:
  /// **'한글을 입력하세요 (예: 한글)'**
  String get converterHintKorToEng;

  /// No description provided for @converterHintRomanize.
  ///
  /// In ko, this message translates to:
  /// **'한글을 입력하세요 (예: 사랑해요)'**
  String get converterHintRomanize;

  /// No description provided for @phrasesTitle.
  ///
  /// In ko, this message translates to:
  /// **'문구'**
  String get phrasesTitle;

  /// No description provided for @phrasesEmpty.
  ///
  /// In ko, this message translates to:
  /// **'문구가 없습니다'**
  String get phrasesEmpty;

  /// No description provided for @phrasesMyIdolEmpty.
  ///
  /// In ko, this message translates to:
  /// **'설정에서 아이돌을 선택하면\n맞춤 문구가 표시됩니다'**
  String get phrasesMyIdolEmpty;

  /// No description provided for @phrasesMyIdolChip.
  ///
  /// In ko, this message translates to:
  /// **'♡ {name}'**
  String phrasesMyIdolChip(String name);

  /// No description provided for @settingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTitle;

  /// No description provided for @themeLabel.
  ///
  /// In ko, this message translates to:
  /// **'테마'**
  String get themeLabel;

  /// No description provided for @themeDark.
  ///
  /// In ko, this message translates to:
  /// **'다크'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In ko, this message translates to:
  /// **'라이트'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템'**
  String get themeSystem;

  /// No description provided for @appInfoTitle.
  ///
  /// In ko, this message translates to:
  /// **'앱 정보'**
  String get appInfoTitle;

  /// No description provided for @appInfoSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'Fangeul v{version}'**
  String appInfoSubtitle(String version);

  /// No description provided for @tagAll.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get tagAll;

  /// No description provided for @tagLove.
  ///
  /// In ko, this message translates to:
  /// **'사랑'**
  String get tagLove;

  /// No description provided for @tagCheer.
  ///
  /// In ko, this message translates to:
  /// **'응원'**
  String get tagCheer;

  /// No description provided for @tagDaily.
  ///
  /// In ko, this message translates to:
  /// **'일상'**
  String get tagDaily;

  /// No description provided for @tagGreeting.
  ///
  /// In ko, this message translates to:
  /// **'인사'**
  String get tagGreeting;

  /// No description provided for @tagEmotional.
  ///
  /// In ko, this message translates to:
  /// **'감정'**
  String get tagEmotional;

  /// No description provided for @tagPraise.
  ///
  /// In ko, this message translates to:
  /// **'칭찬'**
  String get tagPraise;

  /// No description provided for @tagFandom.
  ///
  /// In ko, this message translates to:
  /// **'팬덤'**
  String get tagFandom;

  /// No description provided for @tagBirthday.
  ///
  /// In ko, this message translates to:
  /// **'생일'**
  String get tagBirthday;

  /// No description provided for @tagComeback.
  ///
  /// In ko, this message translates to:
  /// **'컴백'**
  String get tagComeback;

  /// No description provided for @keyboardSpace.
  ///
  /// In ko, this message translates to:
  /// **'Space'**
  String get keyboardSpace;

  /// No description provided for @keyboardModeKorean.
  ///
  /// In ko, this message translates to:
  /// **'한글'**
  String get keyboardModeKorean;

  /// No description provided for @keyboardModeAbc.
  ///
  /// In ko, this message translates to:
  /// **'ABC'**
  String get keyboardModeAbc;

  /// No description provided for @keyboardModeNumbers.
  ///
  /// In ko, this message translates to:
  /// **'123'**
  String get keyboardModeNumbers;

  /// No description provided for @keyboardDone.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get keyboardDone;

  /// No description provided for @defaultTranslationLang.
  ///
  /// In ko, this message translates to:
  /// **'en'**
  String get defaultTranslationLang;

  /// No description provided for @bubbleLabel.
  ///
  /// In ko, this message translates to:
  /// **'플로팅 버블'**
  String get bubbleLabel;

  /// No description provided for @bubbleDescription.
  ///
  /// In ko, this message translates to:
  /// **'앱 밖에서도 변환기를 사용합니다'**
  String get bubbleDescription;

  /// No description provided for @bubblePermissionTitle.
  ///
  /// In ko, this message translates to:
  /// **'오버레이 권한 필요'**
  String get bubblePermissionTitle;

  /// No description provided for @bubblePermissionMessage.
  ///
  /// In ko, this message translates to:
  /// **'플로팅 버블을 표시하려면 다른 앱 위에 표시 권한이 필요합니다.'**
  String get bubblePermissionMessage;

  /// No description provided for @bubblePermissionAllow.
  ///
  /// In ko, this message translates to:
  /// **'허용'**
  String get bubblePermissionAllow;

  /// No description provided for @bubblePermissionDeny.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get bubblePermissionDeny;

  /// No description provided for @bubblePermissionDenied.
  ///
  /// In ko, this message translates to:
  /// **'앱 내에서도 모든 기능을 사용할 수 있습니다'**
  String get bubblePermissionDenied;

  /// No description provided for @bubbleBatteryTitle.
  ///
  /// In ko, this message translates to:
  /// **'배터리 최적화 해제'**
  String get bubbleBatteryTitle;

  /// No description provided for @bubbleBatteryMessage.
  ///
  /// In ko, this message translates to:
  /// **'버블이 안정적으로 동작하려면 배터리 최적화를 해제해주세요.\n일부 기기에서는 배터리 최적화가 버블을 자동 종료할 수 있습니다.'**
  String get bubbleBatteryMessage;

  /// No description provided for @bubbleBatteryAllow.
  ///
  /// In ko, this message translates to:
  /// **'설정 열기'**
  String get bubbleBatteryAllow;

  /// No description provided for @bubbleBatteryDeny.
  ///
  /// In ko, this message translates to:
  /// **'나중에'**
  String get bubbleBatteryDeny;

  /// No description provided for @miniConverterTitle.
  ///
  /// In ko, this message translates to:
  /// **'Fangeul'**
  String get miniConverterTitle;

  /// No description provided for @miniTabPhrases.
  ///
  /// In ko, this message translates to:
  /// **'문구'**
  String get miniTabPhrases;

  /// No description provided for @miniTabFavorites.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기'**
  String get miniTabFavorites;

  /// No description provided for @miniTabRecent.
  ///
  /// In ko, this message translates to:
  /// **'최근'**
  String get miniTabRecent;

  /// No description provided for @miniChipFavorites.
  ///
  /// In ko, this message translates to:
  /// **'★즐찾'**
  String get miniChipFavorites;

  /// No description provided for @miniChipToday.
  ///
  /// In ko, this message translates to:
  /// **'오늘'**
  String get miniChipToday;

  /// No description provided for @miniPackLocked.
  ///
  /// In ko, this message translates to:
  /// **'이 팩은 잠겨있습니다\n곧 해금할 수 있어요!'**
  String get miniPackLocked;

  /// No description provided for @miniPackEmpty.
  ///
  /// In ko, this message translates to:
  /// **'문구가 없습니다'**
  String get miniPackEmpty;

  /// No description provided for @miniOpenConverter.
  ///
  /// In ko, this message translates to:
  /// **'변환기 열기'**
  String get miniOpenConverter;

  /// No description provided for @miniBackToCompact.
  ///
  /// In ko, this message translates to:
  /// **'간편모드'**
  String get miniBackToCompact;

  /// No description provided for @miniFavoritesEmpty.
  ///
  /// In ko, this message translates to:
  /// **'문구 화면에서 ⭐ 탭하여\n즐겨찾기를 추가하세요'**
  String get miniFavoritesEmpty;

  /// No description provided for @miniMyIdolEmpty.
  ///
  /// In ko, this message translates to:
  /// **'설정에서 아이돌을 선택하면\n맞춤 문구가 표시됩니다'**
  String get miniMyIdolEmpty;

  /// No description provided for @miniTodayEmpty.
  ///
  /// In ko, this message translates to:
  /// **'오늘은 관련 이벤트가 없습니다'**
  String get miniTodayEmpty;

  /// No description provided for @miniRecentEmpty.
  ///
  /// In ko, this message translates to:
  /// **'아직 복사한 텍스트가 없습니다'**
  String get miniRecentEmpty;

  /// No description provided for @idolSelectTitle.
  ///
  /// In ko, this message translates to:
  /// **'좋아하는 그룹을 선택하세요'**
  String get idolSelectTitle;

  /// No description provided for @idolSelectSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'설정에서 언제든 바꿀 수 있어요'**
  String get idolSelectSubtitle;

  /// No description provided for @idolSelectSkip.
  ///
  /// In ko, this message translates to:
  /// **'나중에 설정하기'**
  String get idolSelectSkip;

  /// No description provided for @idolSelectOther.
  ///
  /// In ko, this message translates to:
  /// **'기타 (직접 입력)'**
  String get idolSelectOther;

  /// No description provided for @idolSelectOtherHint.
  ///
  /// In ko, this message translates to:
  /// **'그룹 이름을 입력하세요'**
  String get idolSelectOtherHint;

  /// No description provided for @idolSelectConfirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get idolSelectConfirm;

  /// No description provided for @idolSettingLabel.
  ///
  /// In ko, this message translates to:
  /// **'마이 아이돌'**
  String get idolSettingLabel;

  /// No description provided for @idolSettingEmpty.
  ///
  /// In ko, this message translates to:
  /// **'아직 선택하지 않았어요'**
  String get idolSettingEmpty;

  /// No description provided for @idolSettingCurrent.
  ///
  /// In ko, this message translates to:
  /// **'현재: {name}'**
  String idolSettingCurrent(String name);

  /// No description provided for @homeGreeting.
  ///
  /// In ko, this message translates to:
  /// **'안녕하세요, {name} 팬님!'**
  String homeGreeting(String name);

  /// No description provided for @idolSettingChange.
  ///
  /// In ko, this message translates to:
  /// **'변경'**
  String get idolSettingChange;

  /// No description provided for @idolMemberHint.
  ///
  /// In ko, this message translates to:
  /// **'멤버 이름 (선택사항)'**
  String get idolMemberHint;

  /// No description provided for @idolMemberLabel.
  ///
  /// In ko, this message translates to:
  /// **'최애 멤버'**
  String get idolMemberLabel;

  /// No description provided for @phrasesMemberChip.
  ///
  /// In ko, this message translates to:
  /// **'♡ {name}'**
  String phrasesMemberChip(String name);

  /// No description provided for @phrasesGroupChip.
  ///
  /// In ko, this message translates to:
  /// **'{name}'**
  String phrasesGroupChip(String name);

  /// No description provided for @phrasesMemberEmpty.
  ///
  /// In ko, this message translates to:
  /// **'멤버 전용 문구가 없습니다'**
  String get phrasesMemberEmpty;

  /// No description provided for @fanPassButton.
  ///
  /// In ko, this message translates to:
  /// **'팬 패스'**
  String get fanPassButton;

  /// No description provided for @fanPassRemaining.
  ///
  /// In ko, this message translates to:
  /// **'({current}/{max})'**
  String fanPassRemaining(int current, int max);

  /// No description provided for @fanPassCooldown.
  ///
  /// In ko, this message translates to:
  /// **'잠시 후 다시 시도하세요'**
  String get fanPassCooldown;

  /// No description provided for @fanPassAdLoading.
  ///
  /// In ko, this message translates to:
  /// **'광고 준비 중...'**
  String get fanPassAdLoading;

  /// No description provided for @fanPassLimitReached.
  ///
  /// In ko, this message translates to:
  /// **'오늘 시청 완료'**
  String get fanPassLimitReached;

  /// No description provided for @fanPassPopupTitle.
  ///
  /// In ko, this message translates to:
  /// **'팬 패스 획득!'**
  String get fanPassPopupTitle;

  /// No description provided for @fanPassPopupConfirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get fanPassPopupConfirm;

  /// No description provided for @fanPassUnlockRemaining.
  ///
  /// In ko, this message translates to:
  /// **'{time} 남음'**
  String fanPassUnlockRemaining(String time);

  /// No description provided for @unlockRemaining.
  ///
  /// In ko, this message translates to:
  /// **'{time} 남음'**
  String unlockRemaining(String time);

  /// No description provided for @unlockMidnightLabel.
  ///
  /// In ko, this message translates to:
  /// **'자정에 만료'**
  String get unlockMidnightLabel;

  /// No description provided for @unlockMidnightExpiry.
  ///
  /// In ko, this message translates to:
  /// **'{time} 남음 (자정에 만료)'**
  String unlockMidnightExpiry(String time);

  /// No description provided for @shopTitle.
  ///
  /// In ko, this message translates to:
  /// **'감성 컬러 팩'**
  String get shopTitle;

  /// No description provided for @shopRestore.
  ///
  /// In ko, this message translates to:
  /// **'구매 복원'**
  String get shopRestore;

  /// No description provided for @shopBuyButton.
  ///
  /// In ko, this message translates to:
  /// **'구매하기'**
  String get shopBuyButton;

  /// No description provided for @shopPurchased.
  ///
  /// In ko, this message translates to:
  /// **'구매 완료'**
  String get shopPurchased;

  /// No description provided for @shopPhraseCount.
  ///
  /// In ko, this message translates to:
  /// **'문구 {count}개'**
  String shopPhraseCount(int count);

  /// No description provided for @shopPronunciationCount.
  ///
  /// In ko, this message translates to:
  /// **'발음 {count}개'**
  String shopPronunciationCount(int count);

  /// No description provided for @shopRestoreSuccess.
  ///
  /// In ko, this message translates to:
  /// **'구매가 복원되었습니다'**
  String get shopRestoreSuccess;

  /// No description provided for @shopRestoreFailed.
  ///
  /// In ko, this message translates to:
  /// **'복원할 구매가 없습니다'**
  String get shopRestoreFailed;

  /// No description provided for @ddayGiftTitle.
  ///
  /// In ko, this message translates to:
  /// **'{eventName} 축하해요!'**
  String ddayGiftTitle(String eventName);

  /// No description provided for @ddayGiftMessage.
  ///
  /// In ko, this message translates to:
  /// **'오늘 하루 모든 콘텐츠가 무료예요'**
  String get ddayGiftMessage;

  /// No description provided for @ddayGiftButton.
  ///
  /// In ko, this message translates to:
  /// **'선물 받기'**
  String get ddayGiftButton;

  /// No description provided for @ttsLimitTitle.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 발음 듣기는 여기까지!'**
  String get ttsLimitTitle;

  /// No description provided for @ttsLimitMessage.
  ///
  /// In ko, this message translates to:
  /// **'내일 다시 {limit}회 들을 수 있어요'**
  String ttsLimitMessage(int limit);

  /// No description provided for @ttsLimitAdButton.
  ///
  /// In ko, this message translates to:
  /// **'팬 패스로 더 듣기'**
  String get ttsLimitAdButton;

  /// No description provided for @conversionTriggerTitle.
  ///
  /// In ko, this message translates to:
  /// **'더 많은 콘텐츠를 즐기세요'**
  String get conversionTriggerTitle;

  /// No description provided for @conversionTriggerMessage.
  ///
  /// In ko, this message translates to:
  /// **'감성 컬러 팩으로\n무제한 해금하고 특별한 경험을 시작하세요'**
  String get conversionTriggerMessage;

  /// No description provided for @conversionTriggerButton.
  ///
  /// In ko, this message translates to:
  /// **'감성 컬러 팩 보기'**
  String get conversionTriggerButton;

  /// No description provided for @conversionTriggerDismiss.
  ///
  /// In ko, this message translates to:
  /// **'나중에'**
  String get conversionTriggerDismiss;

  /// No description provided for @favLimitTitle.
  ///
  /// In ko, this message translates to:
  /// **'좋아하는 문구가 정말 많네요!'**
  String get favLimitTitle;

  /// No description provided for @favLimitMessage.
  ///
  /// In ko, this message translates to:
  /// **'팬 패스로 더 많은 문구를 저장해보세요\n감성 컬러 팩으로 무제한 보관도 가능해요'**
  String get favLimitMessage;

  /// No description provided for @favLimitAdButton.
  ///
  /// In ko, this message translates to:
  /// **'팬 패스 받기'**
  String get favLimitAdButton;

  /// No description provided for @favLimitIapButton.
  ///
  /// In ko, this message translates to:
  /// **'컬러 팩 구경하기'**
  String get favLimitIapButton;

  /// No description provided for @shopPurchaseSuccess.
  ///
  /// In ko, this message translates to:
  /// **'구매 완료! 콘텐츠가 해금되었어요'**
  String get shopPurchaseSuccess;

  /// No description provided for @shopPurchaseFailed.
  ///
  /// In ko, this message translates to:
  /// **'구매에 실패했어요. 다시 시도해주세요'**
  String get shopPurchaseFailed;

  /// No description provided for @shopPurchasePending.
  ///
  /// In ko, this message translates to:
  /// **'결제 처리 중...'**
  String get shopPurchasePending;

  /// No description provided for @honeymoonDaysLeft.
  ///
  /// In ko, this message translates to:
  /// **'무료 체험 {days}일 남음'**
  String honeymoonDaysLeft(int days);
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'en',
        'es',
        'id',
        'ko',
        'pt',
        'th',
        'vi'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return LEn();
    case 'es':
      return LEs();
    case 'id':
      return LId();
    case 'ko':
      return LKo();
    case 'pt':
      return LPt();
    case 'th':
      return LTh();
    case 'vi':
      return LVi();
  }

  throw FlutterError(
      'L.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
