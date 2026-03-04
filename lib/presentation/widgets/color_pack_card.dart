import 'package:flutter/material.dart';

import 'package:fangeul/data/models/color_pack.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';

/// 감성 컬러 팩 카드 — 그리드에 표시되는 팩 정보 카드.
///
/// 팩 색상 그래디언트, 이름, 문구/발음 수, 가격 또는 구매 완료 배지를 표시한다.
/// [isPurchased]가 true이면 구매 버튼 대신 "구매 완료" 배지를 표시한다.
class ColorPackCard extends StatelessWidget {
  /// Creates a [ColorPackCard].
  const ColorPackCard({
    required this.pack,
    required this.isPurchased,
    required this.onBuy,
    super.key,
  });

  /// 표시할 컬러 팩 데이터.
  final ColorPack pack;

  /// 이미 구매한 팩인지 여부.
  final bool isPurchased;

  /// 구매 버튼 탭 콜백.
  final VoidCallback onBuy;

  /// hex 문자열을 [Color]로 변환한다.
  static Color _parseHex(String hex) {
    final buffer = StringBuffer();
    if (hex.startsWith('#')) {
      buffer.write('FF');
      buffer.write(hex.substring(1));
    } else {
      buffer.write('FF');
      buffer.write(hex);
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = _parseHex(pack.primaryColor);
    final secondary = _parseHex(pack.secondaryColor);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 색상 스와치 — 그래디언트
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: isPurchased
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            UiStrings.shopPurchased,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
          ),
          // 팩 정보
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pack.nameKo,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  UiStrings.shopPhraseCount(pack.phraseCount),
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  UiStrings.shopPronunciationCount(pack.pronunciationCount),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                if (!isPurchased)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onBuy,
                      child: Text(
                        '₩${_formatPrice(pack.priceKrw)}',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 가격을 천 단위 콤마 형식으로 포맷한다.
  static String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
