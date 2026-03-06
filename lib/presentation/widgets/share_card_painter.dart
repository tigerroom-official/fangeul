import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:fangeul/core/entities/daily_card.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';

/// 공유 카드 CustomPainter — 1080x1920 PNG 이미지 생성.
///
/// "절제된 임팩트" — 한글이 주인공, 나머지는 조연.
/// [colorScheme]을 통해 테마 색상을 주입받는다 (CustomPainter는 Theme.of 불가).
class ShareCardPainter extends CustomPainter {
  /// Creates a [ShareCardPainter].
  ShareCardPainter({
    required this.card,
    required this.colorScheme,
    required this.translationLang,
  });

  /// 공유할 카드.
  final DailyCard card;

  /// 현재 테마의 ColorScheme.
  final ColorScheme colorScheme;

  /// 번역 언어 코드.
  final String translationLang;

  @override
  void paint(Canvas canvas, Size size) {
    final bgColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;
    final subColor = colorScheme.onSurfaceVariant;

    // 배경
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bgColor,
    );

    // 한글 (중앙, 큰 글씨)
    _drawText(
      canvas,
      card.phrase.ko,
      offset: Offset(size.width / 2, size.height * 0.35),
      fontSize: 80,
      color: textColor,
      fontWeight: FontWeight.w500,
      maxWidth: size.width - 120,
      textAlign: TextAlign.center,
    );

    // 로마자 발음
    final romanColor = colorScheme.primary;
    _drawText(
      canvas,
      card.phrase.roman,
      offset: Offset(size.width / 2, size.height * 0.50),
      fontSize: 32,
      color: romanColor,
      fontWeight: FontWeight.w400,
      maxWidth: size.width - 120,
      textAlign: TextAlign.center,
    );

    // 번역
    final translation = card.phrase.translations[translationLang] ?? '';
    if (translation.isNotEmpty) {
      _drawText(
        canvas,
        translation,
        offset: Offset(size.width / 2, size.height * 0.58),
        fontSize: 28,
        color: subColor,
        fontWeight: FontWeight.w400,
        maxWidth: size.width - 120,
        textAlign: TextAlign.center,
      );
    }

    // 브랜딩 (하단)
    _drawText(
      canvas,
      UiStrings.appName,
      offset: Offset(size.width / 2, size.height * 0.90),
      fontSize: 24,
      color: subColor.withValues(alpha: 0.5),
      fontWeight: FontWeight.w500,
      maxWidth: size.width,
      textAlign: TextAlign.center,
    );
  }

  void _drawText(
    Canvas canvas,
    String text, {
    required Offset offset,
    required double fontSize,
    required Color color,
    required FontWeight fontWeight,
    required double maxWidth,
    TextAlign textAlign = TextAlign.center,
  }) {
    final paragraphStyle = ui.ParagraphStyle(
      textAlign: textAlign,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: 'NotoSansKR',
    );
    final textStyle = ui.TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: 'NotoSansKR',
    );
    final builder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(text);
    final paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: maxWidth));

    final dx = offset.dx - paragraph.width / 2;
    canvas.drawParagraph(paragraph, Offset(dx, offset.dy));
  }

  @override
  bool shouldRepaint(covariant ShareCardPainter oldDelegate) =>
      card != oldDelegate.card ||
      colorScheme != oldDelegate.colorScheme ||
      translationLang != oldDelegate.translationLang;
}

/// 공유 카드를 PNG로 내보내고 시스템 공유를 실행한다.
///
/// 렌더링 실패, 디스크 쓰기 실패 등 예외 시 조용히 실패하고
/// [debugPrint]로 에러를 출력한다. 네이티브 리소스는 항상 해제된다.
Future<void> shareCard({
  required DailyCard card,
  required ColorScheme colorScheme,
  required String translationLang,
}) async {
  const width = 1080;
  const height = 1920;

  ui.Picture? picture;
  ui.Image? image;

  try {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = ShareCardPainter(
      card: card,
      colorScheme: colorScheme,
      translationLang: translationLang,
    );
    painter.paint(canvas, const Size(1080, 1920));

    picture = recorder.endRecording();
    image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) return;

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/fangeul_card_${card.date}.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: '${card.phrase.ko} — ${UiStrings.appName}',
    );
  } catch (e) {
    debugPrint('Share card failed: $e');
  } finally {
    image?.dispose();
    picture?.dispose();
  }
}
