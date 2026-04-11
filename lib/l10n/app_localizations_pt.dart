// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class LPt extends L {
  LPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Fangeul';

  @override
  String get appVersion => '0.1.0';

  @override
  String get appLegalese => '© 2026 Tiger Room';

  @override
  String get copied => 'Copiado';

  @override
  String get errorPrefix => 'Erro:';

  @override
  String get copyTooltip => 'Copiar';

  @override
  String get favoriteTooltip => 'Favorito';

  @override
  String get complete => 'Concluído';

  @override
  String get share => 'Compartilhar';

  @override
  String streakDays(int streak) {
    return '$streak dias seguidos';
  }

  @override
  String get navHome => 'Início';

  @override
  String get navConverter => 'Conversor';

  @override
  String get navPhrases => 'Frases';

  @override
  String get dailyCardLoadError => 'Não foi possível carregar o card de hoje';

  @override
  String get converterTitle => 'Conversor';

  @override
  String get converterTabEngToKor => 'Ing->Kor';

  @override
  String get converterTabKorToEng => 'Kor->Ing';

  @override
  String get converterTabRomanize => 'Pronúncia';

  @override
  String get converterHintEngToKor => 'Digite em inglês (ex: gksrmf)';

  @override
  String get converterHintKorToEng => 'Digite em coreano (ex: 한글)';

  @override
  String get converterHintRomanize => 'Digite em coreano (ex: 사랑해요)';

  @override
  String get converterPaste => 'Colar';

  @override
  String get phrasesTitle => 'Frases';

  @override
  String get phrasesEmpty => 'Nenhuma frase encontrada';

  @override
  String get phrasesMyIdolEmpty =>
      'Selecione seu idol nas configurações\npara ver frases personalizadas';

  @override
  String phrasesMyIdolChip(String name) {
    return '♡ $name';
  }

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get appInfoTitle => 'Sobre o app';

  @override
  String appInfoSubtitle(String version) {
    return 'Fangeul v$version';
  }

  @override
  String get tagAll => 'Todos';

  @override
  String get tagLove => 'Amor';

  @override
  String get tagCheer => 'Torcida';

  @override
  String get tagDaily => 'Cotidiano';

  @override
  String get tagGreeting => 'Saudação';

  @override
  String get tagEmotional => 'Emoção';

  @override
  String get tagPraise => 'Elogio';

  @override
  String get tagFandom => 'Fandom';

  @override
  String get tagBirthday => 'Aniversário';

  @override
  String get tagComeback => 'Comeback';

  @override
  String get keyboardSpace => 'Space';

  @override
  String get keyboardModeKorean => 'Coreano';

  @override
  String get keyboardModeAbc => 'ABC';

  @override
  String get keyboardModeNumbers => '123';

  @override
  String get keyboardDone => 'OK';

  @override
  String get defaultTranslationLang => 'pt';

  @override
  String get bubbleLabel => 'Bolha flutuante';

  @override
  String get bubbleDescription => 'Use o conversor fora do app';

  @override
  String get bubblePermissionTitle => 'Permissão de sobreposição necessária';

  @override
  String get bubblePermissionMessage =>
      'Para exibir a bolha flutuante, é necessário permitir a sobreposição sobre outros apps.';

  @override
  String get bubblePermissionAllow => 'Permitir';

  @override
  String get bubblePermissionDeny => 'Cancelar';

  @override
  String get bubblePermissionDenied =>
      'Você pode usar todos os recursos dentro do app';

  @override
  String get bubbleBatteryTitle => 'Desativar otimização de bateria';

  @override
  String get bubbleBatteryMessage =>
      'Para que a bolha funcione de forma estável, desative a otimização de bateria.\nEm alguns dispositivos, a otimização pode encerrar a bolha automaticamente.';

  @override
  String get bubbleBatteryAllow => 'Abrir configurações';

  @override
  String get bubbleBatteryDeny => 'Depois';

  @override
  String get miniConverterTitle => 'Fangeul';

  @override
  String get miniTabPhrases => 'Frases';

  @override
  String get miniTabFavorites => 'Favoritos';

  @override
  String get miniTabRecent => 'Recentes';

  @override
  String get miniChipFavorites => '★Favs';

  @override
  String get miniChipToday => 'Hoje';

  @override
  String get miniPackLocked =>
      'Este pacote está bloqueado\nEm breve você poderá desbloqueá-lo!';

  @override
  String get miniPackEmpty => 'Nenhuma frase encontrada';

  @override
  String get miniOpenConverter => 'Abrir conversor';

  @override
  String get miniBackToCompact => 'Modo compacto';

  @override
  String get miniMenuOpenApp => 'Abrir App Fangeul';

  @override
  String get miniMenuCloseBubble => 'Ocultar popup';

  @override
  String get miniFavoritesEmpty =>
      'Toque em ⭐ na tela de frases\npara adicionar favoritos';

  @override
  String get miniMyIdolEmpty =>
      'Selecione seu idol nas configurações\npara ver frases personalizadas';

  @override
  String get miniTodayEmpty => 'Nenhum evento relacionado hoje';

  @override
  String get miniRecentEmpty => 'Nenhum texto copiado ainda';

  @override
  String get idolSelectTitle => 'Escolha seu grupo favorito';

  @override
  String get idolSelectSubtitle =>
      'Você pode mudar a qualquer momento nas configurações';

  @override
  String get idolSelectSkip => 'Configurar depois';

  @override
  String get idolSelectOther => 'Outro (digitar manualmente)';

  @override
  String get idolSelectOtherHint => 'Digite o nome do grupo';

  @override
  String get idolSelectConfirm => 'Confirmar';

  @override
  String get idolSettingLabel => 'Meu idol';

  @override
  String get idolSettingEmpty => 'Ainda não selecionado';

  @override
  String idolSettingCurrent(String name) {
    return 'Atual: $name';
  }

  @override
  String homeGreeting(String name) {
    return 'Olá, fã de $name!';
  }

  @override
  String get idolSettingChange => 'Alterar';

  @override
  String get idolMemberHint => 'Nome do membro (opcional)';

  @override
  String get idolMemberLabel => 'Meu bias';

  @override
  String phrasesMemberChip(String name) {
    return '♡ $name';
  }

  @override
  String phrasesGroupChip(String name) {
    return '$name';
  }

  @override
  String get phrasesMemberEmpty => 'Nenhuma frase exclusiva do membro';

  @override
  String get fanPassButton => 'Fan Pass';

  @override
  String fanPassRemaining(int current, int max) {
    return '($current/$max)';
  }

  @override
  String get fanPassCooldown => 'Tente novamente em breve';

  @override
  String get fanPassAdLoading => 'Preparando anúncio...';

  @override
  String get fanPassLimitReached => 'Visualizações de hoje concluídas';

  @override
  String get fanPassPopupTitle => 'Fan Pass obtido!';

  @override
  String get fanPassPopupConfirm => 'OK';

  @override
  String fanPassUnlockRemaining(String time) {
    return '$time restante';
  }

  @override
  String unlockRemaining(String time) {
    return '$time restante';
  }

  @override
  String get unlockMidnightLabel => 'Expira à meia-noite';

  @override
  String unlockMidnightExpiry(String time) {
    return '$time restante (expira à meia-noite)';
  }

  @override
  String get shopRestoreSuccess => 'Compras restauradas com sucesso';

  @override
  String get shopRestoreFailed => 'Nenhuma compra para restaurar';

  @override
  String ddayGiftTitle(String eventName) {
    return 'Parabéns pelo $eventName!';
  }

  @override
  String get ddayGiftMessage => 'Todo o conteúdo é gratuito hoje';

  @override
  String get ddayGiftButton => 'Receber presente';

  @override
  String get ttsLimitTitle => 'Você usou todas as reproduções de hoje';

  @override
  String get ttsLimitBody => 'Volte amanhã para ouvir mais';

  @override
  String ttsLimitRewarded(int count) {
    return 'Assistir anúncio para mais $count';
  }

  @override
  String get ttsLimitIap => 'Desbloquear ilimitado';

  @override
  String ttsLimitMessage(int limit) {
    return 'Amanhã você pode ouvir mais $limit vezes';
  }

  @override
  String get ttsLimitAdButton => 'Ouvir mais com Fan Pass';

  @override
  String get conversionTriggerTitle => 'Aproveite mais conteúdo';

  @override
  String get conversionTriggerMessage =>
      'Personalize seu tema e desbloqueie\nfavoritos ilimitados';

  @override
  String get conversionTriggerButton => 'Ver opções de tema';

  @override
  String get conversionTriggerDismiss => 'Depois';

  @override
  String get favLimitTitle => 'Você tem muitas frases favoritas!';

  @override
  String favLimitMessage(String price) {
    return 'Compre qualquer produto de tema\ne desbloqueie favoritos ilimitados! A partir de $price';
  }

  @override
  String get favLimitButton => 'Desbloquear favoritos ilimitados';

  @override
  String get favLimitOpenApp => 'Desbloquear no app';

  @override
  String get favLimitDismiss => 'Depois';

  @override
  String honeymoonDaysLeft(int days) {
    return '$days dias de teste grátis restantes';
  }

  @override
  String get languageLabel => 'Idioma';

  @override
  String get languageSystem => 'Padrão do sistema';

  @override
  String get reviewLabel => 'Avaliar este app';

  @override
  String get reviewSubtitle =>
      'Sua avaliação ajuda outros fãs a encontrar o Fangeul';

  @override
  String get contactLabel => 'Fale conosco';

  @override
  String get contactSubtitle => 'Reportar bugs ou sugerir recursos';

  @override
  String get settingsThemeColor => 'Cor do tema';

  @override
  String get settingsThemeColorDesc => 'Personalize a cor do app';

  @override
  String get themePickerTitle => 'Cor do tema';

  @override
  String get themePickerSubtitle =>
      'Deixe o app com a sua cara escolhendo uma cor';

  @override
  String get paletteDefault => 'Padrão (Teal)';

  @override
  String get paletteCherryBlossom => 'Flor de cerejeira';

  @override
  String get paletteOcean => 'Oceano';

  @override
  String get paletteForest => 'Floresta';

  @override
  String get paletteSunset => 'Pôr do sol';

  @override
  String get paletteStarryNight => 'Noite estrelada';

  @override
  String get paletteDawn => 'Amanhecer';

  @override
  String get paletteDusk => 'Crepúsculo';

  @override
  String get paletteJewel => 'Joia';

  @override
  String get themePickerCustom => 'Escolha sua própria cor';

  @override
  String get themePickerThemeColor => 'Cor do tema';

  @override
  String get themePickerHue => 'Matiz';

  @override
  String get themePickerSaturation => 'Saturação';

  @override
  String get themePickerLightness => 'Luminosidade';

  @override
  String get themePickerTextColor => 'Cor do texto';

  @override
  String get themePickerTextColorDesc =>
      'Escolha a cor do texto (apenas com seletor livre)';

  @override
  String get themePickerTextColorAuto => 'Contraste auto';

  @override
  String get themePickerPreview => 'Pré-visualização';

  @override
  String get themePickerLocked => 'Desbloquear com Fan Pass';

  @override
  String themePickerPickerLocked(String price) {
    return 'Desbloquear para sempre por $price';
  }

  @override
  String get themePickerUnlockAll => 'Desbloquear todos os temas';

  @override
  String get themePickerUnlockAllDesc =>
      'Assista a um anúncio para desbloquear todas as paletas para sempre';

  @override
  String get themePickerPreviewHint => 'Apenas prévia — compre para aplicar';

  @override
  String get themePickerApplyLocked => 'Compre para aplicar este tema';

  @override
  String get themePickerUndo => 'Desfazer';

  @override
  String get themePickerLowContrast => 'Baixo contraste';

  @override
  String get favoriteLimitReached => 'Limite de favoritos atingido (máx. 5)';

  @override
  String get choeaeColorTitle => 'Minha Cor';

  @override
  String get choeaeColorSubtitle => 'Personalize o app com a sua cor';

  @override
  String get paletteMidnight => 'Meia-noite';

  @override
  String get palettePurpleDream => 'Sonho Roxo';

  @override
  String get paletteOceanBlue => 'Azul Oceano';

  @override
  String get paletteRoseGold => 'Ouro Rosé';

  @override
  String get paletteConcertEncore => 'Encore do Show';

  @override
  String get paletteGoldenHour => 'Hora Dourada';

  @override
  String get paletteNeonNight => 'Noite Neon';

  @override
  String get paletteMintBreeze => 'Brisa de Menta';

  @override
  String get paletteSunsetCafe => 'Café do Pôr do Sol';

  @override
  String get themePickerChroma => 'Croma';

  @override
  String get themePickerTone => 'Tom';

  @override
  String get themePickerHexInput => 'Código de cor';

  @override
  String get themePickerBrightness => 'Brilho';

  @override
  String get themeModeLocked =>
      'O tema personalizado controla o brilho de forma independente';

  @override
  String get themePickerSlots => 'Slots de tema';

  @override
  String get themePickerSlotSave => 'Salvar tema atual';

  @override
  String get themePickerSlotLocked => 'Desbloqueie slots';

  @override
  String get themePickerCustomSaveLocked =>
      'Compre cores personalizadas para salvar este tema';

  @override
  String get themePickerSlotLongPressHint =>
      'Pressione e segure um slot para renomear ou substituir';

  @override
  String get themePickerSlotName => 'Nome do slot';

  @override
  String get themePickerRecommended => 'Recomendado';

  @override
  String get themePickerFreePickerTitle => 'Cor de texto livre';

  @override
  String get iapThemeCustomColor => 'Fundo e texto personalizados';

  @override
  String get iapThemeCustomColorSub =>
      'Tema de cor personalizado · Favoritos ilimitados';

  @override
  String get iapThemeSlots => 'Salvar 3 temas favoritos';

  @override
  String get iapThemeSlotsSub =>
      'Alternância de slots de tema · Favoritos ilimitados';

  @override
  String get iapThemeBundle => 'Pacote completo (24% desc.)';

  @override
  String get iapThemeBundleSave => 'Favoritos ilimitados';

  @override
  String get privacyPolicyLabel => 'Política de Privacidade';

  @override
  String get privacyPolicySubtitle =>
      'Informações que coletamos e como as usamos';

  @override
  String get termsLabel => 'Termos de Serviço';

  @override
  String get termsSubtitle => 'Condições de uso do serviço';

  @override
  String get packBasicLove => 'Amor e Apoio';

  @override
  String get packDailyPack => 'Diário';

  @override
  String get packBirthdayPack => 'Aniversário';

  @override
  String get packComebackPack => 'Comeback';

  @override
  String get iapErrorTitle => 'Não foi possível processar a compra';

  @override
  String get iapErrorBody =>
      'Atualize o app da Play Store para a versão mais recente e tente novamente. Se o problema persistir, entre em contato.';

  @override
  String get iapErrorRetry => 'Tentar novamente';

  @override
  String get iapErrorContact => 'Fale conosco';
}
