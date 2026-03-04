/// UI 문자열 상수.
///
/// 하드코딩 문자열 금지 규칙에 따라 모든 UI 텍스트를 중앙 관리한다.
/// 향후 i18n(easy_localization 등) 도입 시 이 파일을 ARB로 마이그레이션.
abstract final class UiStrings {
  // 앱 전역
  static const appName = 'Fangeul';
  static const appVersion = '0.1.0';
  static const appLegalese = '\u00a9 2026 Tiger Room';

  // 공통
  static const copied = '복사되었습니다';
  static const errorPrefix = '오류:';
  static const copyTooltip = '복사';
  static const favoriteTooltip = '즐겨찾기';
  static const complete = '완료';
  static const share = '공유';

  /// 스트릭 일수 표시. 예: '7일 연속'.
  static String streakDays(int streak) => '$streak일 연속';

  // 네비게이션 바
  static const navHome = '홈';
  static const navConverter = '변환기';
  static const navPhrases = '문구';

  // 홈 화면
  static const dailyCardLoadError = '오늘의 카드를 불러올 수 없습니다';

  // 변환기 화면
  static const converterTitle = '변환기';
  static const converterTabEngToKor = '영->한';
  static const converterTabKorToEng = '한->영';
  static const converterTabRomanize = '발음';
  static const converterHintEngToKor = '영문을 입력하세요 (예: gksrmf)';
  static const converterHintKorToEng = '한글을 입력하세요 (예: 한글)';
  static const converterHintRomanize = '한글을 입력하세요 (예: 사랑해요)';

  // 문구 화면
  static const phrasesTitle = '문구';
  static const phrasesEmpty = '문구가 없습니다';

  /// 마이아이돌 문구 빈 상태 메시지.
  static const phrasesMyIdolEmpty = '설정에서 아이돌을 선택하면\n맞춤 문구가 표시됩니다';

  /// 마이아이돌 칩 레이블. 예: '♡ BTS'.
  static String phrasesMyIdolChip(String name) => '♡ $name';

  // 설정 화면
  static const settingsTitle = '설정';
  static const themeLabel = '테마';
  static const themeDark = '다크';
  static const themeLight = '라이트';
  static const themeSystem = '시스템';
  static const appInfoTitle = '앱 정보';
  static const appInfoSubtitle = 'Fangeul v$appVersion';

  // 태그 필터
  static const tagAll = '전체';
  static const tagLove = '사랑';
  static const tagCheer = '응원';
  static const tagDaily = '일상';
  static const tagGreeting = '인사';
  static const tagEmotional = '감정';
  static const tagPraise = '칭찬';
  static const tagFandom = '팬덤';
  static const tagBirthday = '생일';
  static const tagComeback = '컴백';

  // 키보드
  static const keyboardSpace = 'Space';
  static const keyboardModeKorean = '한글';
  static const keyboardModeAbc = 'ABC';
  static const keyboardModeNumbers = '123';
  static const keyboardDone = '완료';

  // 기본 번역 언어
  static const defaultTranslationLang = 'en';

  // 플로팅 버블
  static const bubbleLabel = '플로팅 버블';
  static const bubbleDescription = '앱 밖에서도 변환기를 사용합니다';
  static const bubblePermissionTitle = '오버레이 권한 필요';
  static const bubblePermissionMessage = '플로팅 버블을 표시하려면 다른 앱 위에 표시 권한이 필요합니다.';
  static const bubblePermissionAllow = '허용';
  static const bubblePermissionDeny = '취소';
  static const bubblePermissionDenied = '앱 내에서도 모든 기능을 사용할 수 있습니다';
  static const bubbleBatteryTitle = '배터리 최적화 해제';
  static const bubbleBatteryMessage = '버블이 안정적으로 동작하려면 배터리 최적화를 해제해주세요.\n'
      '일부 기기에서는 배터리 최적화가 버블을 자동 종료할 수 있습니다.';
  static const bubbleBatteryAllow = '설정 열기';
  static const bubbleBatteryDeny = '나중에';

  // 미니 변환기
  static const miniConverterTitle = 'Fangeul';
  static const miniTabPhrases = '문구';
  static const miniTabFavorites = '즐겨찾기';
  static const miniTabRecent = '최근';
  static const miniChipFavorites = '★즐찾';
  static const miniChipToday = '오늘';
  static const miniPackLocked = '이 팩은 잠겨있습니다\n곧 해금할 수 있어요!';
  static const miniPackEmpty = '문구가 없습니다';
  static const miniOpenConverter = '변환기 열기';
  static const miniBackToCompact = '간편모드';
  static const miniFavoritesEmpty = '문구 화면에서 ⭐ 탭하여\n즐겨찾기를 추가하세요';
  static const miniMyIdolEmpty = '설정에서 아이돌을 선택하면\n맞춤 문구가 표시됩니다';
  static const miniTodayEmpty = '오늘은 관련 이벤트가 없습니다';
  static const miniRecentEmpty = '아직 복사한 텍스트가 없습니다';

  // 마이 아이돌
  static const idolSelectTitle = '좋아하는 그룹을 선택하세요';
  static const idolSelectSubtitle = '설정에서 언제든 바꿀 수 있어요';
  static const idolSelectSkip = '나중에 설정하기';
  static const idolSelectOther = '기타 (직접 입력)';
  static const idolSelectOtherHint = '그룹 이름을 입력하세요';
  static const idolSelectConfirm = '확인';
  static const idolSettingLabel = '마이 아이돌';
  static const idolSettingEmpty = '아직 선택하지 않았어요';

