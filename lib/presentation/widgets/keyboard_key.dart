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

/// 한글 자음 집합. 모음과 시각적으로 구분하기 위해 사용.
const _consonants = {
  '\u3131', '\u3132', '\u3134', '\u3137', '\u3138', '\u3139',
  '\u3141', '\u3142', '\u3143', '\u3145', '\u3146', '\u3147',
  '\u3148', '\u3149', '\u314A', '\u314B', '\u314C', '\u314D', '\u314E',
};

/// 커스텀 한글 키보드의 개별 키 위젯 (순수 렌더링용).
///
/// 제스처 처리는 부모 키보드 위젯이 단일 [Listener]로 수행한다.
/// 개별 키는 시각적 렌더링만 담당하며, 터치 이벤트를 직접 받지 않는다.
/// 이 방식은 시스템 키보드(Gboard)와 동일한 데드존 제로 터치를 구현한다.
class KeyboardKey extends StatelessWidget {
  /// 키보드 키를 생성한다.
  const KeyboardKey({
    required this.keyType,
    this.onTap,
    this.keyData,
    this.isShifted = false,
    this.isCapsLocked = false,
    this.isEngToKor = true,
    super.key,
  }) : assert(
          keyType != KeyType.character || keyData != null,
          'keyData is required when keyType is character',
        );

  /// 키의 종류.
  final KeyType keyType;

  /// 탭 콜백 (multi_mode_keyboard 등 개별 제스처 처리 시 사용).
  /// KoreanKeyboard에서는 키보드 레벨 Listener가 처리하므로 null.
  final VoidCallback? onTap;

  /// 문자 키 메타데이터.
  final KeyData? keyData;

  /// Shift 활성 여부.
  final bool isShifted;

  /// Caps Lock 활성 여부.
  final bool isCapsLocked;

  /// 영->한 모드 여부.
  final bool isEngToKor;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = colorScheme.primary;
    final bgColor = colorScheme.surfaceContainer;
    final subColor = colorScheme.onSurfaceVariant;

    Widget visual = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: _buildContent(l, subColor, accentColor),
        ),
      ),
    );

    // onTap이 있으면 개별 Listener 추가 (multi_mode_keyboard 호환).
    // KoreanKeyboard에서는 키보드 레벨 Listener가 처리하므로 onTap=null.
    if (onTap != null) {
      visual = Listener(
        onPointerDown: (_) {
          HapticFeedback.lightImpact();
          onTap!();
        },
        child: visual,
      );
    }

    return SizedBox(height: 52, child: visual);
  }

  Widget _buildContent(L l, Color subColor, Color accentColor) {
    switch (keyType) {
      case KeyType.character:
        return _buildCharacterContent(subColor, accentColor);
      case KeyType.caps:
        return _buildCapsContent(subColor, accentColor);
      case KeyType.backspace:
        return Icon(Icons.backspace_outlined, size: 20, color: subColor);
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
      mainLabel = engLabel;
      mainColor = subColor;
      subLabel = korLabel;
      subLabelColor = accentColor.withValues(alpha: korOpacity);
    } else {
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
