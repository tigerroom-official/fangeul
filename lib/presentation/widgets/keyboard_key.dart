import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide KeyboardKey;

import 'package:fangeul/l10n/app_localizations.dart';

/// 키 하나의 메타데이터.
///
/// 영문 라벨([eng]), 한글 자모 라벨([kor]),
/// Shift 시 표시할 쌍자음([korShift])을 보관한다.
class KeyData {
  /// [eng] 영문 소문자, [kor] 한글 자모(기본), [korShift] 쌍자음(선택).
  const KeyData({
    required this.eng,
    required this.kor,
    this.korShift,
  });

  /// 영문 소문자 라벨 (예: 'q').
  final String eng;

  /// 한글 자모 기본 라벨 (예: 'ㅂ').
  final String kor;

  /// Shift 시 한글 쌍자음 라벨 (예: 'ㅃ'). null이면 Shift 변형 없음.
  final String? korShift;
}

/// 키 종류.
enum KeyType {
  /// 일반 문자 키.
  character,

  /// Caps(Shift) 토글 키.
  caps,

  /// 백스페이스 키.
  backspace,

  /// 스페이스바.
  space,
}

/// 커스텀 한글 키보드의 개별 키 위젯.
///
/// [KeyType]에 따라 문자 키(이중 라벨), Caps 키, 백스페이스, 스페이스바를 렌더링한다.
/// 문자 키는 영문/한글 두 줄 라벨을 표시하며,
/// 자음(consonant)과 모음(vowel)에 서로 다른 불투명도를 적용해 시각적 구분을 돕는다.
/// 모든 키에 햅틱 피드백을 제공한다.
class KeyboardKey extends StatelessWidget {
  /// 키보드 키를 생성한다.
  ///
  /// [keyType]이 [KeyType.character]이면 [keyData]가 필수이다.
  const KeyboardKey({
    required this.keyType,
    required this.onTap,
    this.keyData,
    this.isShifted = false,
    this.isCapsLocked = false,
    this.isEngToKor = true,
    this.onLongPressStart,
    this.onLongPressEnd,
    super.key,
  }) : assert(
          keyType != KeyType.character || keyData != null,
          'keyData is required when keyType is character',
        );

  /// 키의 종류.
  final KeyType keyType;

  /// 탭 콜백.
  final VoidCallback onTap;

  /// 문자 키 메타데이터. [keyType] == [KeyType.character]일 때 필수.
  final KeyData? keyData;

  /// Shift 활성 여부.
  final bool isShifted;

  /// Caps Lock 활성 여부.
  final bool isCapsLocked;

  /// 영->한 모드 여부. true이면 영문이 주 라벨, false이면 한글이 주 라벨.
  final bool isEngToKor;

  /// 길게 누르기 시작 콜백 (백스페이스 연속 삭제 등).
  final VoidCallback? onLongPressStart;

  /// 길게 누르기 종료 콜백.
  final VoidCallback? onLongPressEnd;

  /// 한글 자음 집합. 모음과 시각적으로 구분하기 위해 사용.
  static const _consonants = {
    '\u3131', // ㄱ
    '\u3132', // ㄲ
    '\u3134', // ㄴ
    '\u3137', // ㄷ
    '\u3138', // ㄸ
    '\u3139', // ㄹ
    '\u3141', // ㅁ
    '\u3142', // ㅂ
    '\u3143', // ㅃ
    '\u3145', // ㅅ
    '\u3146', // ㅆ
    '\u3147', // ㅇ
    '\u3148', // ㅈ
    '\u3149', // ㅉ
    '\u314A', // ㅊ
    '\u314B', // ㅋ
    '\u314C', // ㅌ
    '\u314D', // ㅍ
    '\u314E', // ㅎ
  };

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = colorScheme.primary;
    final bgColor = colorScheme.surfaceContainer;
    final subColor = colorScheme.onSurfaceVariant;

    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          child: GestureDetector(
            onLongPressStart: onLongPressStart != null
                ? (_) {
                    _triggerHaptic();
                    onLongPressStart!();
                  }
                : null,
            onLongPressEnd:
                onLongPressEnd != null ? (_) => onLongPressEnd!() : null,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              splashColor: accentColor.withValues(alpha: 0.2),
              onTap: () {
                _triggerHaptic();
                onTap();
              },
              child: Center(
                child: _buildContent(l, subColor, accentColor),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _triggerHaptic() {
    switch (keyType) {
      case KeyType.character:
        HapticFeedback.selectionClick();
      case KeyType.backspace:
        HapticFeedback.lightImpact();
      case KeyType.caps:
        HapticFeedback.mediumImpact();
      case KeyType.space:
        HapticFeedback.selectionClick();
    }
  }

  Widget _buildContent(L l, Color subColor, Color accentColor) {
    switch (keyType) {
      case KeyType.character:
        return _buildCharacterContent(subColor, accentColor);
      case KeyType.caps:
        return _buildCapsContent(subColor, accentColor);
      case KeyType.backspace:
        return Icon(
          Icons.backspace_outlined,
          size: 20,
          color: subColor,
        );
      case KeyType.space:
        return Text(
          l.keyboardSpace,
          style: TextStyle(
            fontFamily: 'NotoSansKR',
            fontSize: 12,
            color: subColor,
          ),
        );
    }
  }

  Widget _buildCharacterContent(Color subColor, Color accentColor) {
    final data = keyData!;
    final engLabel = isShifted ? data.eng.toUpperCase() : data.eng;
    final korLabel =
        isShifted && data.korShift != null ? data.korShift! : data.kor;
    final isConsonant = _consonants.contains(korLabel);
    final korOpacity = isConsonant ? 1.0 : 0.6;

    final String mainLabel;
    final Color mainColor;
    final String subLabel;
    final Color subLabelColor;

    if (isEngToKor) {
      // 영->한 모드: 영문이 주 라벨, 한글이 보조 라벨
      mainLabel = engLabel;
      mainColor = subColor;
      subLabel = korLabel;
      subLabelColor = accentColor.withValues(alpha: korOpacity);
    } else {
      // 한->영/발음 모드: 한글이 주 라벨, 영문이 보조 라벨
      mainLabel = korLabel;
      mainColor = accentColor;
      subLabel = engLabel;
      subLabelColor = subColor.withValues(alpha: 0.4);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          mainLabel,
          style: TextStyle(
            fontFamily: 'NotoSansKR',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: mainColor,
          ),
        ),
        Text(
          subLabel,
          style: TextStyle(
            fontFamily: 'NotoSansKR',
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: subLabelColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCapsContent(Color subColor, Color accentColor) {
    final isActive = isShifted || isCapsLocked;
    final iconColor = isActive ? accentColor : subColor;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.arrow_upward,
          size: 20,
          color: iconColor,
        ),
        if (isCapsLocked)
          Container(
            width: 12,
            height: 2,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
      ],
    );
  }
}
