// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class LId extends L {
  LId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Fangeul';

  @override
  String get appVersion => '0.1.0';

  @override
  String get appLegalese => '© 2026 Tiger Room';

  @override
  String get copied => 'Tersalin';

  @override
  String get errorPrefix => 'Error:';

  @override
  String get copyTooltip => 'Salin';

  @override
  String get favoriteTooltip => 'Favorit';

  @override
  String get complete => 'Selesai';

  @override
  String get share => 'Bagikan';

  @override
  String streakDays(int streak) {
    return '$streak hari berturut-turut';
  }

  @override
  String get navHome => 'Beranda';

  @override
  String get navConverter => 'Konverter';

  @override
  String get navPhrases => 'Frasa';

  @override
  String get dailyCardLoadError => 'Tidak bisa memuat kartu hari ini';

  @override
  String get converterTitle => 'Konverter';

  @override
  String get converterTabEngToKor => 'Ing→Kor';

  @override
  String get converterTabKorToEng => 'Kor→Ing';

  @override
  String get converterTabRomanize => 'Romanisasi';

  @override
  String get converterHintEngToKor =>
      'Ketik dalam bahasa Inggris (cth: gksrmf)';

  @override
  String get converterHintKorToEng => 'Ketik dalam bahasa Korea (cth: 한글)';

  @override
  String get converterHintRomanize => 'Ketik dalam bahasa Korea (cth: 사랑해요)';

  @override
  String get phrasesTitle => 'Frasa';

  @override
  String get phrasesEmpty => 'Tidak ada frasa';

  @override
  String get phrasesMyIdolEmpty =>
      'Pilih idol kamu di Pengaturan\nuntuk melihat frasa khusus';

  @override
  String phrasesMyIdolChip(String name) {
    return '♡ $name';
  }

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeDark => 'Gelap';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get appInfoTitle => 'Info Aplikasi';

  @override
  String appInfoSubtitle(String version) {
    return 'Fangeul v$version';
  }

  @override
  String get tagAll => 'Semua';

  @override
  String get tagLove => 'Cinta';

  @override
  String get tagCheer => 'Semangat';

  @override
  String get tagDaily => 'Harian';

  @override
  String get tagGreeting => 'Sapaan';

  @override
  String get tagEmotional => 'Emosi';

  @override
  String get tagPraise => 'Pujian';

  @override
  String get tagFandom => 'Fandom';

  @override
  String get tagBirthday => 'Ulang Tahun';

  @override
  String get tagComeback => 'Comeback';

  @override
  String get keyboardSpace => 'Space';

  @override
  String get keyboardModeKorean => 'Korea';

  @override
  String get keyboardModeAbc => 'ABC';

  @override
  String get keyboardModeNumbers => '123';

  @override
  String get keyboardDone => 'Selesai';

  @override
  String get defaultTranslationLang => 'id';

  @override
  String get bubbleLabel => 'Bubble Melayang';

  @override
  String get bubbleDescription => 'Gunakan konverter di luar aplikasi';

  @override
  String get bubblePermissionTitle => 'Izin Overlay Diperlukan';

  @override
  String get bubblePermissionMessage =>
      'Untuk menampilkan bubble melayang, kami perlu izin untuk tampil di atas aplikasi lain.';

  @override
  String get bubblePermissionAllow => 'Izinkan';

  @override
  String get bubblePermissionDeny => 'Batal';

  @override
  String get bubblePermissionDenied =>
      'Kamu tetap bisa menggunakan semua fitur di dalam aplikasi';

  @override
  String get bubbleBatteryTitle => 'Nonaktifkan Optimisasi Baterai';

  @override
  String get bubbleBatteryMessage =>
      'Agar bubble berjalan stabil, mohon nonaktifkan optimisasi baterai.\nDi beberapa perangkat, optimisasi baterai bisa menutup bubble secara otomatis.';

  @override
  String get bubbleBatteryAllow => 'Buka Pengaturan';

  @override
  String get bubbleBatteryDeny => 'Nanti';

  @override
  String get miniConverterTitle => 'Fangeul';

  @override
  String get miniTabPhrases => 'Frasa';

  @override
  String get miniTabFavorites => 'Favorit';

  @override
  String get miniTabRecent => 'Terakhir';

  @override
  String get miniChipFavorites => '★Fav';

  @override
  String get miniChipToday => 'Hari ini';

  @override
  String get miniPackLocked => 'Paket ini terkunci\nSegera bisa kamu buka!';

  @override
  String get miniPackEmpty => 'Tidak ada frasa';

  @override
  String get miniOpenConverter => 'Buka Konverter';

  @override
  String get miniBackToCompact => 'Mode Ringkas';

  @override
  String get miniMenuOpenApp => 'Buka Aplikasi Fangeul';

  @override
  String get miniMenuCloseBubble => 'Sembunyikan popup';

  @override
  String get miniFavoritesEmpty =>
      'Ketuk ⭐ pada frasa\nuntuk menambahkan ke favorit';

  @override
  String get miniMyIdolEmpty =>
      'Pilih idol kamu di Pengaturan\nuntuk melihat frasa khusus';

  @override
  String get miniTodayEmpty => 'Tidak ada event hari ini';

  @override
  String get miniRecentEmpty => 'Belum ada teks yang disalin';

  @override
  String get idolSelectTitle => 'Pilih grup favoritmu';

  @override
  String get idolSelectSubtitle =>
      'Kamu bisa mengubahnya kapan saja di Pengaturan';

  @override
  String get idolSelectSkip => 'Atur nanti';

  @override
  String get idolSelectOther => 'Lainnya (ketik sendiri)';

  @override
  String get idolSelectOtherHint => 'Masukkan nama grup';

  @override
  String get idolSelectConfirm => 'Konfirmasi';

  @override
  String get idolSettingLabel => 'Idol Saya';

  @override
  String get idolSettingEmpty => 'Belum dipilih';

  @override
  String idolSettingCurrent(String name) {
    return 'Saat ini: $name';
  }

  @override
  String homeGreeting(String name) {
    return 'Hai, fans $name!';
  }

  @override
  String get idolSettingChange => 'Ubah';

  @override
  String get idolMemberHint => 'Nama member (opsional)';

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
  String get phrasesMemberEmpty => 'Tidak ada frasa khusus member';

  @override
  String get fanPassButton => 'Fan Pass';

  @override
  String fanPassRemaining(int current, int max) {
    return '($current/$max)';
  }

  @override
  String get fanPassCooldown => 'Coba lagi sebentar ya';

  @override
  String get fanPassAdLoading => 'Memuat iklan...';

  @override
  String get fanPassLimitReached => 'Sudah selesai untuk hari ini';

  @override
  String get fanPassPopupTitle => 'Fan Pass diperoleh!';

  @override
  String get fanPassPopupConfirm => 'OK';

  @override
  String fanPassUnlockRemaining(String time) {
    return '$time tersisa';
  }

  @override
  String unlockRemaining(String time) {
    return '$time tersisa';
  }

  @override
  String get unlockMidnightLabel => 'Berakhir tengah malam';

  @override
  String unlockMidnightExpiry(String time) {
    return '$time tersisa (berakhir tengah malam)';
  }

  @override
  String get shopTitle => 'Paket Warna Emosi';

  @override
  String get shopRestore => 'Pulihkan Pembelian';

  @override
  String get shopBuyButton => 'Beli';

  @override
  String get shopPurchased => 'Sudah Dibeli';

  @override
  String shopPhraseCount(int count) {
    return '$count frasa';
  }

  @override
  String shopPronunciationCount(int count) {
    return '$count pelafalan';
  }

  @override
  String get shopRestoreSuccess => 'Pembelian berhasil dipulihkan';

  @override
  String get shopRestoreFailed => 'Tidak ada pembelian yang bisa dipulihkan';

  @override
  String ddayGiftTitle(String eventName) {
    return 'Selamat $eventName!';
  }

  @override
  String get ddayGiftMessage => 'Semua konten gratis hari ini';

  @override
  String get ddayGiftButton => 'Ambil Hadiah';

  @override
  String get ttsLimitTitle => 'Kuota mendengarkan hari ini habis!';

  @override
  String ttsLimitMessage(int limit) {
    return 'Besok kamu bisa mendengarkan $limit kali lagi';
  }

  @override
  String get ttsLimitAdButton => 'Dengar lebih banyak dengan Fan Pass';

  @override
  String get conversionTriggerTitle => 'Nikmati lebih banyak konten';

  @override
  String get conversionTriggerMessage =>
      'Buka semuanya dengan Paket Warna Emosi\ndan mulai pengalaman spesial';

  @override
  String get conversionTriggerButton => 'Lihat Paket Warna Emosi';

  @override
  String get conversionTriggerDismiss => 'Nanti';

  @override
  String get favLimitTitle => 'Wah, kamu suka banyak frasa banget!';

  @override
  String get favLimitMessage =>
      'Simpan lebih banyak frasa dengan Fan Pass\natau simpan tanpa batas dengan Paket Warna Emosi';

  @override
  String get favLimitAdButton => 'Dapatkan Fan Pass';

  @override
  String get favLimitIapButton => 'Lihat Paket Warna Emosi';

  @override
  String get shopPurchaseSuccess => 'Pembelian berhasil! Konten terbuka';

  @override
  String get shopPurchaseFailed => 'Pembelian gagal. Silakan coba lagi';

  @override
  String get shopPurchasePending => 'Memproses pembayaran...';

  @override
  String honeymoonDaysLeft(int days) {
    return '$days hari uji coba gratis tersisa';
  }

  @override
  String get languageLabel => 'Bahasa';

  @override
  String get languageSystem => 'Default sistem';

  @override
  String get reviewLabel => 'Beri rating';

  @override
  String get reviewSubtitle =>
      'Ulasan kamu membantu fans lain menemukan Fangeul';

  @override
  String get contactLabel => 'Hubungi kami';

  @override
  String get contactSubtitle => 'Laporkan bug atau sarankan fitur';

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
}
