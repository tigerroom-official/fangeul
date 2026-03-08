import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart'
    show contrastRatio;

/// 배경색 기반 WCAG 4.5:1 추천 글자색 생성.
///
/// 보색, 유사색, 무채색에서 WCAG 대비율 4.5:1을 만족하는 후보를 반환한다.
List<Color> suggestTextColors(Color background) {
  final bgHct = Hct.fromInt(background.toARGB32());
  final isDark = bgHct.tone < 50;
  final baseTone = isDark ? 90.0 : 10.0;

  final rawCandidates = <Hct>[
    // 보색
    Hct.from((bgHct.hue + 180) % 360, 30, baseTone),
    // 유사색 ±30
    Hct.from((bgHct.hue + 30) % 360, 20, baseTone),
    Hct.from((bgHct.hue + 330) % 360, 20, baseTone),
    // 같은 hue, 대비 tone
    Hct.from(bgHct.hue, 16, baseTone),
    // 무채색
    Hct.from(0, 0, isDark ? 95.0 : 5.0),
    Hct.from(0, 0, isDark ? 85.0 : 15.0),
    // 순백/순흑
    Hct.from(0, 0, isDark ? 100.0 : 0.0),
  ];

  final candidates = <Color>[];
  for (final hct in rawCandidates) {
    final color = Color(hct.toInt());
    if (contrastRatio(color, background) >= 4.5) {
      // 중복 방지 (비슷한 색상)
      final isDuplicate = candidates.any(
        (c) => _colorDistance(c, color) < 20,
      );
      if (!isDuplicate) candidates.add(color);
    }
  }
  return candidates.take(5).toList();
}

double _colorDistance(Color a, Color b) {
  final dr = ((a.r - b.r) * 255);
  final dg = ((a.g - b.g) * 255);
  final db = ((a.b - b.b) * 255);
  return math.sqrt(dr * dr + dg * dg + db * db);
}

/// HCT 기반 경량 글자색 피커 다이얼로그.
///
/// hue 바 + tone 슬라이더 + 실시간 프리뷰 + WCAG 대비율 표시.
class TextColorPickerDialog extends StatefulWidget {
  const TextColorPickerDialog({
    super.key,
    required this.backgroundColor,
    this.initialColor,
  });

  /// 대비율 계산용 배경색.
  final Color backgroundColor;

  /// 초기 글자색 (null이면 흰색으로 시작).
  final Color? initialColor;

  /// 다이얼로그를 표시하고 선택된 색상을 반환한다.
  static Future<Color?> show(
    BuildContext context, {
    required Color backgroundColor,
    Color? initialColor,
  }) {
    return showDialog<Color>(
      context: context,
      builder: (_) => TextColorPickerDialog(
        backgroundColor: backgroundColor,
        initialColor: initialColor,
      ),
    );
  }

  @override
  State<TextColorPickerDialog> createState() => _TextColorPickerDialogState();
}

class _TextColorPickerDialogState extends State<TextColorPickerDialog> {
  late double _hue;
  late double _tone;
  late double _chroma;

  late final TextEditingController _hexController;
  late final FocusNode _hexFocusNode;
  bool _hexEditing = false; // hex→slider 동기화 루프 방지

  @override
  void initState() {
    super.initState();
    if (widget.initialColor != null) {
      final hct = Hct.fromInt(widget.initialColor!.toARGB32());
      _hue = hct.hue;
      _tone = hct.tone.clamp(0.0, 100.0);
      _chroma = hct.chroma.clamp(10.0, 100.0);
    } else {
      _hue = 0;
      _tone = 90;
      _chroma = 20.0;
    }
    _hexController = TextEditingController(
      text: _colorToHex6(_currentColor),
    );
    _hexFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _hexFocusNode.dispose();
    _hexController.dispose();
    super.dispose();
  }

  Color get _currentColor => Color(Hct.from(_hue, _chroma, _tone).toInt());

