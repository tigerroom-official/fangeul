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
}
