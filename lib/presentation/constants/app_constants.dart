/// 앱 전역 상수 — URL, 이메일, 패키지명 등.
///
/// 하드코딩 방지. 변경 시 이 파일만 수정하면 전체 앱에 반영된다.
abstract final class AppConstants {
  /// 지원 이메일 주소.
  static const supportEmail = 'tigerroom.official@gmail.com';

  /// 지원 이메일 mailto URI.
  static final supportEmailUri = Uri.parse('mailto:$supportEmail');

  /// 개인정보처리방침 URL.
  static const privacyPolicyUrl =
      'https://tigerroom-official.github.io/fangeul/privacy-policy.html';

  /// 이용약관 URL.
  static const termsUrl =
      'https://tigerroom-official.github.io/fangeul/terms.html';

  /// TTS CDN 베이스 URL.
  static const ttsCdnBaseUrl = 'https://tts.tigerroom.app/ko';

  /// Google Play 앱 패키지 ID.
  static const packageId = 'com.tigerroom.fangeul';
}