  /// Hex 입력 → 2D 피커 동기화.
  ///
  /// postFrameCallback으로 defer하여 키보드 이벤트 처리 중 setState 충돌 방지.
  void _onHexChanged(String value) {
    if (value.length != 6) return;
    final parsed = int.tryParse(value, radix: 16);
    if (parsed == null) return;
    final color = Color(0xFF000000 | parsed);
    final hct = Hct.fromInt(color.toARGB32());
    _hexEditing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _hue = hct.hue;
        _chroma = hct.chroma.clamp(10.0, 100.0);
        _tone = hct.tone.clamp(0.0, 100.0);
      });
      _hexEditing = false;
    });
  }

  /// 2D 피커 → hex 입력 동기화.
  void _syncHexFromSliders() {
    if (_hexEditing) return;
    final newText = _colorToHex6(_currentColor);
    if (_hexController.text != newText) {
      _hexController.text = newText;
    }
  }

  static String _colorToHex6(Color c) {
    return (c.toARGB32() & 0x00FFFFFF)
        .toRadixString(16)
        .padLeft(6, '0')
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final theme = Theme.of(context);
    final color = _currentColor;
    final ratio = contrastRatio(color, widget.backgroundColor);

    // WCAG 3-level: AA (>=4.5), AA18 (>=3.0), fail (<3.0)
    final Color wcagColor;
    final IconData wcagIcon;
    final String wcagLabel;
    if (ratio >= 4.5) {
      wcagColor = Colors.green;
      wcagIcon = Icons.check_circle_outline;
      wcagLabel = 'AA';
    } else if (ratio >= 3.0) {
      wcagColor = Colors.orange;
      wcagIcon = Icons.warning_amber_rounded;
      wcagLabel = 'AA18';
    } else {
      wcagColor = theme.colorScheme.error;
      wcagIcon = Icons.error_outline;
      wcagLabel = '';
    }

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 타이틀
              Text(
                l.themePickerFreePickerTitle,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              // 프리뷰 (대비율 <3.0이면 오버레이 표시)
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '가나다라마바사 ABC 123',
                      style: TextStyle(
                        fontFamily: 'NotoSansKR',
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                  ),
                  if (ratio < 3.0)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.visibility_off,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // WCAG 대비율 (3-level)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(wcagIcon, size: 16, color: wcagColor),
                  const SizedBox(width: 4),
                  Text(
                    wcagLabel.isEmpty
                        ? '${ratio.toStringAsFixed(1)}:1'
                        : '$wcagLabel ${ratio.toStringAsFixed(1)}:1',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: wcagColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 2D HCT 영역 (chroma×tone) — 배경 피커와 동일한 시각 경험
              SizedBox(
                height: 120,
                child: _TextColorHctArea(
                  hue: _hue,
                  chroma: _chroma,
                  tone: _tone,
                  onChanged: (chroma, tone) {
                    setState(() {
                      _chroma = chroma;
                      _tone = tone;
                    });
                    _syncHexFromSliders();
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Hue 바 (레인보우)
              SizedBox(
                height: 36,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF0000),
                            Color(0xFFFFFF00),
                            Color(0xFF00FF00),
                            Color(0xFF00FFFF),
                            Color(0xFF0000FF),
                            Color(0xFFFF00FF),
                            Color(0xFFFF0000),
                          ],
                        ),
                      ),
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 0,
                        activeTrackColor: Colors.transparent,
                        inactiveTrackColor: Colors.transparent,
                        thumbColor:
                            HSLColor.fromAHSL(1, _hue, 1, 0.5).toColor(),
                        overlayColor:
                            HSLColor.fromAHSL(0.2, _hue, 1, 0.5).toColor(),
                      ),
                      child: Slider(
                        value: _hue,
                        min: 0,
                        max: 360,
                        onChanged: (v) {
                          setState(() => _hue = v);
                          _syncHexFromSliders();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Hex 입력 + 색상 프리뷰
              Row(
                children: [
                  Text(
                    '#',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _hexController,
                      focusNode: _hexFocusNode,
                      maxLength: 6,
                      // visiblePassword: IME 합성 모드 비활성화 → 키 이벤트 충돌 방지
                      keyboardType: TextInputType.visiblePassword,
                      autocorrect: false,
                      enableSuggestions: false,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        counterText: '',
                        hintText: 'FFD700',
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9a-fA-F]')),
                      ],
                      onChanged: _onHexChanged,
                      onTap: () {
                        // 탭 시 전체 선택 → 백스페이스 없이 바로 덮어쓰기
                        _hexController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _hexController.text.length,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border:
                          Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                        MaterialLocalizations.of(context).cancelButtonLabel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(color),
                    child: Text(l.complete),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 2D HCT 영역 (chroma×tone) — 글자색 피커용.
///
/// 배경 피커의 [_HctAreaPainter]와 동일한 패턴이나,
/// 글자색 특성상 tone 범위를 0~100으로 넓혀 고대비 색상도 선택 가능.
class _TextColorHctArea extends StatefulWidget {
  const _TextColorHctArea({
    required this.hue,
    required this.chroma,
    required this.tone,
    required this.onChanged,
  });

  final double hue;
  final double chroma;
  final double tone;
  final void Function(double chroma, double tone) onChanged;

  @override
  State<_TextColorHctArea> createState() => _TextColorHctAreaState();
}

class _TextColorHctAreaState extends State<_TextColorHctArea> {
  ui.Image? _cachedImage;
  double? _cachedHue;

  static const _imgWidth = 96;
  static const _imgHeight = 64;
  static const _minTone = 0.0;
  static const _maxTone = 100.0;
  static const _toneRange = _maxTone - _minTone;
  static const _minChroma = 0.0;
  static const _maxChroma = 100.0;

  @override
  void initState() {
    super.initState();
    _regenerateImage();
  }

  @override
  void didUpdateWidget(_TextColorHctArea old) {
    super.didUpdateWidget(old);
    if (old.hue != widget.hue) _regenerateImage();
  }

  @override
  void dispose() {
    _cachedImage?.dispose();
    super.dispose();
  }

  void _regenerateImage() {
    if (_cachedHue == widget.hue && _cachedImage != null) return;
    _cachedHue = widget.hue;
    _generateImage(widget.hue, _imgWidth, _imgHeight).then((image) {
      if (!mounted) {
        image.dispose();
        return;
      }
      final old = _cachedImage;
      setState(() => _cachedImage = image);
      old?.dispose();
    });
  }

  static Future<ui.Image> _generateImage(
    double hue,
    int width,
    int height,
  ) {
    final pixels = Uint8List(width * height * 4);
    for (int y = 0; y < height; y++) {
      final tone = _maxTone - (y / (height - 1)) * _toneRange;
      for (int x = 0; x < width; x++) {
        final chroma =
            _minChroma + (x / (width - 1)) * (_maxChroma - _minChroma);
        final argb = Hct.from(hue, chroma, tone).toInt();
        final offset = (y * width + x) * 4;
        pixels[offset] = (argb >> 16) & 0xFF; // R
        pixels[offset + 1] = (argb >> 8) & 0xFF; // G
        pixels[offset + 2] = argb & 0xFF; // B
        pixels[offset + 3] = 0xFF; // A
      }
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  void _onGesture(Offset localPosition, Size areaSize) {
    final x = localPosition.dx.clamp(0.0, areaSize.width);
    final y = localPosition.dy.clamp(0.0, areaSize.height);

    final chroma =
        (_minChroma + (x / areaSize.width) * (_maxChroma - _minChroma))
            .clamp(_minChroma, _maxChroma);
    final tone = (_maxTone - (y / areaSize.height) * _toneRange)
        .clamp(_minTone, _maxTone);

    widget.onChanged(chroma, tone);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final areaWidth = constraints.maxWidth;
      final areaHeight = constraints.maxHeight;

      final markerX =
          ((widget.chroma - _minChroma) / (_maxChroma - _minChroma)) *
              areaWidth;
      final markerY = ((_maxTone - widget.tone) / _toneRange) * areaHeight;

      return GestureDetector(
        onPanDown: (d) =>
            _onGesture(d.localPosition, Size(areaWidth, areaHeight)),
        onPanUpdate: (d) =>
            _onGesture(d.localPosition, Size(areaWidth, areaHeight)),
        child: SizedBox(
          width: areaWidth,
          height: areaHeight,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomPaint(
                    painter: _TextColorAreaPainter(cachedImage: _cachedImage),
                  ),
                ),
              ),
              Positioned(
                left: markerX.clamp(0, areaWidth) - 8,
                top: markerY.clamp(0, areaHeight) - 8,
                child: IgnorePointer(
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(
                          Hct.from(widget.hue, widget.chroma, widget.tone)
                              .toInt()),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// 2D HCT 영역 CustomPainter — 캐시된 이미지를 그린다.
class _TextColorAreaPainter extends CustomPainter {
  const _TextColorAreaPainter({required this.cachedImage});

  final ui.Image? cachedImage;

  @override
  void paint(Canvas canvas, Size size) {
    if (cachedImage == null) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.grey,
      );
      return;
    }

    final src = Rect.fromLTWH(
      0,
      0,
      cachedImage!.width.toDouble(),
      cachedImage!.height.toDouble(),
    );
    canvas.drawImageRect(
      cachedImage!,
      src,
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_TextColorAreaPainter old) =>
      old.cachedImage != cachedImage;
}
