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

/// HSV 기반 글자색 피커 다이얼로그.
///
/// 2D HSV 영역(saturation×value) + hue 바 + hex 입력 + WCAG 대비율 표시.
class TextColorPickerDialog extends StatefulWidget {
  const TextColorPickerDialog({
    super.key,
    required this.backgroundColor,
    this.initialColor,
  });

  final Color backgroundColor;
  final Color? initialColor;

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
  late double _hue; // 0-360
  late double _saturation; // 0-1
  late double _value; // 0-1

  late final TextEditingController _hexController;
  late final FocusNode _hexFocusNode;
  bool _hexEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialColor != null) {
      final hsv = HSVColor.fromColor(widget.initialColor!);
      _hue = hsv.hue;
      _saturation = hsv.saturation;
      _value = hsv.value;
    } else {
      _hue = 0;
      _saturation = 0;
      _value = 0.9;
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

  Color get _currentColor =>
      HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();

  void _onHexChanged(String value) {
    if (value.length != 6) return;
    final parsed = int.tryParse(value, radix: 16);
    if (parsed == null) return;
    final color = Color(0xFF000000 | parsed);
    final hsv = HSVColor.fromColor(color);
    _hexEditing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _hue = hsv.hue;
        _saturation = hsv.saturation;
        _value = hsv.value;
      });
      _hexEditing = false;
    });
  }

  void _syncHexFromPicker() {
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
              Text(
                l.themePickerFreePickerTitle,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              // 프리뷰
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
              // WCAG 대비율
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
              // 2D HSV 영역 (saturation × value)
              SizedBox(
                height: 120,
                child: _TextColorHsvArea(
                  hue: _hue,
                  saturation: _saturation,
                  value: _value,
                  onChanged: (saturation, value) {
                    setState(() {
                      _saturation = saturation;
                      _value = value;
                    });
                    _syncHexFromPicker();
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Hue 바
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
                          _syncHexFromPicker();
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

/// 2D HSV 영역 (saturation × value) — 글자색 피커용.
class _TextColorHsvArea extends StatefulWidget {
  const _TextColorHsvArea({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.onChanged,
  });

  final double hue;
  final double saturation;
  final double value;
  final void Function(double saturation, double value) onChanged;

  @override
  State<_TextColorHsvArea> createState() => _TextColorHsvAreaState();
}

class _TextColorHsvAreaState extends State<_TextColorHsvArea> {
  ui.Image? _cachedImage;
  double? _cachedHue;
  ScrollHoldController? _holdController;

  static const _imgWidth = 96;
  static const _imgHeight = 64;

  @override
  void initState() {
    super.initState();
    _regenerateImage();
  }

  @override
  void didUpdateWidget(_TextColorHsvArea old) {
    super.didUpdateWidget(old);
    if (old.hue != widget.hue) _regenerateImage();
  }

  void _releaseScrollHold() {
    _holdController?.cancel();
    _holdController = null;
  }

  @override
  void dispose() {
    _releaseScrollHold();
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
      final v = 1.0 - y / (height - 1); // 상단=밝음, 하단=어두움
      for (int x = 0; x < width; x++) {
        final s = x / (width - 1); // 좌=무채색, 우=포화
        final argb = HSVColor.fromAHSV(1.0, hue, s, v).toColor().toARGB32();
        final offset = (y * width + x) * 4;
        pixels[offset] = (argb >> 16) & 0xFF;
        pixels[offset + 1] = (argb >> 8) & 0xFF;
        pixels[offset + 2] = argb & 0xFF;
        pixels[offset + 3] = 0xFF;
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

    final saturation = (x / areaSize.width).clamp(0.0, 1.0);
    final value = (1.0 - y / areaSize.height).clamp(0.0, 1.0);

    widget.onChanged(saturation, value);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final areaWidth = constraints.maxWidth;
      final areaHeight = constraints.maxHeight;

      final markerX = widget.saturation * areaWidth;
      final markerY = (1.0 - widget.value) * areaHeight;
      final markerColor = HSVColor.fromAHSV(
        1.0,
        widget.hue,
        widget.saturation,
        widget.value,
      ).toColor();

      return Listener(
        onPointerDown: (_) {
          // 터치 시작 시 부모 스크롤 차단.
          final scrollable = Scrollable.maybeOf(context);
          _holdController = scrollable?.position.hold(() {
            _holdController = null;
          });
        },
        onPointerUp: (_) => _releaseScrollHold(),
        onPointerCancel: (_) => _releaseScrollHold(),
        child: GestureDetector(
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
                      painter: _HsvAreaPainter(cachedImage: _cachedImage),
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
                        color: markerColor,
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
        ),
      );
    });
  }
}

class _HsvAreaPainter extends CustomPainter {
  const _HsvAreaPainter({required this.cachedImage});

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
  bool shouldRepaint(_HsvAreaPainter old) => old.cachedImage != cachedImage;
}
