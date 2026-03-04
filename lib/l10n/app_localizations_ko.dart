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
}
