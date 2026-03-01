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
  static const miniPackLocked = '이 팩은 잠겨있습니다\n곧 해금할 수 있어요!';
  static const miniPackEmpty = '문구가 없습니다';
  static const miniOpenConverter = '변환기 열기';
  static const miniBackToCompact = '간편모드';
  static const miniFavoritesEmpty = '문구 화면에서 ⭐ 탭하여\n즐겨찾기를 추가하세요';
  static const miniRecentEmpty = '아직 복사한 텍스트가 없습니다';
}
