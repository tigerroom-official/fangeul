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
  String get converterPaste => 'วาง';

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
  String get defaultTranslationLang => 'th';

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
      'ปรับแต่งธีมของคุณ\nและปลดล็อกรายการโปรดไม่จำกัด';

  @override
  String get conversionTriggerButton => 'ดูตัวเลือกธีม';

  @override
  String get conversionTriggerDismiss => 'ไว้ทีหลัง';

  @override
  String get favLimitTitle => 'คุณชอบวลีเยอะมากเลย!';

  @override
  String favLimitMessage(String price) {
    return 'ซื้อสินค้าธีมใดก็ได้\nเพื่อปลดล็อกรายการโปรดไม่จำกัด! เริ่ม $price';
  }

  @override
  String get favLimitButton => 'ปลดล็อกรายการโปรดไม่จำกัด';

  @override
  String get favLimitOpenApp => 'ปลดล็อกในแอป';

  @override
  String get favLimitDismiss => 'ไว้ทีหลัง';

  @override
  String honeymoonDaysLeft(int days) {
    return 'ทดลองใช้ฟรีเหลืออีก $days วัน';
  }

  @override
  String get languageLabel => 'ภาษา';

  @override
  String get languageSystem => 'ค่าเริ่มต้นระบบ';

  @override
  String get reviewLabel => 'ให้คะแนนแอป';

  @override
  String get reviewSubtitle => 'รีวิวของคุณช่วยให้แฟนคนอื่นค้นพบ Fangeul';

  @override
  String get contactLabel => 'ติดต่อเรา';

  @override
  String get contactSubtitle => 'แจ้งบั๊กหรือแนะนำฟีเจอร์';

  @override
  String get settingsThemeColor => 'สีธีม';

  @override
  String get settingsThemeColorDesc => 'เปลี่ยนสีแอปตามใจชอบ';

  @override
  String get themePickerTitle => 'สีธีม';

  @override
  String get themePickerSubtitle => 'ตกแต่งแอปด้วยสีที่คุณชอบ';

  @override
  String get paletteDefault => 'ค่าเริ่มต้น (Teal)';

  @override
  String get paletteCherryBlossom => 'ซากุระ';

  @override
  String get paletteOcean => 'มหาสมุทร';

  @override
  String get paletteForest => 'ป่า';

  @override
  String get paletteSunset => 'พระอาทิตย์ตก';

  @override
  String get paletteStarryNight => 'คืนดาว';

  @override
  String get paletteDawn => 'รุ่งอรุณ';

  @override
  String get paletteDusk => 'สนธยา';

  @override
  String get paletteJewel => 'อัญมณี';

  @override
  String get themePickerCustom => 'เลือกสีเอง';

  @override
  String get themePickerThemeColor => 'สีธีม';

  @override
  String get themePickerHue => 'เฉดสี';

  @override
  String get themePickerSaturation => 'ความอิ่มตัว';

  @override
  String get themePickerLightness => 'ความสว่าง';

  @override
  String get themePickerTextColor => 'สีตัวอักษร';

  @override
  String get themePickerTextColorDesc => 'เลือกสีตัวอักษร (เฉพาะตัวเลือกอิสระ)';

  @override
  String get themePickerTextColorAuto => 'คอนทราสต์อัตโนมัติ';

  @override
  String get themePickerPreview => 'ตัวอย่าง';

  @override
  String get themePickerLocked => 'ปลดล็อกด้วย Fan Pass';

  @override
  String themePickerPickerLocked(String price) {
    return 'ปลดล็อกตลอดกาล $price';
  }

  @override
  String get themePickerUnlockAll => 'ปลดล็อกธีมทั้งหมด';

  @override
  String get themePickerUnlockAllDesc =>
      'ดูโฆษณาเพื่อปลดล็อกพาเลทธีมทั้งหมดตลอดกาล';

  @override
  String get themePickerPreviewHint => 'ตัวอย่างเท่านั้น — ซื้อเพื่อใช้งาน';

  @override
  String get themePickerApplyLocked => 'ซื้อเพื่อใช้ธีมนี้';

  @override
  String get themePickerUndo => 'เลิกทำ';

  @override
  String get themePickerLowContrast => 'คอนทราสต์ต่ำ';

  @override
  String get favoriteLimitReached =>
      'ถึงขีดจำกัดรายการโปรดแล้ว (สูงสุด 5 รายการ)';

  @override
  String get choeaeColorTitle => 'สีของฉัน';

  @override
  String get choeaeColorSubtitle => 'ตกแต่งแอปด้วยสีของคุณ';

  @override
  String get paletteMidnight => 'มิดไนท์';

  @override
  String get palettePurpleDream => 'เพอร์เพิลดรีม';

  @override
  String get paletteOceanBlue => 'โอเชี่ยนบลู';

  @override
  String get paletteRoseGold => 'โรสโกลด์';

  @override
  String get paletteConcertEncore => 'คอนเสิร์ตอังกอร์';

  @override
  String get paletteGoldenHour => 'โกลเด้นอาวร์';

  @override
  String get paletteNeonNight => 'นีออนไนท์';

  @override
  String get paletteMintBreeze => 'มินต์บรีซ';

  @override
  String get paletteSunsetCafe => 'ซันเซ็ตคาเฟ่';

  @override
  String get themePickerChroma => 'ความอิ่มตัว';

  @override
  String get themePickerTone => 'โทนสี';

  @override
  String get themePickerHexInput => 'รหัสสี';

  @override
  String get themePickerBrightness => 'ความสว่าง';

  @override
  String get themeModeLocked => 'ธีมที่กำหนดเองควบคุมความสว่างอย่างอิสระ';

  @override
  String get themePickerSlots => 'สล็อตธีม';

  @override
  String get themePickerSlotSave => 'บันทึกธีมปัจจุบัน';

  @override
  String get themePickerSlotLocked => 'ปลดล็อกสล็อต';

  @override
  String get themePickerCustomSaveLocked =>
      'ซื้อสีที่กำหนดเองเพื่อบันทึกธีมนี้';

  @override
  String get themePickerSlotLongPressHint =>
      'กดค้างสล็อตเพื่อเปลี่ยนชื่อหรือเขียนทับ';

  @override
  String get themePickerSlotName => 'ชื่อสล็อต';

  @override
  String get themePickerRecommended => 'แนะนำ';

  @override
  String get themePickerFreePickerTitle => 'เลือกสีตัวอักษร';

  @override
  String get iapThemeCustomColor => 'พื้นหลังและตัวอักษรกำหนดเอง';

  @override
  String get iapThemeCustomColorSub => 'ธีมสีกำหนดเอง · รายการโปรดไม่จำกัด';

  @override
  String get iapThemeSlots => 'บันทึก 3 ธีมโปรด';

  @override
  String get iapThemeSlotsSub => 'สลับสล็อตธีม · รายการโปรดไม่จำกัด';

  @override
  String get iapThemeBundle => 'แพ็กเกจเต็ม (ลด 24%)';

  @override
  String get iapThemeBundleSave => 'รายการโปรดไม่จำกัด';

  @override
  String get privacyPolicyLabel => 'นโยบายความเป็นส่วนตัว';

  @override
  String get privacyPolicySubtitle => 'ข้อมูลที่เราเก็บรวบรวมและวิธีการใช้งาน';

  @override
  String get termsLabel => 'เงื่อนไขการให้บริการ';

  @override
  String get termsSubtitle => 'เงื่อนไขการใช้บริการ';

  @override
  String get packBasicLove => 'รักและเชียร์';

  @override
  String get packDailyPack => 'ประจำวัน';

  @override
  String get packBirthdayPack => 'วันเกิด';

  @override
  String get packComebackPack => 'คัมแบ็ก';
}
