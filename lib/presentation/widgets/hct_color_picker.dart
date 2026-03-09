import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:fangeul/l10n/app_localizations.dart';

/// 2D HSV 색상 피커 — X=채도, Y=명도, 하단 hue 바 + hex 입력.
///
/// Photoshop/Figma 스타일 2D 영역에서 saturation×value를 선택하고,
/// 하단 hue 바에서 색조를 변경한다. sRGB 전체 색역을 커버한다.
class HctColorPicker extends StatefulWidget {
  const HctColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  @override
  State<HctColorPicker> createState() => _HctColorPickerState();
}

class _HctColorPickerState extends State<HctColorPicker> {
  late double _hue; // 0-360
  late double _saturation; // 0-1
  late double _value; // 0-1
  ui.Image? _cachedImage;
  double? _cachedHue;

  late final TextEditingController _hexController;
  bool _hexEditing = false;

  static const _imgWidth = 128;
  static const _imgHeight = 96;

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.initialColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
    _hexController = TextEditingController(text: _currentHex);
    _regenerateImage();
  }

  @override
  void dispose() {
    _hexController.dispose();
    _cachedImage?.dispose();
    super.dispose();
  }

  Color get _currentColor =>
      HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();

  String get _currentHex {
    final argb = _currentColor.toARGB32();
    return (argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();
  }

  void _onHexChanged(String value) {
    if (value.length != 6) return;
    final parsed = int.tryParse(value, radix: 16);
    if (parsed == null) return;
    final color = Color(0xFF000000 | parsed);
    final hsv = HSVColor.fromColor(color);
    _hexEditing = true;
    setState(() {
      _hue = hsv.hue;
      _saturation = hsv.saturation;
      _value = hsv.value;
    });
    _regenerateImage();
    widget.onColorChanged(color);
    _hexEditing = false;
  }

  void _regenerateImage() {
    if (_cachedHue == _hue && _cachedImage != null) return;
    _cachedHue = _hue;
    _generateHsvImage(_hue, _imgWidth, _imgHeight).then((image) {
      if (!mounted) {
        image.dispose();
        return;
      }
      final old = _cachedImage;
      setState(() => _cachedImage = image);
      old?.dispose();
    });
  }

  /// HSV 2D 이미지: X=saturation(0→1), Y=value(1→0, 상단밝음).
  static Future<ui.Image> _generateHsvImage(
    double hue,
    int width,
    int height,
  ) {
    final pixels = Uint8List(width * height * 4);
    for (int y = 0; y < height; y++) {
      final v = 1.0 - y / (height - 1); // 상단=밝음, 하단=어두움
      for (int x = 0; x < width; x++) {
        final s = x / (width - 1); // 좌=무채색, 우=포화
        final color = HSVColor.fromAHSV(1.0, hue, s, v).toColor();
        final argb = color.toARGB32();
        final offset = (y * width + x) * 4;
        pixels[offset] = (argb >> 16) & 0xFF; // R
        pixels[offset + 1] = (argb >> 8) & 0xFF; // G
        pixels[offset + 2] = argb & 0xFF; // B
        pixels[offset + 3] = 0xFF; // A
      }
    }

    final completer = _ImageCompleter();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  void _onAreaGesture(Offset localPosition, Size areaSize) {
    final x = localPosition.dx.clamp(0.0, areaSize.width);
    final y = localPosition.dy.clamp(0.0, areaSize.height);

    final saturation = (x / areaSize.width).clamp(0.0, 1.0);
    final value = (1.0 - y / areaSize.height).clamp(0.0, 1.0);

    setState(() {
      _saturation = saturation;
      _value = value;
    });
    _emitColor();
  }

  void _onHueChanged(double hue) {
    setState(() => _hue = hue);
    _regenerateImage();
    _emitColor();
  }

  void _emitColor() {
    widget.onColorChanged(_currentColor);
    if (!_hexEditing) {
      _hexController.text = _currentHex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2D saturation×value 영역
        LayoutBuilder(builder: (context, constraints) {
          final areaWidth = constraints.maxWidth;
          const areaHeight = 160.0;

          final markerX = _saturation * areaWidth;
          final markerY = (1.0 - _value) * areaHeight;

          return GestureDetector(
            onPanDown: (d) =>
                _onAreaGesture(d.localPosition, Size(areaWidth, areaHeight)),
            onPanUpdate: (d) =>
                _onAreaGesture(d.localPosition, Size(areaWidth, areaHeight)),
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
                  // 마커
                  Positioned(
                    left: markerX - 10,
                    top: markerY - 10,
                    child: IgnorePointer(
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentColor,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.themePickerSaturation,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              l.themePickerBrightness,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Hue 바
        _HueBar(
          value: _hue,
          onChanged: _onHueChanged,
        ),
        const SizedBox(height: 10),
        // Hex 입력 + 색상 프리뷰
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _currentColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '#',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 100,
              child: TextField(
                controller: _hexController,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'FF0000',
                  counterText: '',
                ),
                maxLength: 6,
                keyboardType: TextInputType.visiblePassword,
                autocorrect: false,
                enableSuggestions: false,
                textCapitalization: TextCapitalization.characters,
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
            Text(
              l.themePickerHexInput,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 2D HSV 영역 CustomPainter.
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
    final dst = Offset.zero & size;
    canvas.drawImageRect(
      cachedImage!,
      src,
      dst,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_HsvAreaPainter old) => old.cachedImage != cachedImage;
}

/// Hue 바 — 레인보우 그래디언트 + 슬라이더.
class _HueBar extends StatelessWidget {
  const _HueBar({
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.themePickerHue,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
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
                data: _hueSliderTheme(
                  context,
                  HSLColor.fromAHSL(1.0, value, 1.0, 0.5).toColor(),
                ),
                child: Slider(
                  value: value,
                  min: 0,
                  max: 360,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

SliderThemeData _hueSliderTheme(BuildContext context, Color thumbColor) {
  return SliderThemeData(
    trackHeight: 0,
    activeTrackColor: Colors.transparent,
    inactiveTrackColor: Colors.transparent,
    thumbColor: thumbColor,
    overlayColor: thumbColor.withValues(alpha: 0.2),
    thumbShape: const _CircleThumb(radius: 10),
  );
}

class _CircleThumb extends SliderComponentShape {
  const _CircleThumb({required this.radius});

  final double radius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    canvas.drawCircle(
      center,
      radius + 1.5,
      Paint()..color = Colors.white,
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = sliderTheme.thumbColor ?? Colors.white,
    );

    canvas.drawCircle(
      center,
      radius + 1.5,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }
}

class _ImageCompleter {
  final _completer = Completer<ui.Image>();

  Future<ui.Image> get future => _completer.future;

  void complete(ui.Image image) => _completer.complete(image);
}
