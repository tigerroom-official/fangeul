import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/providers/color_pack_provider.dart';
import 'package:fangeul/presentation/providers/iap_provider.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/widgets/color_pack_card.dart';

/// 감성 컬러 팩 샵 화면.
///
/// 구매 가능한 컬러 팩 목록을 2열 그리드로 표시한다.
/// 각 팩 카드에서 구매 플로우를 시작하고, 앱바에서 구매 복원을 지원한다.
class ShopScreen extends ConsumerWidget {
  /// Creates the [ShopScreen] widget.
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final colorPacksAsync = ref.watch(colorPacksProvider);
    final monetizationAsync = ref.watch(monetizationNotifierProvider);
    final purchasedIds =
        monetizationAsync.valueOrNull?.purchasedPackIds ?? <String>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.shopTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: l.shopRestore,
            onPressed: () => _restorePurchases(context, ref),
          ),
        ],
      ),
      body: colorPacksAsync.when(
        data: (packs) => GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.65,
          ),
          itemCount: packs.length,
          itemBuilder: (context, index) {
            final pack = packs[index];
            final isPurchased = purchasedIds.contains(pack.skuId);
            return ColorPackCard(
              pack: pack,
              isPurchased: isPurchased,
              onBuy: () => _buyPack(context, ref, pack.skuId),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('${l.errorPrefix} $error'),
        ),
      ),
    );
  }

  /// IAP 구매를 시작한다.
  Future<void> _buyPack(
    BuildContext context,
    WidgetRef ref,
    String skuId,
  ) async {
    final iap = ref.read(iapServiceProvider);
    await iap.buyPack(skuId);
  }

  /// 이전 구매를 복원한다.
  Future<void> _restorePurchases(BuildContext context, WidgetRef ref) async {
    final iap = ref.read(iapServiceProvider);
    await iap.restorePurchases();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(L.of(context).shopRestoreSuccess)),
    );
  }
}