  /// 현재 선택된 아이돌 표시. 예: '현재: BTS'.
  static String idolSettingCurrent(String name) => '현재: $name';

  /// 홈 화면 인사말. 예: '안녕하세요, BTS 팬님!'.
  static String homeGreeting(String name) => '안녕하세요, $name 팬님!';
  static const idolSettingChange = '변경';

  // 마이 아이돌 — 멤버
  static const idolMemberHint = '멤버 이름 (선택사항)';
  static const idolMemberLabel = '최애 멤버';

  /// 멤버 칩 레이블. 예: '♡ 정국'.
  static String phrasesMemberChip(String name) => '♡ $name';

  /// 멤버 설정 시 그룹 칩 레이블 (♡ 없음).
  static String phrasesGroupChip(String name) => name;

  static const phrasesMemberEmpty = '멤버 전용 문구가 없습니다';

  // 팬 패스 (보상형 광고)
  static const fanPassButton = '팬 패스';

  /// 남은 시청 횟수. 예: '(1/3)'.
  static String fanPassRemaining(int current, int max) => '($current/$max)';
  static const fanPassCooldown = '잠시 후 다시 시도하세요';
  static const fanPassAdLoading = '광고 준비 중...';
  static const fanPassLimitReached = '오늘 시청 완료';
  static const fanPassPopupTitle = '팬 패스 획득!';
  static const fanPassPopupConfirm = '확인';

  /// 해금 남은 시간. 예: '03:45 남음'.
  static String fanPassUnlockRemaining(String time) => '$time 남음';

  // 해금 타이머
  /// 남은 시간 표시. 예: '3:42:15 남음'.
  static String unlockRemaining(String time) => '$time 남음';

  /// 자정 만료 레이블.
  static const unlockMidnightLabel = '자정에 만료';

  /// 자정 만료 시 남은 시간 표시. 예: '42:15 남음 (자정에 만료)'.
  static String unlockMidnightExpiry(String time) =>
      '$time 남음 ($unlockMidnightLabel)';

  // 샵
  /// 샵 화면 타이틀.
  static const shopTitle = '감성 컬러 팩';

  /// 구매 복원 버튼 레이블.
  static const shopRestore = '구매 복원';

  /// 구매하기 버튼 레이블.
  static const shopBuyButton = '구매하기';

  /// 구매 완료 배지 텍스트.
  static const shopPurchased = '구매 완료';

  /// 문구 개수 표시. 예: '문구 50개'.
  static String shopPhraseCount(int count) => '문구 $count개';

  /// 발음 개수 표시. 예: '발음 30개'.
  static String shopPronunciationCount(int count) => '발음 $count개';

  /// 구매 복원 성공 메시지.
  static const shopRestoreSuccess = '구매가 복원되었습니다';

  /// 구매 복원 실패 메시지.
  static const shopRestoreFailed = '복원할 구매가 없습니다';

  // D-day 선물 팝업

  /// D-day 선물 팝업 제목. 예: '슈가 생일 축하해요!'.
  static String ddayGiftTitle(String eventName) => '$eventName 축하해요!';

  /// D-day 선물 팝업 메시지.
  static const ddayGiftMessage = '오늘 하루 모든 콘텐츠가 무료예요';

  /// D-day 선물 팝업 수락 버튼.
  static const ddayGiftButton = '선물 받기';

  // TTS 제한
  /// TTS 일일 제한 도달 시 다이얼로그 타이틀.
  static const ttsLimitTitle = 'TTS 사용량 소진';

  /// TTS 일일 제한 도달 시 메시지. 예: '오늘 5회 모두 사용했어요'.
  static String ttsLimitMessage(int limit) => '오늘 $limit회 모두 사용했어요';

  /// TTS 제한 다이얼로그 — 보상형 광고 해금 버튼.
  static const ttsLimitAdButton = '팬 패스로 해금';

  // 전환 트리거 팝업
  /// 전환 트리거 팝업 타이틀.
  static const conversionTriggerTitle = '더 많은 콘텐츠를 즐기세요';

  /// 전환 트리거 팝업 메시지.
  static const conversionTriggerMessage =
      '감성 컬러 팩으로\n무제한 해금하고 특별한 경험을 시작하세요';

  /// 전환 트리거 팝업 CTA 버튼.
  static const conversionTriggerButton = '감성 컬러 팩 보기';

  /// 전환 트리거 팝업 닫기 버튼.
  static const conversionTriggerDismiss = '나중에';

  // 즐겨찾기 제한
  /// 즐겨찾기 슬롯 포화 다이얼로그 타이틀.
  static const favLimitTitle = '즐겨찾기가 가득 찼어요';

  /// 즐겨찾기 슬롯 포화 메시지.
  static const favLimitMessage =
      '팬 패스로 임시 해금하거나\n감성 컬러 팩으로 무제한 즐기세요';

  /// 즐겨찾기 제한 — 팬 패스 버튼.
  static const favLimitAdButton = '팬 패스로 해금';

  /// 즐겨찾기 제한 — IAP 버튼.
  static const favLimitIapButton = '감성 컬러 팩 보기';

  // 구매 결과
  /// 구매 성공.
  static const shopPurchaseSuccess = '구매 완료! 콘텐츠가 해금되었어요';

  /// 구매 실패.
  static const shopPurchaseFailed = '구매에 실패했어요. 다시 시도해주세요';

  /// 구매 처리 중.
  static const shopPurchasePending = '결제 처리 중...';

  // 허니문
  /// 허니문 남은 일수 표시. 예: '무료 체험 3일 남음'.
  static String honeymoonDaysLeft(int days) => '무료 체험 $days일 남음';
}
