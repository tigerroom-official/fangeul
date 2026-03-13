// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class LJa extends L {
  LJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Fangeul';

  @override
  String get appVersion => '0.1.0';

  @override
  String get appLegalese => '© 2026 Tiger Room';

  @override
  String get copied => 'コピーしました';

  @override
  String get errorPrefix => 'エラー:';

  @override
  String get copyTooltip => 'コピー';

  @override
  String get favoriteTooltip => 'お気に入り';

  @override
  String get complete => '完了';

  @override
  String get share => '共有';

  @override
  String streakDays(int streak) {
    return '連続$streak日';
  }

  @override
  String get navHome => 'ホーム';

  @override
  String get navConverter => 'キー変換';

  @override
  String get navPhrases => 'フレーズ';

  @override
  String get dailyCardLoadError => '今日のカードを読み込めませんでした';

  @override
  String get converterTitle => 'キー変換';

  @override
  String get converterTabEngToKor => '英→韓';

  @override
  String get converterTabKorToEng => '韓→英';

  @override
  String get converterTabRomanize => '発音';

  @override
  String get converterHintEngToKor => '英語を入力してください（例: gksrmf）';

  @override
  String get converterHintKorToEng => '韓国語を入力してください（例: 한글）';

  @override
  String get converterHintRomanize => '韓国語を入力してください（例: 사랑해요）';

  @override
  String get converterPaste => 'ペースト';

  @override
  String get phrasesTitle => 'フレーズ';

  @override
  String get phrasesEmpty => 'フレーズがありません';

  @override
  String get phrasesMyIdolEmpty => '設定で推しを選択すると\nあなた向けのフレーズが表示されます';

  @override
  String phrasesMyIdolChip(String name) {
    return '♡ $name';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get themeLabel => 'テーマ';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeSystem => 'システム';

  @override
  String get appInfoTitle => 'アプリ情報';

  @override
  String appInfoSubtitle(String version) {
    return 'Fangeul v$version';
  }

  @override
  String get tagAll => 'すべて';

  @override
  String get tagLove => '愛';

  @override
  String get tagCheer => '応援';

  @override
  String get tagDaily => '日常';

  @override
  String get tagGreeting => 'あいさつ';

  @override
  String get tagEmotional => '感情';

  @override
  String get tagPraise => '称賛';

  @override
  String get tagFandom => 'ファンダム';

  @override
  String get tagBirthday => '誕生日';

  @override
  String get tagComeback => 'カムバ';

  @override
  String get keyboardSpace => 'Space';

  @override
  String get keyboardModeKorean => '韓国語';

  @override
  String get keyboardModeAbc => 'ABC';

  @override
  String get keyboardModeNumbers => '123';

  @override
  String get keyboardDone => '完了';

  @override
  String get defaultTranslationLang => 'ja';

  @override
  String get bubbleLabel => 'フローティングバブル';

  @override
  String get bubbleDescription => 'アプリの外でも変換機能を使えます';

  @override
  String get bubblePermissionTitle => 'オーバーレイ権限が必要です';

  @override
  String get bubblePermissionMessage =>
      'フローティングバブルを表示するには、他のアプリの上に表示する権限が必要です。';

  @override
  String get bubblePermissionAllow => '許可する';

  @override
  String get bubblePermissionDeny => 'キャンセル';

  @override
  String get bubblePermissionDenied => 'アプリ内ですべての機能をご利用いただけます';

  @override
  String get bubbleBatteryTitle => 'バッテリー最適化の無効化';

  @override
  String get bubbleBatteryMessage =>
      'バブルを安定して動作させるため、バッテリー最適化を無効にしてください。\n一部の端末ではバッテリー最適化によりバブルが自動終了する場合があります。';

  @override
  String get bubbleBatteryAllow => '設定を開く';

  @override
  String get bubbleBatteryDeny => 'あとで';

  @override
  String get miniConverterTitle => 'Fangeul';

  @override
  String get miniTabPhrases => 'フレーズ';

  @override
  String get miniTabFavorites => 'お気に入り';

  @override
  String get miniTabRecent => '最近';

  @override
  String get miniChipFavorites => '★お気に入り';

  @override
  String get miniChipToday => '今日';

  @override
  String get miniPackLocked => 'このパックはロックされています\nまもなく解除できるようになります！';

  @override
  String get miniPackEmpty => 'フレーズがありません';

  @override
  String get miniOpenConverter => '変換機能を開く';

  @override
  String get miniBackToCompact => 'コンパクトモード';

  @override
  String get miniMenuOpenApp => 'Fangeulアプリを開く';

  @override
  String get miniMenuCloseBubble => 'ポップアップを閉じる';

  @override
  String get miniFavoritesEmpty => 'フレーズ画面で ⭐ をタップして\nお気に入りに追加しましょう';

  @override
  String get miniMyIdolEmpty => '設定で推しを選択すると\nあなた向けのフレーズが表示されます';

  @override
  String get miniTodayEmpty => '今日に関連するイベントはありません';

  @override
  String get miniRecentEmpty => 'まだコピーしたテキストはありません';

  @override
  String get idolSelectTitle => '推しのグループを選んでください';

  @override
  String get idolSelectSubtitle => '設定からいつでも変更できます';

  @override
  String get idolSelectSkip => 'あとで設定する';

  @override
  String get idolSelectOther => 'その他（直接入力）';

  @override
  String get idolSelectOtherHint => 'グループ名を入力してください';

  @override
  String get idolSelectConfirm => '決定';

  @override
  String get idolSettingLabel => '推しグループ';

  @override
  String get idolSettingEmpty => 'まだ選択されていません';

  @override
  String idolSettingCurrent(String name) {
    return '現在: $name';
  }

  @override
  String homeGreeting(String name) {
    return 'こんにちは、$nameペンさん！';
  }

  @override
  String get idolSettingChange => '変更';

  @override
  String get idolMemberHint => 'メンバー名（任意）';

  @override
  String get idolMemberLabel => '推しメンバー';

  @override
  String phrasesMemberChip(String name) {
    return '♡ $name';
  }

  @override
  String phrasesGroupChip(String name) {
    return '$name';
  }

  @override
  String get phrasesMemberEmpty => 'メンバー専用フレーズがありません';

  @override
  String get fanPassButton => 'ファンパス';

  @override
  String fanPassRemaining(int current, int max) {
    return '($current/$max)';
  }

  @override
  String get fanPassCooldown => 'しばらくしてからお試しください';

  @override
  String get fanPassAdLoading => '広告を準備中...';

  @override
  String get fanPassLimitReached => '今日はこれで終了です';

  @override
  String get fanPassPopupTitle => 'ファンパス獲得！';

  @override
  String get fanPassPopupConfirm => 'OK';

  @override
  String fanPassUnlockRemaining(String time) {
    return '残り$time';
  }

  @override
  String unlockRemaining(String time) {
    return '残り$time';
  }

  @override
  String get unlockMidnightLabel => '深夜0時に終了';

  @override
  String unlockMidnightExpiry(String time) {
    return '残り$time（深夜0時に終了）';
  }

  @override
  String get shopRestoreSuccess => '購入が復元されました';

  @override
  String get shopRestoreFailed => '復元する購入がありません';

  @override
  String ddayGiftTitle(String eventName) {
    return '$eventNameおめでとう！';
  }

  @override
  String get ddayGiftMessage => '今日はすべてのコンテンツが無料です';

  @override
  String get ddayGiftButton => 'ギフトを受け取る';

  @override
  String get ttsLimitTitle => '今日の発音リスニングはここまで！';

  @override
  String ttsLimitMessage(int limit) {
    return '明日また$limit回聴けます';
  }

  @override
  String get ttsLimitAdButton => 'ファンパスでもっと聴く';

  @override
  String get conversionTriggerTitle => 'もっとコンテンツを楽しもう';

  @override
  String get conversionTriggerMessage => '自分だけのテーマをカスタマイズして\nお気に入りも無制限に';

  @override
  String get conversionTriggerButton => 'テーマオプションを見る';

  @override
  String get conversionTriggerDismiss => 'あとで';

  @override
  String get favLimitTitle => 'お気に入りのフレーズがたくさんですね！';

  @override
  String favLimitMessage(String price) {
    return 'テーマパックをひとつ購入するだけで\nお気に入り無制限に！ $priceから';
  }

  @override
  String get favLimitButton => 'お気に入り無制限を解除';

  @override
  String get favLimitOpenApp => 'アプリで解除';

  @override
  String get favLimitDismiss => 'あとで';

  @override
  String honeymoonDaysLeft(int days) {
    return '無料体験 残り$days日';
  }

  @override
  String get languageLabel => '言語';

  @override
  String get languageSystem => 'システムデフォルト';

  @override
  String get reviewLabel => 'アプリを評価する';

  @override
  String get reviewSubtitle => 'レビューは他のペンがFangeulを見つける助けになります';

  @override
  String get contactLabel => 'お問い合わせ';

  @override
  String get contactSubtitle => 'バグ報告や機能のご提案';

  @override
  String get settingsThemeColor => 'テーマカラー';

  @override
  String get settingsThemeColorDesc => 'アプリの色をカスタマイズ';

  @override
  String get themePickerTitle => 'テーマカラー';

  @override
  String get themePickerSubtitle => '自分だけの色でアプリを彩りましょう';

  @override
  String get paletteDefault => 'デフォルト（ティール）';

  @override
  String get paletteCherryBlossom => '桜';

  @override
  String get paletteOcean => '海';

  @override
  String get paletteForest => '森';

  @override
  String get paletteSunset => '夕焼け';

  @override
  String get paletteStarryNight => '星空';

  @override
  String get paletteDawn => '夜明け';

  @override
  String get paletteDusk => '黄昏';

  @override
  String get paletteJewel => '宝石';

  @override
  String get themePickerCustom => '自分で選ぶ';

  @override
  String get themePickerThemeColor => 'テーマカラー';

  @override
  String get themePickerHue => '色相';

  @override
  String get themePickerSaturation => '彩度';

  @override
  String get themePickerLightness => '明度';

  @override
  String get themePickerTextColor => '文字色';

  @override
  String get themePickerTextColorDesc => '文字色を選択できます（カスタムピッカー限定）';

  @override
  String get themePickerTextColorAuto => '自動コントラスト';

  @override
  String get themePickerPreview => 'プレビュー';

  @override
  String get themePickerLocked => 'ファンパスで解除';

  @override
  String themePickerPickerLocked(String price) {
    return '$priceで永久解除';
  }

  @override
  String get themePickerUnlockAll => '全テーマを解除';

  @override
  String get themePickerUnlockAllDesc => '広告を視聴してすべてのテーマパレットを永久解除';

  @override
  String get themePickerPreviewHint => 'プレビューのみ — 購入後に適用できます';

  @override
  String get themePickerApplyLocked => '購入後に適用できます';

  @override
  String get themePickerUndo => '元に戻す';

  @override
  String get themePickerLowContrast => '低コントラスト';

  @override
  String get favoriteLimitReached => 'お気に入り上限に達しました（最大5件）';

  @override
  String get choeaeColorTitle => '推し色';

  @override
  String get choeaeColorSubtitle => '自分だけの色でアプリを彩りましょう';

  @override
  String get paletteMidnight => 'ミッドナイト';

  @override
  String get palettePurpleDream => 'パープルドリーム';

  @override
  String get paletteOceanBlue => 'オーシャンブルー';

  @override
  String get paletteRoseGold => 'ローズゴールド';

  @override
  String get paletteConcertEncore => 'コンサートアンコール';

  @override
  String get paletteGoldenHour => 'ゴールデンアワー';

  @override
  String get paletteNeonNight => 'ネオンナイト';

  @override
  String get paletteMintBreeze => 'ミントブリーズ';

  @override
  String get paletteSunsetCafe => 'サンセットカフェ';

  @override
  String get themePickerChroma => '彩度';

  @override
  String get themePickerTone => 'トーン';

  @override
  String get themePickerHexInput => 'カラーコード';

  @override
  String get themePickerBrightness => '明るさ';

  @override
  String get themeModeLocked => 'カスタムテーマが明るさを個別に管理しています';

  @override
  String get themePickerSlots => 'テーマスロット';

  @override
  String get themePickerSlotSave => '現在のテーマを保存';

  @override
  String get themePickerSlotLocked => 'スロットを解除';

  @override
  String get themePickerSlotLongPressHint => '長押しで名前変更・上書きができます';

  @override
  String get themePickerSlotName => 'スロット名';

  @override
  String get themePickerRecommended => 'おすすめ';

  @override
  String get themePickerFreePickerTitle => 'カスタム文字色';

  @override
  String get iapThemeCustomColor => '背景・文字色カスタム';

  @override
  String get iapThemeCustomColorSub => 'オリジナル色テーマ · お気に入り無制限';

  @override
  String get iapThemeSlots => '推しテーマ3つを保存';

  @override
  String get iapThemeSlotsSub => 'テーマスロット切替 · お気に入り無制限';

  @override
  String get iapThemeBundle => 'フルバンドル（24%オフ）';

  @override
  String get iapThemeBundleSave => 'お気に入り無制限';

  @override
  String get privacyPolicyLabel => 'プライバシーポリシー';

  @override
  String get privacyPolicySubtitle => '収集する情報と利用目的について';

  @override
  String get termsLabel => '利用規約';

  @override
  String get termsSubtitle => 'サービスのご利用条件';
}
