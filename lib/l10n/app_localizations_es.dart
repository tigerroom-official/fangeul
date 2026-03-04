// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class LEs extends L {
  LEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Fangeul';

  @override
  String get appVersion => '0.1.0';

  @override
  String get appLegalese => '© 2026 Tiger Room';

  @override
  String get copied => 'Copiado';

  @override
  String get errorPrefix => 'Error:';

  @override
  String get copyTooltip => 'Copiar';

  @override
  String get favoriteTooltip => 'Favorito';

  @override
  String get complete => 'Listo';

  @override
  String get share => 'Compartir';

  @override
  String streakDays(int streak) {
    return '$streak días seguidos';
  }

  @override
  String get navHome => 'Inicio';

  @override
  String get navConverter => 'Conversor';

  @override
  String get navPhrases => 'Frases';

  @override
  String get dailyCardLoadError => 'No se pudo cargar la tarjeta de hoy';

  @override
  String get converterTitle => 'Conversor';

  @override
  String get converterTabEngToKor => 'Ing->Cor';

  @override
  String get converterTabKorToEng => 'Cor->Ing';

  @override
  String get converterTabRomanize => 'Pronunciación';

  @override
  String get converterHintEngToKor => 'Escribe en inglés (ej: gksrmf)';

  @override
  String get converterHintKorToEng => 'Escribe en coreano (ej: 한글)';

  @override
  String get converterHintRomanize => 'Escribe en coreano (ej: 사랑해요)';

  @override
  String get phrasesTitle => 'Frases';

  @override
  String get phrasesEmpty => 'No hay frases';

  @override
  String get phrasesMyIdolEmpty =>
      'Selecciona tu idol en ajustes\npara ver frases personalizadas';

  @override
  String phrasesMyIdolChip(String name) {
    return '♡ $name';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get appInfoTitle => 'Info de la app';

  @override
  String appInfoSubtitle(String version) {
    return 'Fangeul v$version';
  }

  @override
  String get tagAll => 'Todo';

  @override
  String get tagLove => 'Amor';

  @override
  String get tagCheer => 'Ánimo';

  @override
  String get tagDaily => 'Diario';

  @override
  String get tagGreeting => 'Saludo';

  @override
  String get tagEmotional => 'Emoción';

  @override
  String get tagPraise => 'Elogio';

  @override
  String get tagFandom => 'Fandom';

  @override
  String get tagBirthday => 'Cumpleaños';

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
  String get keyboardDone => 'Listo';

  @override
  String get defaultTranslationLang => 'en';

  @override
  String get bubbleLabel => 'Burbuja flotante';

  @override
  String get bubbleDescription => 'Usa el conversor fuera de la app';

  @override
  String get bubblePermissionTitle => 'Se necesita permiso de superposición';

  @override
  String get bubblePermissionMessage =>
      'Para mostrar la burbuja flotante, se necesita permiso para mostrar sobre otras apps.';

  @override
  String get bubblePermissionAllow => 'Permitir';

  @override
  String get bubblePermissionDeny => 'Cancelar';

  @override
  String get bubblePermissionDenied =>
      'Puedes usar todas las funciones dentro de la app';

  @override
  String get bubbleBatteryTitle => 'Desactivar optimización de batería';

  @override
  String get bubbleBatteryMessage =>
      'Para que la burbuja funcione de forma estable, desactiva la optimización de batería.\nEn algunos dispositivos, la optimización puede cerrar la burbuja automáticamente.';

  @override
  String get bubbleBatteryAllow => 'Abrir ajustes';

  @override
  String get bubbleBatteryDeny => 'Después';

  @override
  String get miniConverterTitle => 'Fangeul';

  @override
  String get miniTabPhrases => 'Frases';

  @override
  String get miniTabFavorites => 'Favoritos';

  @override
  String get miniTabRecent => 'Recientes';

  @override
  String get miniChipFavorites => '★Favs';

  @override
  String get miniChipToday => 'Hoy';

  @override
  String get miniPackLocked =>
      'Este paquete está bloqueado\n¡Pronto podrás desbloquearlo!';

  @override
  String get miniPackEmpty => 'No hay frases';

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
      'Toca ⭐ en la pantalla de frases\npara agregar favoritos';

  @override
  String get miniMyIdolEmpty =>
      'Selecciona tu idol en ajustes\npara ver frases personalizadas';

  @override
  String get miniTodayEmpty => 'No hay eventos relacionados hoy';

  @override
  String get miniRecentEmpty => 'Aún no hay texto copiado';

  @override
  String get idolSelectTitle => 'Elige tu grupo favorito';

  @override
  String get idolSelectSubtitle =>
      'Puedes cambiarlo en cualquier momento en ajustes';

  @override
  String get idolSelectSkip => 'Configurar después';

  @override
  String get idolSelectOther => 'Otro (escribir manualmente)';

  @override
  String get idolSelectOtherHint => 'Escribe el nombre del grupo';

  @override
  String get idolSelectConfirm => 'Confirmar';

  @override
  String get idolSettingLabel => 'Mi idol';

  @override
  String get idolSettingEmpty => 'Aún no seleccionado';

  @override
  String idolSettingCurrent(String name) {
    return 'Actual: $name';
  }

  @override
  String homeGreeting(String name) {
    return '¡Hola, fan de $name!';
  }

  @override
  String get idolSettingChange => 'Cambiar';

  @override
  String get idolMemberHint => 'Nombre del miembro (opcional)';

  @override
  String get idolMemberLabel => 'Mi bias';

  @override
  String phrasesMemberChip(String name) {
    return '♡ $name';
  }

  @override
  String phrasesGroupChip(String name) {
    return '$name';
  }

  @override
  String get phrasesMemberEmpty => 'No hay frases exclusivas del miembro';

  @override
  String get fanPassButton => 'Fan Pass';

  @override
  String fanPassRemaining(int current, int max) {
    return '($current/$max)';
  }

  @override
  String get fanPassCooldown => 'Inténtalo de nuevo en un momento';

  @override
  String get fanPassAdLoading => 'Preparando anuncio...';

  @override
  String get fanPassLimitReached => 'Visualizaciones de hoy completadas';

  @override
  String get fanPassPopupTitle => '¡Fan Pass obtenido!';

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
  String get unlockMidnightLabel => 'Expira a medianoche';

  @override
  String unlockMidnightExpiry(String time) {
    return '$time restante (expira a medianoche)';
  }

  @override
  String get shopTitle => 'Paquetes Color Vibe';

  @override
  String get shopRestore => 'Restaurar compras';

  @override
  String get shopBuyButton => 'Comprar';

  @override
  String get shopPurchased => 'Comprado';

  @override
  String shopPhraseCount(int count) {
    return '$count frases';
  }

  @override
  String shopPronunciationCount(int count) {
    return '$count pronunciaciones';
  }

  @override
  String get shopRestoreSuccess => 'Compras restauradas exitosamente';

  @override
  String get shopRestoreFailed => 'No hay compras para restaurar';

  @override
  String ddayGiftTitle(String eventName) {
    return '¡Felicidades por $eventName!';
  }

  @override
  String get ddayGiftMessage => 'Hoy todo el contenido es gratis';

  @override
  String get ddayGiftButton => 'Recibir regalo';

  @override
  String get ttsLimitTitle => '¡Las pronunciaciones de hoy se acabaron!';

  @override
  String ttsLimitMessage(int limit) {
    return 'Mañana podrás escuchar $limit veces más';
  }

  @override
  String get ttsLimitAdButton => 'Escuchar más con Fan Pass';

  @override
  String get conversionTriggerTitle => 'Disfruta más contenido';

  @override
  String get conversionTriggerMessage =>
      'Desbloquea todo con un Paquete Color Vibe\ny comienza una experiencia especial';

  @override
  String get conversionTriggerButton => 'Ver Paquetes Color Vibe';

  @override
  String get conversionTriggerDismiss => 'Después';

  @override
  String get favLimitTitle => '¡Tienes muchas frases favoritas!';

  @override
  String get favLimitMessage =>
      'Guarda más frases con el Fan Pass\nO desbloquea almacenamiento ilimitado con un Paquete Color Vibe';

  @override
  String get favLimitAdButton => 'Obtener Fan Pass';

  @override
  String get favLimitIapButton => 'Ver Paquetes Color Vibe';

  @override
  String get shopPurchaseSuccess =>
      '¡Compra completada! Contenido desbloqueado';

  @override
  String get shopPurchaseFailed => 'La compra falló. Inténtalo de nuevo';

  @override
  String get shopPurchasePending => 'Procesando pago...';

  @override
  String honeymoonDaysLeft(int days) {
    return '$days días de prueba gratis restantes';
  }
}
