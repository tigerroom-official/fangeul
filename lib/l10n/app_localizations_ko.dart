// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class LKo extends L {
  LKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'Fangeul';

  @override
  String get appVersion => '0.1.0';

  @override
  String get appLegalese => '© 2026 Tiger Room';

  @override
  String get copied => '복사되었습니다';

  @override
  String get errorPrefix => '오류:';

  @override
  String get copyTooltip => '복사';

  @override
  String get favoriteTooltip => '즐겨찾기';

  @override
  String get complete => '완료';

  @override
  String get share => '공유';

  @override
  String streakDays(int streak) {
    return '$streak일 연속';
  }

  @override
  String get navHome => '홈';

  @override
  String get navConverter => '변환기';

  @override
  String get navPhrases => '문구';

  @override
  String get dailyCardLoadError => '오늘의 카드를 불러올 수 없습니다';

  @override
  String get converterTitle => '변환기';

  @override
  String get converterTabEngToKor => '영->한';

  @override
  String get converterTabKorToEng => '한->영';

  @override
  String get converterTabRomanize => '발음';

  @override
  String get converterHintEngToKor => '영문을 입력하세요 (예: gksrmf)';

  @override
  String get converterHintKorToEng => '한글을 입력하세요 (예: 한글)';

  @override
  String get converterHintRomanize => '한글을 입력하세요 (예: 사랑해요)';

  @override
  String get phrasesTitle => '문구';

  @override
  String get phrasesEmpty => '문구가 없습니다';

  @override
  String get phrasesMyIdolEmpty => '설정에서 아이돌을 선택하면\n맞춤 문구가 표시됩니다';

  @override
  String phrasesMyIdolChip(String name) {
    return '♡ $name';
  }

  @override
  String get settingsTitle => '설정';

  @override
  String get themeLabel => '테마';

  @override
  String get themeDark => '다크';

  @override
  String get themeLight => '라이트';

  @override
  String get themeSystem => '시스템';

  @override
  String get appInfoTitle => '앱 정보';

  @override
  String appInfoSubtitle(String version) {
    return 'Fangeul v$version';
  }

  @override
  String get tagAll => '전체';

  @override
  String get tagLove => '사랑';

  @override
  String get tagCheer => '응원';

  @override
  String get tagDaily => '일상';

  @override
  String get tagGreeting => '인사';

  @override
  String get tagEmotional => '감정';

  @override
  String get tagPraise => '칭찬';

  @override
  String get tagFandom => '팬덤';

  @override
  String get tagBirthday => '생일';

  @override
  String get tagComeback => '컴백';

  @override
  String get keyboardSpace => 'Space';

  @override
  String get keyboardModeKorean => '한글';

  @override
  String get keyboardModeAbc => 'ABC';

  @override
  String get keyboardModeNumbers => '123';

  @override
  String get keyboardDone => '완료';

  @override
  String get defaultTranslationLang => 'en';

  @override
  String get bubbleLabel => '플로팅 버블';

  @override
  String get bubbleDescription => '앱 밖에서도 변환기를 사용합니다';

  @override
  String get bubblePermissionTitle => '오버레이 권한 필요';

  @override
  String get bubblePermissionMessage => '플로팅 버블을 표시하려면 다른 앱 위에 표시 권한이 필요합니다.';

  @override
  String get bubblePermissionAllow => '허용';

  @override
  String get bubblePermissionDeny => '취소';

  @override
  String get bubblePermissionDenied => '앱 내에서도 모든 기능을 사용할 수 있습니다';

  @override
  String get bubbleBatteryTitle => '배터리 최적화 해제';

  @override
  String get bubbleBatteryMessage =>
      '버블이 안정적으로 동작하려면 배터리 최적화를 해제해주세요.\n일부 기기에서는 배터리 최적화가 버블을 자동 종료할 수 있습니다.';

  @override
  String get bubbleBatteryAllow => '설정 열기';

  @override
  String get bubbleBatteryDeny => '나중에';

  @override
  String get miniConverterTitle => 'Fangeul';

  @override
  String get miniTabPhrases => '문구';

  @override
  String get miniTabFavorites => '즐겨찾기';

  @override
  String get miniTabRecent => '최근';

  @override
  String get miniChipFavorites => '★즐찾';

  @override
  String get miniChipToday => '오늘';

  @override
  String get miniPackLocked => '이 팩은 잠겨있습니다\n곧 해금할 수 있어요!';

  @override
  String get miniPackEmpty => '문구가 없습니다';

  @override
  String get miniOpenConverter => '변환기 열기';

  @override
  String get miniBackToCompact => '간편모드';

  @override
  String get miniMenuOpenApp => 'Fangeul 앱 열기';

  @override
  String get miniMenuCloseBubble => '팝업 숨기기';

  @override
  String get miniFavoritesEmpty => '문구 화면에서 ⭐ 탭하여\n즐겨찾기를 추가하세요';

  @override
  String get miniMyIdolEmpty => '설정에서 아이돌을 선택하면\n맞춤 문구가 표시됩니다';

  @override
  String get miniTodayEmpty => '오늘은 관련 이벤트가 없습니다';

  @override
  String get miniRecentEmpty => '아직 복사한 텍스트가 없습니다';

  @override
  String get idolSelectTitle => '좋아하는 그룹을 선택하세요';

  @override
  String get idolSelectSubtitle => '설정에서 언제든 바꿀 수 있어요';

  @override
  String get idolSelectSkip => '나중에 설정하기';

  @override
  String get idolSelectOther => '기타 (직접 입력)';

  @override
  String get idolSelectOtherHint => '그룹 이름을 입력하세요';

  @override
  String get idolSelectConfirm => '확인';

  @override
  String get idolSettingLabel => '마이 아이돌';

  @override
  String get idolSettingEmpty => '아직 선택하지 않았어요';

  @override
  String idolSettingCurrent(String name) {
    return '현재: $name';
  }

  @override
  String homeGreeting(String name) {
    return '안녕하세요, $name 팬님!';
  }

  @override
  String get idolSettingChange => '변경';

  @override
  String get idolMemberHint => '멤버 이름 (선택사항)';

  @override
  String get idolMemberLabel => '최애 멤버';

  @override
  String phrasesMemberChip(String name) {
    return '♡ $name';
  }

  @override
  String phrasesGroupChip(String name) {
    return '$name';
  }

  @override
  String get phrasesMemberEmpty => '멤버 전용 문구가 없습니다';

  @override
  String get fanPassButton => '팬 패스';

  @override
  String fanPassRemaining(int current, int max) {
    return '($current/$max)';
  }

  @override
  String get fanPassCooldown => '잠시 후 다시 시도하세요';

  @override
  String get fanPassAdLoading => '광고 준비 중...';

  @override
  String get fanPassLimitReached => '오늘 시청 완료';

  @override
  String get fanPassPopupTitle => '팬 패스 획득!';

  @override
  String get fanPassPopupConfirm => '확인';

  @override
  String fanPassUnlockRemaining(String time) {
    return '$time 남음';
  }

  @override
  String unlockRemaining(String time) {
    return '$time 남음';
  }

  @override
  String get unlockMidnightLabel => '자정에 만료';

  @override
  String unlockMidnightExpiry(String time) {
    return '$time 남음 (자정에 만료)';
  }

  @override
  String get shopTitle => '감성 컬러 팩';

  @override
  String get shopRestore => '구매 복원';

  @override
  String get shopBuyButton => '구매하기';

  @override
  String get shopPurchased => '구매 완료';

  @override
  String shopPhraseCount(int count) {
    return '문구 $count개';
  }

  @override
  String shopPronunciationCount(int count) {
    return '발음 $count개';
  }

  @override
  String get shopRestoreSuccess => '구매가 복원되었습니다';

  @override
  String get shopRestoreFailed => '복원할 구매가 없습니다';

  @override
  String ddayGiftTitle(String eventName) {
    return '$eventName 축하해요!';
  }

  @override
  String get ddayGiftMessage => '오늘 하루 모든 콘텐츠가 무료예요';

  @override
  String get ddayGiftButton => '선물 받기';

  @override
  String get ttsLimitTitle => '오늘의 발음 듣기는 여기까지!';

  @override
  String ttsLimitMessage(int limit) {
    return '내일 다시 $limit회 들을 수 있어요';
  }

  @override
  String get ttsLimitAdButton => '팬 패스로 더 듣기';

  @override
  String get conversionTriggerTitle => '더 많은 콘텐츠를 즐기세요';

  @override
  String get conversionTriggerMessage => '감성 컬러 팩으로\n무제한 해금하고 특별한 경험을 시작하세요';

  @override
  String get conversionTriggerButton => '감성 컬러 팩 보기';

  @override
  String get conversionTriggerDismiss => '나중에';

  @override
  String get favLimitTitle => '좋아하는 문구가 정말 많네요!';

  @override
  String get favLimitMessage => '팬 패스로 더 많은 문구를 저장해보세요\n감성 컬러 팩으로 무제한 보관도 가능해요';

  @override
  String get favLimitAdButton => '팬 패스 받기';

  @override
  String get favLimitIapButton => '컬러 팩 구경하기';

  @override
  String get shopPurchaseSuccess => '구매 완료! 콘텐츠가 해금되었어요';

  @override
  String get shopPurchaseFailed => '구매에 실패했어요. 다시 시도해주세요';

  @override
  String get shopPurchasePending => '결제 처리 중...';

  @override
  String honeymoonDaysLeft(int days) {
    return '무료 체험 $days일 남음';
  }

  @override
  String get languageLabel => '언어';

  @override
  String get languageSystem => '시스템 기본';

  @override
  String get reviewLabel => '리뷰 남기기';

  @override
  String get reviewSubtitle => '리뷰는 다른 팬들이 Fangeul을 찾는 데 도움이 돼요';

  @override
  String get contactLabel => '문의하기';

  @override
  String get contactSubtitle => '버그 신고 및 기능 제안';

  @override
  String get settingsThemeColor => '테마 색상';

  @override
  String get settingsThemeColorDesc => '앱 전체 색상을 변경하세요';

  @override
  String get themePickerTitle => '테마 색상';

  @override
  String get themePickerSubtitle => '나만의 색상으로 앱을 꾸며보세요';

  @override
  String get paletteDefault => '기본 (틸)';

  @override
  String get paletteCherryBlossom => '벚꽃';

  @override
  String get paletteOcean => '바다';

  @override
  String get paletteForest => '숲';

  @override
  String get paletteSunset => '노을';

  @override
  String get paletteStarryNight => '별밤';

  @override
  String get paletteDawn => '새벽';

  @override
  String get paletteDusk => '석양';

  @override
  String get paletteJewel => '보석';

  @override
  String get themePickerCustom => '직접 고르기';

  @override
  String get themePickerThemeColor => '테마 색상';

  @override
  String get themePickerHue => '색조';

  @override
  String get themePickerSaturation => '채도';

  @override
  String get themePickerLightness => '밝기';

  @override
  String get themePickerTextColor => '글자색';

  @override
  String get themePickerTextColorDesc => '글자색을 직접 선택하세요 (자유 피커 전용)';

  @override
  String get themePickerTextColorAuto => '자동 대비';

  @override
  String get themePickerPreview => '미리보기';

  @override
  String get themePickerLocked => '팬 패스로 해금';

  @override
  String get themePickerPickerLocked => '₩990으로 영구 해금';

  @override
  String get themePickerUnlockAll => '전체 테마 해금';

  @override
  String get themePickerUnlockAllDesc => '광고 시청으로 모든 테마 팔레트를 영구 해금하세요';

  @override
  String get themePickerPreviewHint => '미리보기 전용 — 구매 후 적용 가능';

  @override
  String get themePickerApplyLocked => '구매 후 적용 가능';

  @override
  String get themePickerUndo => '되돌리기';

  @override
  String get themePickerLowContrast => '낮은 대비';

  @override
  String get favoriteLimitReached => '즐겨찾기 한도에 도달했어요 (최대 5개)';

  @override
  String get choeaeColorTitle => '최애색';

  @override
  String get choeaeColorSubtitle => '나만의 색으로 앱을 꾸며보세요';

  @override
  String get paletteMidnight => '미드나잇';

  @override
  String get palettePurpleDream => '퍼플 드림';

  @override
  String get paletteOceanBlue => '오션 블루';

  @override
  String get paletteRoseGold => '로즈 골드';

  @override
  String get paletteConcertEncore => '콘서트 앙코르';

  @override
  String get paletteGoldenHour => '골든 아워';

  @override
  String get paletteNeonNight => '네온 나잇';

  @override
  String get paletteMintBreeze => '민트 브리즈';

  @override
  String get paletteSunsetCafe => '선셋 카페';

  @override
  String get themePickerChroma => '채도';

  @override
  String get themePickerTone => '명도';

  @override
  String get themePickerSlots => '테마 슬롯';

  @override
  String get themePickerSlotSave => '현재 테마 저장';

  @override
  String get themePickerSlotLocked => '슬롯을 해금하세요';

  @override
  String get themePickerSlotName => '슬롯 이름';

  @override
  String get themePickerRecommended => '추천';

  @override
  String get themePickerFreePickerTitle => '자유 글자색 선택';

  @override
  String get iapThemeCustomColor => '배경·글자색 자유선택';

  @override
  String get iapThemeSlots => '테마 슬롯 3개';

  @override
  String get iapThemeBundle => '전체 번들 (24% 할인)';

  @override
  String get iapThemeBundleSave => '₩480 절약';
}
