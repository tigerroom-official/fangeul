// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class LVi extends L {
  LVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Fangeul';

  @override
  String get appVersion => '0.1.0';

  @override
  String get appLegalese => '© 2026 Tiger Room';

  @override
  String get copied => 'Đã sao chép';

  @override
  String get errorPrefix => 'Lỗi:';

  @override
  String get copyTooltip => 'Sao chép';

  @override
  String get favoriteTooltip => 'Yêu thích';

  @override
  String get complete => 'Hoàn tất';

  @override
  String get share => 'Chia sẻ';

  @override
  String streakDays(int streak) {
    return '$streak ngày liên tiếp';
  }

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navConverter => 'Chuyển đổi';

  @override
  String get navPhrases => 'Câu nói';

  @override
  String get dailyCardLoadError => 'Không thể tải thẻ hôm nay';

  @override
  String get converterTitle => 'Chuyển đổi';

  @override
  String get converterTabEngToKor => 'Anh->Hàn';

  @override
  String get converterTabKorToEng => 'Hàn->Anh';

  @override
  String get converterTabRomanize => 'Phát âm';

  @override
  String get converterHintEngToKor => 'Nhập tiếng Anh (VD: gksrmf)';

  @override
  String get converterHintKorToEng => 'Nhập tiếng Hàn (VD: 한글)';

  @override
  String get converterHintRomanize => 'Nhập tiếng Hàn (VD: 사랑해요)';

  @override
  String get converterPaste => '붙여넣기';

  @override
  String get phrasesTitle => 'Câu nói';

  @override
  String get phrasesEmpty => 'Không có câu nói nào';

  @override
  String get phrasesMyIdolEmpty =>
      'Chọn idol trong cài đặt\nđể xem câu nói dành riêng cho bạn';

  @override
  String phrasesMyIdolChip(String name) {
    return '♡ $name';
  }

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get themeLabel => 'Giao diện';

  @override
  String get themeDark => 'Tối';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeSystem => 'Hệ thống';

  @override
  String get appInfoTitle => 'Thông tin ứng dụng';

  @override
  String appInfoSubtitle(String version) {
    return 'Fangeul v$version';
  }

  @override
  String get tagAll => 'Tất cả';

  @override
  String get tagLove => 'Yêu thương';

  @override
  String get tagCheer => 'Cổ vũ';

  @override
  String get tagDaily => 'Hàng ngày';

  @override
  String get tagGreeting => 'Chào hỏi';

  @override
  String get tagEmotional => 'Cảm xúc';

  @override
  String get tagPraise => 'Khen ngợi';

  @override
  String get tagFandom => 'Fandom';

  @override
  String get tagBirthday => 'Sinh nhật';

  @override
  String get tagComeback => 'Comeback';

  @override
  String get keyboardSpace => 'Space';

  @override
  String get keyboardModeKorean => 'Tiếng Hàn';

  @override
  String get keyboardModeAbc => 'ABC';

  @override
  String get keyboardModeNumbers => '123';

  @override
  String get keyboardDone => 'Xong';

  @override
  String get defaultTranslationLang => 'vi';

  @override
  String get bubbleLabel => 'Bong bóng nổi';

  @override
  String get bubbleDescription => 'Dùng chuyển đổi ngoài ứng dụng';

  @override
  String get bubblePermissionTitle => 'Cần quyền hiển thị chồng lên';

  @override
  String get bubblePermissionMessage =>
      'Để hiển thị bong bóng nổi, cần cho phép hiển thị trên các ứng dụng khác.';

  @override
  String get bubblePermissionAllow => 'Cho phép';

  @override
  String get bubblePermissionDeny => 'Hủy';

  @override
  String get bubblePermissionDenied =>
      'Bạn vẫn có thể dùng tất cả tính năng trong ứng dụng';

  @override
  String get bubbleBatteryTitle => 'Tắt tối ưu hóa pin';

  @override
  String get bubbleBatteryMessage =>
      'Để bong bóng hoạt động ổn định, hãy tắt tối ưu hóa pin.\nTrên một số thiết bị, tối ưu hóa pin có thể tự động tắt bong bóng.';

  @override
  String get bubbleBatteryAllow => 'Mở cài đặt';

  @override
  String get bubbleBatteryDeny => 'Để sau';

  @override
  String get miniConverterTitle => 'Fangeul';

  @override
  String get miniTabPhrases => 'Câu nói';

  @override
  String get miniTabFavorites => 'Yêu thích';

  @override
  String get miniTabRecent => 'Gần đây';

  @override
  String get miniChipFavorites => '★Thích';

  @override
  String get miniChipToday => 'Hôm nay';

  @override
  String get miniPackLocked => 'Gói này đang bị khóa\nBạn sẽ sớm mở khóa được!';

  @override
  String get miniPackEmpty => 'Không có câu nói nào';

  @override
  String get miniOpenConverter => 'Mở chuyển đổi';

  @override
  String get miniBackToCompact => 'Chế độ thu gọn';

  @override
  String get miniMenuOpenApp => 'Mở ứng dụng Fangeul';

  @override
  String get miniMenuCloseBubble => 'Ẩn popup';

  @override
  String get miniFavoritesEmpty =>
      'Nhấn ⭐ ở màn hình câu nói\nđể thêm vào yêu thích';

  @override
  String get miniMyIdolEmpty =>
      'Chọn idol trong cài đặt\nđể xem câu nói dành riêng cho bạn';

  @override
  String get miniTodayEmpty => 'Hôm nay không có sự kiện liên quan';

  @override
  String get miniRecentEmpty => 'Chưa có văn bản nào được sao chép';

  @override
  String get idolSelectTitle => 'Chọn nhóm yêu thích của bạn';

  @override
  String get idolSelectSubtitle =>
      'Bạn có thể thay đổi bất cứ lúc nào trong cài đặt';

  @override
  String get idolSelectSkip => 'Cài đặt sau';

  @override
  String get idolSelectOther => 'Khác (nhập thủ công)';

  @override
  String get idolSelectOtherHint => 'Nhập tên nhóm';

  @override
  String get idolSelectConfirm => 'Xác nhận';

  @override
  String get idolSettingLabel => 'Idol của tôi';

  @override
  String get idolSettingEmpty => 'Chưa chọn';

  @override
  String idolSettingCurrent(String name) {
    return 'Hiện tại: $name';
  }

  @override
  String homeGreeting(String name) {
    return 'Xin chào, fan của $name!';
  }

  @override
  String get idolSettingChange => 'Thay đổi';

  @override
  String get idolMemberHint => 'Tên thành viên (không bắt buộc)';

  @override
  String get idolMemberLabel => 'Bias của tôi';

  @override
  String phrasesMemberChip(String name) {
    return '♡ $name';
  }

  @override
  String phrasesGroupChip(String name) {
    return '$name';
  }

  @override
  String get phrasesMemberEmpty => 'Không có câu nói riêng của thành viên';

  @override
  String get fanPassButton => 'Fan Pass';

  @override
  String fanPassRemaining(int current, int max) {
    return '($current/$max)';
  }

  @override
  String get fanPassCooldown => 'Vui lòng thử lại sau';

  @override
  String get fanPassAdLoading => 'Đang chuẩn bị quảng cáo...';

  @override
  String get fanPassLimitReached => 'Đã xem hết lượt hôm nay';

  @override
  String get fanPassPopupTitle => 'Nhận Fan Pass thành công!';

  @override
  String get fanPassPopupConfirm => 'OK';

  @override
  String fanPassUnlockRemaining(String time) {
    return 'Còn $time';
  }

  @override
  String unlockRemaining(String time) {
    return 'Còn $time';
  }

  @override
  String get unlockMidnightLabel => 'Hết hạn lúc nửa đêm';

  @override
  String unlockMidnightExpiry(String time) {
    return 'Còn $time (hết hạn lúc nửa đêm)';
  }

  @override
  String get shopTitle => 'Gói màu sắc cảm xúc';

  @override
  String get shopRestore => 'Khôi phục mua hàng';

  @override
  String get shopBuyButton => 'Mua';

  @override
  String get shopPurchased => 'Đã mua';

  @override
  String shopPhraseCount(int count) {
    return '$count câu nói';
  }

  @override
  String shopPronunciationCount(int count) {
    return '$count phát âm';
  }

  @override
  String get shopRestoreSuccess => 'Đã khôi phục mua hàng thành công';

  @override
  String get shopRestoreFailed => 'Không có giao dịch nào để khôi phục';

  @override
  String ddayGiftTitle(String eventName) {
    return 'Chúc mừng $eventName!';
  }

  @override
  String get ddayGiftMessage => 'Hôm nay tất cả nội dung đều miễn phí';

  @override
  String get ddayGiftButton => 'Nhận quà';

  @override
  String get ttsLimitTitle => 'Lượt nghe phát âm hôm nay đã hết!';

  @override
  String ttsLimitMessage(int limit) {
    return 'Ngày mai bạn có thể nghe thêm $limit lần';
  }

  @override
  String get ttsLimitAdButton => 'Nghe thêm với Fan Pass';

  @override
  String get conversionTriggerTitle => 'Khám phá thêm nội dung';

  @override
  String get conversionTriggerMessage =>
      'Mở khóa tất cả với gói màu sắc cảm xúc\nvà bắt đầu trải nghiệm đặc biệt';

  @override
  String get conversionTriggerButton => 'Xem gói màu sắc cảm xúc';

  @override
  String get conversionTriggerDismiss => 'Để sau';

  @override
  String get favLimitTitle => 'Bạn có rất nhiều câu nói yêu thích!';

  @override
  String get favLimitMessage =>
      'Mua bất kỳ sản phẩm giao diện nào\nđể mở khóa yêu thích không giới hạn! Từ ₩990';

  @override
  String get favLimitButton => 'Mở khóa yêu thích không giới hạn';

  @override
  String get favLimitOpenApp => 'Mở khóa trong ứng dụng';

  @override
  String get favLimitDismiss => 'Để sau';

  @override
  String get shopPurchaseSuccess => 'Mua thành công! Nội dung đã được mở khóa';

  @override
  String get shopPurchaseFailed => 'Mua thất bại. Vui lòng thử lại';

  @override
  String get shopPurchasePending => 'Đang xử lý thanh toán...';

  @override
  String honeymoonDaysLeft(int days) {
    return 'Còn $days ngày dùng thử miễn phí';
  }

  @override
  String get languageLabel => 'Ngôn ngữ';

  @override
  String get languageSystem => 'Mặc định hệ thống';

  @override
  String get reviewLabel => 'Đánh giá ứng dụng';

  @override
  String get reviewSubtitle => 'Đánh giá giúp fan khác tìm thấy Fangeul';

  @override
  String get contactLabel => 'Liên hệ';

  @override
  String get contactSubtitle => 'Báo lỗi hoặc đề xuất tính năng';

  @override
  String get settingsThemeColor => 'Màu giao diện';

  @override
  String get settingsThemeColorDesc => 'Tùy chỉnh màu sắc ứng dụng';

  @override
  String get themePickerTitle => 'Màu giao diện';

  @override
  String get themePickerSubtitle =>
      'Biến ứng dụng thành của riêng bạn với màu yêu thích';

  @override
  String get paletteDefault => 'Mặc định (Teal)';

  @override
  String get paletteCherryBlossom => 'Hoa anh đào';

  @override
  String get paletteOcean => 'Đại dương';

  @override
  String get paletteForest => 'Rừng xanh';

  @override
  String get paletteSunset => 'Hoàng hôn';

  @override
  String get paletteStarryNight => 'Đêm sao';

  @override
  String get paletteDawn => 'Bình minh';

  @override
  String get paletteDusk => 'Chạng vạng';

  @override
  String get paletteJewel => 'Ngọc quý';

  @override
  String get themePickerCustom => 'Tự chọn màu';

  @override
  String get themePickerThemeColor => 'Màu giao diện';

  @override
  String get themePickerHue => 'Sắc độ';

  @override
  String get themePickerSaturation => 'Độ bão hòa';

  @override
  String get themePickerLightness => 'Độ sáng';

  @override
  String get themePickerTextColor => 'Màu chữ';

  @override
  String get themePickerTextColorDesc =>
      'Chọn màu chữ (chỉ dành cho bộ chọn tự do)';

  @override
  String get themePickerTextColorAuto => 'Tương phản tự động';

  @override
  String get themePickerPreview => 'Xem trước';

  @override
  String get themePickerLocked => 'Mở khóa bằng Fan Pass';

  @override
  String get themePickerPickerLocked => 'Mở khóa vĩnh viễn ₩990';

  @override
  String get themePickerUnlockAll => 'Mở khóa tất cả chủ đề';

  @override
  String get themePickerUnlockAllDesc =>
      'Xem quảng cáo để mở khóa tất cả bảng màu chủ đề vĩnh viễn';

  @override
  String get themePickerPreviewHint => 'Chỉ xem trước — mua để áp dụng';

  @override
  String get themePickerApplyLocked => 'Mua để áp dụng chủ đề này';

  @override
  String get themePickerUndo => 'Hoàn tác';

  @override
  String get themePickerLowContrast => 'Độ tương phản thấp';

  @override
  String get favoriteLimitReached => 'Đã đạt giới hạn yêu thích (tối đa 5)';

  @override
  String get choeaeColorTitle => 'Màu Của Tôi';

  @override
  String get choeaeColorSubtitle => 'Tùy chỉnh ứng dụng với màu sắc của bạn';

  @override
  String get paletteMidnight => 'Nửa Đêm';

  @override
  String get palettePurpleDream => 'Giấc Mơ Tím';

  @override
  String get paletteOceanBlue => 'Xanh Đại Dương';

  @override
  String get paletteRoseGold => 'Vàng Hồng';

  @override
  String get paletteConcertEncore => 'Encore Concert';

  @override
  String get paletteGoldenHour => 'Giờ Vàng';

  @override
  String get paletteNeonNight => 'Đêm Neon';

  @override
  String get paletteMintBreeze => 'Gió Bạc Hà';

  @override
  String get paletteSunsetCafe => 'Quán Hoàng Hôn';

  @override
  String get themePickerChroma => 'Sắc độ';

  @override
  String get themePickerTone => 'Tông màu';

  @override
  String get themePickerHexInput => 'Mã màu';

  @override
  String get themePickerBrightness => 'Độ sáng';

  @override
  String get themeModeLocked => 'Chủ đề tùy chỉnh kiểm soát độ sáng độc lập';

  @override
  String get themePickerSlots => 'Slot chủ đề';

  @override
  String get themePickerSlotSave => 'Lưu chủ đề hiện tại';

  @override
  String get themePickerSlotLocked => 'Mở khóa slot';

  @override
  String get themePickerSlotLongPressHint =>
      'Nhấn giữ slot để đổi tên hoặc ghi đè';

  @override
  String get themePickerSlotName => 'Tên slot';

  @override
  String get themePickerRecommended => 'Gợi ý';

  @override
  String get themePickerFreePickerTitle => 'Chọn màu chữ tùy ý';

  @override
  String get iapThemeCustomColor => 'Nền & chữ tùy chỉnh';

  @override
  String get iapThemeCustomColorSub =>
      'Chủ đề màu tùy chỉnh · Yêu thích không giới hạn';

  @override
  String get iapThemeSlots => 'Lưu 3 chủ đề yêu thích';

  @override
  String get iapThemeSlotsSub =>
      'Chuyển slot chủ đề · Yêu thích không giới hạn';

  @override
  String get iapThemeBundle => 'Gói đầy đủ (giảm 24%)';

  @override
  String get iapThemeBundleSave => 'Tiết kiệm ₩480 · Yêu thích không giới hạn';

  @override
  String get privacyPolicyLabel => 'Chính sách Bảo mật';

  @override
  String get privacyPolicySubtitle =>
      'Thông tin chúng tôi thu thập và cách sử dụng';

  @override
  String get termsLabel => 'Điều khoản Dịch vụ';

  @override
  String get termsSubtitle => 'Điều kiện sử dụng dịch vụ';
}
