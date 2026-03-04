// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class LTh extends L {
  LTh([String locale = 'th']) : super(locale);

  @override
  String get appName => 'Fangeul';

  @override
  String get appVersion => '0.1.0';

  @override
  String get appLegalese => '© 2026 Tiger Room';

  @override
  String get copied => 'คัดลอกแล้ว';

  @override
  String get errorPrefix => 'ข้อผิดพลาด:';

  @override
  String get copyTooltip => 'คัดลอก';

  @override
  String get favoriteTooltip => 'รายการโปรด';

  @override
  String get complete => 'เสร็จ';

  @override
  String get share => 'แชร์';

  @override
  String streakDays(int streak) {
    return 'ต่อเนื่อง $streak วัน';
  }

  @override
  String get navHome => 'หน้าหลัก';

  @override
  String get navConverter => 'แปลงภาษา';

  @override
  String get navPhrases => 'วลี';

  @override
  String get dailyCardLoadError => 'ไม่สามารถโหลดการ์ดวันนี้ได้';

  @override
  String get converterTitle => 'แปลงภาษา';

  @override
  String get converterTabEngToKor => 'อังกฤษ→เกาหลี';

  @override
  String get converterTabKorToEng => 'เกาหลี→อังกฤษ';

  @override
  String get converterTabRomanize => 'คำอ่าน';

  @override
  String get converterHintEngToKor => 'พิมพ์ภาษาอังกฤษ (เช่น gksrmf)';

  @override
  String get converterHintKorToEng => 'พิมพ์ภาษาเกาหลี (เช่น 한글)';

  @override
  String get converterHintRomanize => 'พิมพ์ภาษาเกาหลี (เช่น 사랑해요)';

  @override
  String get phrasesTitle => 'วลี';

  @override
  String get phrasesEmpty => 'ไม่มีวลี';

  @override
  String get phrasesMyIdolEmpty =>
      'เลือกไอดอลในการตั้งค่า\nเพื่อดูวลีที่เหมาะกับคุณ';

  @override
  String phrasesMyIdolChip(String name) {
    return '♡ $name';
  }

  @override
  String get settingsTitle => 'การตั้งค่า';

  @override
  String get themeLabel => 'ธีม';

  @override
  String get themeDark => 'มืด';

  @override
  String get themeLight => 'สว่าง';

  @override
  String get themeSystem => 'ระบบ';

  @override
  String get appInfoTitle => 'ข้อมูลแอป';

  @override
  String appInfoSubtitle(String version) {
    return 'Fangeul v$version';
  }

  @override
  String get tagAll => 'ทั้งหมด';

  @override
  String get tagLove => 'ความรัก';

  @override
  String get tagCheer => 'เชียร์';

  @override
  String get tagDaily => 'ประจำวัน';

  @override
  String get tagGreeting => 'ทักทาย';

  @override
  String get tagEmotional => 'อารมณ์';

  @override
  String get tagPraise => 'ชื่นชม';

  @override
  String get tagFandom => 'แฟนด้อม';

  @override
  String get tagBirthday => 'วันเกิด';

  @override
  String get tagComeback => 'คัมแบ็ก';

  @override
  String get keyboardSpace => 'Space';

  @override
  String get keyboardModeKorean => 'เกาหลี';

  @override
  String get keyboardModeAbc => 'ABC';

  @override
  String get keyboardModeNumbers => '123';

  @override
  String get keyboardDone => 'เสร็จ';

  @override
  String get defaultTranslationLang => 'en';

  @override
  String get bubbleLabel => 'บับเบิลลอย';

  @override
  String get bubbleDescription => 'ใช้ตัวแปลงนอกแอปได้';

  @override
  String get bubblePermissionTitle => 'ต้องการสิทธิ์การแสดงผลทับ';

  @override
  String get bubblePermissionMessage =>
      'เพื่อแสดงบับเบิลลอย จำเป็นต้องได้รับอนุญาตให้แสดงผลทับแอปอื่น';

  @override
  String get bubblePermissionAllow => 'อนุญาต';

  @override
  String get bubblePermissionDeny => 'ยกเลิก';

  @override
  String get bubblePermissionDenied => 'คุณยังสามารถใช้ทุกฟีเจอร์ได้ในแอป';

  @override
  String get bubbleBatteryTitle => 'ปิดการเพิ่มประสิทธิภาพแบตเตอรี่';

  @override
  String get bubbleBatteryMessage =>
      'เพื่อให้บับเบิลทำงานได้เสถียร กรุณาปิดการเพิ่มประสิทธิภาพแบตเตอรี่\nในบางอุปกรณ์ การเพิ่มประสิทธิภาพแบตเตอรี่อาจปิดบับเบิลโดยอัตโนมัติ';

  @override
  String get bubbleBatteryAllow => 'เปิดการตั้งค่า';

  @override
  String get bubbleBatteryDeny => 'ไว้ทีหลัง';

  @override
  String get miniConverterTitle => 'Fangeul';

  @override
  String get miniTabPhrases => 'วลี';

  @override
  String get miniTabFavorites => 'รายการโปรด';

  @override
  String get miniTabRecent => 'ล่าสุด';

  @override
  String get miniChipFavorites => '★โปรด';

  @override
  String get miniChipToday => 'วันนี้';

  @override
  String get miniPackLocked => 'แพ็คนี้ยังล็อกอยู่\nเร็วๆ นี้จะปลดล็อกได้!';

  @override
  String get miniPackEmpty => 'ไม่มีวลี';

  @override
  String get miniOpenConverter => 'เปิดตัวแปลง';

  @override
  String get miniBackToCompact => 'โหมดย่อ';

  @override
  String get miniMenuOpenApp => 'เปิดแอป Fangeul';

  @override
  String get miniMenuCloseBubble => 'ซ่อนป๊อปอัป';

  @override
  String get miniFavoritesEmpty => 'แตะ ⭐ ที่วลี\nเพื่อเพิ่มในรายการโปรด';

  @override
  String get miniMyIdolEmpty =>
      'เลือกไอดอลในการตั้งค่า\nเพื่อดูวลีที่เหมาะกับคุณ';

  @override
  String get miniTodayEmpty => 'ไม่มีอีเวนต์ที่เกี่ยวข้องวันนี้';

  @override
  String get miniRecentEmpty => 'ยังไม่มีข้อความที่คัดลอก';

  @override
  String get idolSelectTitle => 'เลือกกรุ๊ปที่ชอบ';

  @override
  String get idolSelectSubtitle => 'เปลี่ยนได้ทุกเมื่อในการตั้งค่า';

  @override
  String get idolSelectSkip => 'ตั้งค่าทีหลัง';

  @override
  String get idolSelectOther => 'อื่นๆ (พิมพ์เอง)';

  @override
  String get idolSelectOtherHint => 'ใส่ชื่อกรุ๊ป';

  @override
  String get idolSelectConfirm => 'ยืนยัน';

  @override
  String get idolSettingLabel => 'ไอดอลของฉัน';

  @override
  String get idolSettingEmpty => 'ยังไม่ได้เลือก';

  @override
  String idolSettingCurrent(String name) {
    return 'ตอนนี้: $name';
  }

  @override
  String homeGreeting(String name) {
    return 'สวัสดี แฟน $name!';
  }

  @override
  String get idolSettingChange => 'เปลี่ยน';

  @override
  String get idolMemberHint => 'ชื่อเมมเบอร์ (ไม่บังคับ)';

  @override
  String get idolMemberLabel => 'ไบแอส';

  @override
  String phrasesMemberChip(String name) {
    return '♡ $name';
  }

  @override
  String phrasesGroupChip(String name) {
    return '$name';
  }

  @override
  String get phrasesMemberEmpty => 'ไม่มีวลีเฉพาะเมมเบอร์';

  @override
  String get fanPassButton => 'Fan Pass';

  @override
  String fanPassRemaining(int current, int max) {
    return '($current/$max)';
  }

  @override
  String get fanPassCooldown => 'กรุณาลองใหม่อีกครู่';

  @override
  String get fanPassAdLoading => 'กำลังโหลดโฆษณา...';

  @override
  String get fanPassLimitReached => 'วันนี้ครบแล้ว';

  @override
  String get fanPassPopupTitle => 'ได้รับ Fan Pass แล้ว!';

  @override
  String get fanPassPopupConfirm => 'ตกลง';

  @override
  String fanPassUnlockRemaining(String time) {
    return 'เหลืออีก $time';
  }

  @override
  String unlockRemaining(String time) {
    return 'เหลืออีก $time';
  }

  @override
  String get unlockMidnightLabel => 'หมดอายุตอนเที่ยงคืน';

  @override
  String unlockMidnightExpiry(String time) {
    return 'เหลืออีก $time (หมดอายุตอนเที่ยงคืน)';
  }

  @override
  String get shopTitle => 'แพ็คสีอารมณ์';

  @override
  String get shopRestore => 'กู้คืนการซื้อ';

  @override
  String get shopBuyButton => 'ซื้อ';

  @override
  String get shopPurchased => 'ซื้อแล้ว';

  @override
  String shopPhraseCount(int count) {
    return '$count วลี';
  }

  @override
  String shopPronunciationCount(int count) {
    return '$count คำอ่าน';
  }

  @override
  String get shopRestoreSuccess => 'กู้คืนการซื้อสำเร็จ';

  @override
  String get shopRestoreFailed => 'ไม่พบรายการซื้อที่จะกู้คืน';

  @override
  String ddayGiftTitle(String eventName) {
    return 'สุขสันต์ $eventName!';
  }

  @override
  String get ddayGiftMessage => 'วันนี้คอนเทนต์ทั้งหมดฟรี';

  @override
  String get ddayGiftButton => 'รับของขวัญ';

  @override
  String get ttsLimitTitle => 'หมดโควต้าฟังวันนี้แล้ว!';

  @override
  String ttsLimitMessage(int limit) {
    return 'พรุ่งนี้จะฟังได้อีก $limit ครั้ง';
  }

  @override
  String get ttsLimitAdButton => 'ฟังเพิ่มด้วย Fan Pass';

  @override
  String get conversionTriggerTitle => 'เพลิดเพลินกับคอนเทนต์มากขึ้น';

  @override
  String get conversionTriggerMessage =>
      'ปลดล็อกทั้งหมดด้วยแพ็คสีอารมณ์\nเริ่มต้นประสบการณ์พิเศษ';

  @override
  String get conversionTriggerButton => 'ดูแพ็คสีอารมณ์';

  @override
  String get conversionTriggerDismiss => 'ไว้ทีหลัง';

  @override
  String get favLimitTitle => 'คุณชอบวลีเยอะมากเลย!';

  @override
  String get favLimitMessage =>
      'บันทึกวลีเพิ่มด้วย Fan Pass\nหรือเก็บไม่จำกัดด้วยแพ็คสีอารมณ์';

  @override
  String get favLimitAdButton => 'รับ Fan Pass';

  @override
  String get favLimitIapButton => 'ดูแพ็คสี';

  @override
  String get shopPurchaseSuccess => 'ซื้อสำเร็จ! ปลดล็อกคอนเทนต์แล้ว';

  @override
  String get shopPurchaseFailed => 'การซื้อล้มเหลว กรุณาลองใหม่';

  @override
  String get shopPurchasePending => 'กำลังดำเนินการชำระเงิน...';

  @override
  String honeymoonDaysLeft(int days) {
    return 'ทดลองใช้ฟรีเหลืออีก $days วัน';
  }
}
