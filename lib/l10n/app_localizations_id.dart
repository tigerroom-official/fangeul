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
  String get converterPaste => 'Tempel';

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
      'Sesuaikan tema kamu dan buka\nfavorit tak terbatas';

  @override
  String get conversionTriggerButton => 'Lihat opsi tema';

  @override
  String get conversionTriggerDismiss => 'Nanti';

  @override
  String get favLimitTitle => 'Wah, kamu suka banyak frasa banget!';

  @override
  String favLimitMessage(String price) {
    return 'Beli produk tema apa saja untuk\nmembuka favorit tak terbatas! Mulai $price';
  }

  @override
  String get favLimitButton => 'Buka favorit tak terbatas';

  @override
  String get favLimitOpenApp => 'Buka di aplikasi';

  @override
  String get favLimitDismiss => 'Nanti';

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
  String get settingsThemeColor => 'Warna Tema';

  @override
  String get settingsThemeColorDesc => 'Ubah warna aplikasi sesuai keinginanmu';

  @override
  String get themePickerTitle => 'Warna Tema';

  @override
  String get themePickerSubtitle =>
      'Buat aplikasi jadi milikmu dengan warna pilihanmu';

  @override
  String get paletteDefault => 'Default (Teal)';

  @override
  String get paletteCherryBlossom => 'Bunga Sakura';

  @override
  String get paletteOcean => 'Lautan';

  @override
  String get paletteForest => 'Hutan';

  @override
  String get paletteSunset => 'Senja';

  @override
  String get paletteStarryNight => 'Malam Berbintang';

  @override
  String get paletteDawn => 'Fajar';

  @override
  String get paletteDusk => 'Senjamuri';

  @override
  String get paletteJewel => 'Permata';

  @override
  String get themePickerCustom => 'Pilih warnamu sendiri';

  @override
  String get themePickerThemeColor => 'Warna tema';

  @override
  String get themePickerHue => 'Corak';

  @override
  String get themePickerSaturation => 'Saturasi';

  @override
  String get themePickerLightness => 'Kecerahan';

  @override
  String get themePickerTextColor => 'Warna teks';

  @override
  String get themePickerTextColorDesc =>
      'Pilih warna teks (khusus pemilih bebas)';

  @override
  String get themePickerTextColorAuto => 'Kontras otomatis';

  @override
  String get themePickerPreview => 'Pratinjau';

  @override
  String get themePickerLocked => 'Buka dengan Fan Pass';

  @override
  String themePickerPickerLocked(String price) {
    return 'Buka selamanya seharga $price';
  }

  @override
  String get themePickerUnlockAll => 'Buka semua tema';

  @override
  String get themePickerUnlockAllDesc =>
      'Tonton iklan untuk membuka semua palet tema selamanya';

  @override
  String get themePickerPreviewHint => 'Pratinjau saja — beli untuk menerapkan';

  @override
  String get themePickerApplyLocked => 'Beli untuk menerapkan tema ini';

  @override
  String get themePickerUndo => 'Urungkan';

  @override
  String get themePickerLowContrast => 'Kontras rendah';

  @override
  String get favoriteLimitReached => 'Batas favorit tercapai (maks. 5)';

  @override
  String get choeaeColorTitle => 'Warna Saya';

  @override
  String get choeaeColorSubtitle => 'Sesuaikan aplikasi dengan warnamu';

  @override
  String get paletteMidnight => 'Tengah Malam';

  @override
  String get palettePurpleDream => 'Mimpi Ungu';

  @override
  String get paletteOceanBlue => 'Biru Laut';

  @override
  String get paletteRoseGold => 'Rose Gold';

  @override
  String get paletteConcertEncore => 'Encore Konser';

  @override
  String get paletteGoldenHour => 'Jam Emas';

  @override
  String get paletteNeonNight => 'Malam Neon';

  @override
  String get paletteMintBreeze => 'Semilir Mint';

  @override
  String get paletteSunsetCafe => 'Kafe Senja';

  @override
  String get themePickerChroma => 'Kroma';

  @override
  String get themePickerTone => 'Nada';

  @override
  String get themePickerHexInput => 'Kode warna';

  @override
  String get themePickerBrightness => 'Kecerahan';

  @override
  String get themeModeLocked =>
      'Tema kustom mengontrol kecerahan secara mandiri';

  @override
  String get themePickerSlots => 'Slot Tema';

  @override
  String get themePickerSlotSave => 'Simpan tema saat ini';

  @override
  String get themePickerSlotLocked => 'Buka kunci slot';

  @override
  String get themePickerCustomSaveLocked =>
      'Beli warna kustom untuk menyimpan tema ini';

  @override
  String get themePickerSlotLongPressHint =>
      'Tekan lama slot untuk mengganti nama atau menimpa';

  @override
  String get themePickerSlotName => 'Nama slot';

  @override
  String get themePickerRecommended => 'Rekomendasi';

  @override
  String get themePickerFreePickerTitle => 'Warna teks kustom';

  @override
  String get iapThemeCustomColor => 'Latar & teks kustom';

  @override
  String get iapThemeCustomColorSub =>
      'Tema warna kustom · Favorit tak terbatas';

  @override
  String get iapThemeSlots => 'Simpan 3 tema favorit';

  @override
  String get iapThemeSlotsSub => 'Ganti slot tema · Favorit tak terbatas';

  @override
  String get iapThemeBundle => 'Paket lengkap (diskon 24%)';

  @override
  String get iapThemeBundleSave => 'Favorit tak terbatas';

  @override
  String get privacyPolicyLabel => 'Kebijakan Privasi';

  @override
  String get privacyPolicySubtitle =>
      'Informasi yang kami kumpulkan dan cara penggunaannya';

  @override
  String get termsLabel => 'Ketentuan Layanan';

  @override
  String get termsSubtitle => 'Syarat penggunaan layanan';

  @override
  String get packBasicLove => 'Cinta & Dukungan';

  @override
  String get packDailyPack => 'Harian';

  @override
  String get packBirthdayPack => 'Ulang Tahun';

  @override
  String get packComebackPack => 'Comeback';
}
