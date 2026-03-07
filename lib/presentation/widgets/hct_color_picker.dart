import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

import 'package:fangeul/l10n/app_localizations.dart';

/// 2D HCT 색상 피커 — X=chroma, Y=tone, 하단 hue 바.
///
/// IntelliJ/Photoshop 스타일 2D 영역에서 chroma×tone을 선택하고,
/// 하단 hue 바에서 색조를 변경한다. gamut 외 영역은 HCT 자동 클램핑.
class HctColorPicker extends StatefulWidget {
  const HctColorPicker({
    super.key,
    required this.initialHue,
    required this.initialChroma,
    required this.initialTone,
    required this.onColorChanged,
  });

  final double initialHue;
  final double initialChroma;
  final double initialTone;
  final ValueChanged<Color> onColorChanged;

  @override
  State<HctColorPicker> createState() => _HctColorPickerState();
}

class _HctColorPickerState extends State<HctColorPicker> {
  late double _hue;
  late double _chroma;
  late double _tone;
  ui.Image? _cachedImage;
  double? _cachedHue;

  /// 2D 영역 해상도 — 성능과 품질의 균형.
  static const _imgWidth = 128;
  static const _imgHeight = 96;

  /// tone 범위: 15(어두움) ~ 85(밝음).
  static const _minTone = 15.0;
  static const _maxTone = 85.0;
  static const _toneRange = _maxTone - _minTone;

  /// chroma 범위: 12(최소) ~ 130(최대).
  static const _minChroma = 12.0;
  static const _maxChroma = 130.0;

  @override
  void initState() {
    super.initState();
    _hue = widget.initialHue;
    _chroma = widget.initialChroma.clamp(_minChroma, _maxChroma);
    _tone = widget.initialTone.clamp(_minTone, _maxTone);
    _regenerateImage();
  }

  @override
  void dispose() {
    _cachedImage?.dispose();
    super.dispose();
  }

  void _regenerateImage() {
    if (_cachedHue == _hue && _cachedImage != null) return;
    _cachedHue = _hue;
    _generateHctImage(_hue, _imgWidth, _imgHeight).then((image) {
      if (!mounted) {
        image.dispose();
        return;
      }
      final old = _cachedImage;
      setState(() => _cachedImage = image);
      old?.dispose();
    });
  }

  /// 픽셀 버퍼로 2D HCT 이미지를 생성한다.
  static Future<ui.Image> _generateHctImage(
    double hue,
    int width,
    int height,
  ) {
    final pixels = Uint8List(width * height * 4);
    for (int y = 0; y < height; y++) {
      final tone = _maxTone - (y / (height - 1)) * _toneRange;
      for (int x = 0; x < width; x++) {
        final chroma = _minChroma + (x / (width - 1)) * (_maxChroma - _minChroma);
        final argb = Hct.from(hue, chroma, tone).toInt();
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

    final chroma =
        (_minChroma + (x / areaSize.width) * (_maxChroma - _minChroma))
            .clamp(_minChroma, _maxChroma);
    final tone = (_maxTone - (y / areaSize.height) * _toneRange)
        .clamp(_minTone, _maxTone);

    setState(() {
      _chroma = chroma;
      _tone = tone;
    });
    _emitColor();
  }

  void _onHueChanged(double hue) {
    setState(() => _hue = hue);
    _regenerateImage();
    _emitColor();
  }

  void _emitColor() {
    final color = Color(Hct.from(_hue, _chroma, _tone).toInt());
    widget.onColorChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2D chroma×tone 영역
        LayoutBuilder(builder: (context, constraints) {
          final areaWidth = constraints.maxWidth;
          const areaHeight = 160.0;

          // 마커 위치 계산
          final markerX =
              ((_chroma - _minChroma) / (_maxChroma - _minChroma)) * areaWidth;
          final markerY =
              ((_maxTone - _tone) / _toneRange) * areaHeight;

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
                  // 2D 그래디언트 이미지
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CustomPaint(
                        painter: _HctAreaPainter(cachedImage: _cachedImage),
                      ),
                    ),
                  ),
                  // 십자 마커
                  Positioned(
                    left: markerX - 10,
                    top: markerY - 10,
                    child: IgnorePointer(
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(
                              Hct.from(_hue, _chroma, _tone).toInt()),
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
        // 축 라벨
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.themePickerChroma,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              l.themePickerTone,
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
      ],
    );
  }
}

/// 2D HCT 영역 CustomPainter — 캐시된 이미지를 그린다.
class _HctAreaPainter extends CustomPainter {
  const _HctAreaPainter({required this.cachedImage});

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
  bool shouldRepaint(_HctAreaPainter old) => old.cachedImage != cachedImage;
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

/// hue 슬라이더 테마 — 투명 트랙 + 컬러 Thumb.
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

/// 커스텀 원형 Thumb (흰 테두리 + 색상 채움).
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

/// decodeImageFromPixels 콜백을 Future로 변환하는 헬퍼.
class _ImageCompleter {
  final _completer = Completer<ui.Image>();

  Future<ui.Image> get future => _completer.future;

  void complete(ui.Image image) => _completer.complete(image);
}
