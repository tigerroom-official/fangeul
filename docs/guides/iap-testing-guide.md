# Fangeul IAP 설정 및 테스트 가이드

> **대상**: Fangeul 개발자 (Google Play IAP 실무 경험 없는 사람 포함)
> **패키지**: `in_app_purchase: ^3.2.0`
> **상품 유형**: Non-consumable (일회성 구매, 구독 아님)
> **최종 업데이트**: 2026-03-12

---

## 목차

1. [Google Play Console IAP 상품 설정](#1-google-play-console-iap-상품-설정)
2. [테스트 환경 설정](#2-테스트-환경-설정)
3. [IAP 테스트 단계](#3-iap-테스트-단계)
4. [일반적인 IAP 함정과 해결](#4-일반적인-iap-함정과-해결)
5. [Fangeul 프로젝트 특화 체크리스트](#5-fangeul-프로젝트-특화-체크리스트)

---

## 1. Google Play Console IAP 상품 설정

### 1.1 관리되는 상품(Managed Product) vs 구독

| 항목 | 관리되는 상품 (Fangeul 사용) | 구독 |
|------|---------------------------|------|
| 결제 방식 | 일회성 | 반복 과금 |
| 소유 | 영구 소유 | 기간 만료 시 소멸 |
| 유형 | Non-consumable (재구매 불가) | - |
| Google 수수료 | 15~30% | 15% (1년 이후) |
| 적합 사례 | 테마 피커, 슬롯, 컬러 팩 | Phase 7+ 프로 구독 |

Fangeul MVP는 **관리되는 상품(Non-consumable)** 만 사용한다. `IapService.buyPack()`에서 `buyNonConsumable()`을 호출한다. 구독은 Phase 7 이후 별도 구현 예정.

### 1.2 상품 등록 위치

1. [Google Play Console](https://play.google.com/console) 접속
2. **앱 선택** (`com.tigerroom.fangeul`)
3. 좌측 메뉴: **수익 창출** > **제품** > **인앱 상품**
4. **"제품 만들기"** 클릭

> **주의**: 인앱 상품을 등록하려면 먼저 앱의 AAB/APK를 **최소 1회** 내부 테스트 트랙 이상에 업로드해야 한다. 상품 등록 메뉴 자체가 AAB 업로드 전에는 비활성 상태일 수 있다.

### 1.3 상품 ID 매핑

코드의 SKU ID(= `IapProducts` 상수)와 Play Console 상품 ID는 **정확히 일치**해야 한다.

**`lib/services/iap_products.dart`에 정의된 전체 SKU 목록:**

#### 테마 SKU (3-SKU)

| 코드 상수 | 상품 ID (Play Console에 입력) | 설명 | 기본 가격 (KRW) |
|-----------|-------------------------------|------|----------------|
| `IapProducts.themeCustomColor` | `fangeul_theme_custom_color` | 테마 배경/글자색 자유선택 (피커) | ₩990 |
| `IapProducts.themeSlots` | `fangeul_theme_slots` | 테마 슬롯 3개 추가 | ₩990 |
| `IapProducts.themeBundle` | `fangeul_theme_bundle` | 피커 + 슬롯 번들 | ₩1,500 |

#### 컬러 팩 SKU (5종)

| 코드 상수 | 상품 ID (Play Console에 입력) | 설명 | 기본 가격 (KRW) |
|-----------|-------------------------------|------|----------------|
| `IapProducts.starterPack` | `fangeul_color_starter` | 첫 만남 팩 | ₩990 |
| `IapProducts.purpleDream` | `fangeul_color_purple_dream` | 퍼플 드림 팩 | ₩1,900 |
| `IapProducts.goldenHour` | `fangeul_color_golden_hour` | 골든 아워 팩 | ₩1,900 |
| `IapProducts.concertSky` | `fangeul_color_concert_sky` | 그날 콘서트 하늘 팩 | ₩1,900 |
| `IapProducts.dawnLightstick` | `fangeul_color_dawn_lightstick` | 새벽 응원봉 잔광 팩 | ₩1,900 |

> **필수 확인**: Play Console에 입력하는 상품 ID(Product ID)는 한번 생성하면 **변경 불가**. 오타 시 삭제 후 재생성해야 한다. 코드의 `IapProducts.allIds`와 1:1 대응을 반드시 검증하라.

### 1.4 가격 설정

#### 기본 통화 설정
- Play Console 상품 설정에서 **기본 가격**(KRW)을 입력
- "가격 관리" 탭에서 **자동 현지 가격 변환** 적용 가능

#### 동남아 시장 가격 전략

Fangeul의 주요 타겟인 동남아(인도네시아, 태국, 베트남, 필리핀) 시장은 구매력이 다르다. Play Console에서 국가별 가격을 **수동 설정**하는 것을 권장한다.

| SKU | KRW | IDR (인도네시아) | THB (태국) | VND (베트남) | PHP (필리핀) |
|-----|-----|----------------|-----------|-------------|-------------|
| 피커/슬롯 (₩990) | ₩990 | Rp 15,000 | ฿29 | ₫25,000 | ₱49 |
| 번들 (₩1,500) | ₩1,500 | Rp 22,000 | ฿39 | ₫35,000 | ₱69 |
| 스타터 팩 (₩990) | ₩990 | Rp 15,000 | ฿29 | ₫25,000 | ₱49 |
| 프리미엄 팩 (₩1,900) | ₩1,900 | Rp 29,000 | ฿59 | ₫49,000 | ₱99 |

> **팁**: Google의 자동 변환은 환율 기준이라 동남아 현지 "심리적 가격대"와 맞지 않는 경우가 많다. 현지 앱스토어 경쟁 앱 가격을 참고하여 수동 조정하라.

**가격 설정 방법:**
1. 상품 편집 > 가격 관리
2. "기본 가격" 입력 (KRW)
3. "가격 변환 적용" 클릭 (자동 변환 기준값 생성)
4. 대상 국가의 가격을 수동으로 위 표에 맞게 조정
5. 저장

### 1.5 상품 상태 관리

| 상태 | 의미 |
|------|------|
| **활성(Active)** | 유저에게 노출, 구매 가능 |
| **비활성(Inactive)** | 유저에게 숨겨짐, 구매 불가 |

- 상품 등록 후 **기본 상태는 비활성**. 모든 정보를 입력하고 명시적으로 **활성화**해야 한다.
- `IapService._loadProducts()`에서 `queryProductDetails()`를 호출하면, 비활성 상품은 `notFoundIDs`에 포함된다.
- 디버그 로그에 `[IapService] not found SKUs: ...`가 출력되면 상품이 비활성이거나 ID가 불일치하는 것이다.

---

## 2. 테스트 환경 설정

### 2.1 Google Play Console 테스트 트랙

| 트랙 | 인원 제한 | 목적 | 스토어 노출 |
|------|----------|------|-----------|
| **내부 테스트** | 최대 100명 | 개발팀 IAP/기능 검증 | 비공개 |
| **비공개 테스트 (Closed)** | 무제한 (이메일 목록) | 베타 테스터 그룹 | 비공개 링크 |
| **공개 테스트 (Open)** | 무제한 | 넓은 베타 | 스토어 노출 (베타 표시) |
| **프로덕션** | 전체 | 정식 출시 | 완전 공개 |

**IAP 테스트 순서:**
1. **내부 테스트 트랙**에 서명된 AAB 업로드 (최소 요건)
2. 인앱 상품 8개 등록 + 활성화
3. 라이선스 테스트 계정 설정
4. 내부 테스트에서 전체 구매 플로우 검증
5. 비공개/공개 테스트로 확장
6. 프로덕션 배포

### 2.2 라이선스 테스트 계정 설정

**설정 경로:** Play Console > **설정** > **라이선스 테스트**

1. "Gmail 주소 추가"에 테스트용 Google 계정 입력
2. **라이선스 응답**: `LICENSED`로 설정
3. 테스트 기기에서 해당 Google 계정으로 로그인

**라이선스 테스트 계정의 특징:**
- 실제 결제 없이 구매 플로우 완료 가능 (무료 구매)
- 테스트 구매는 "테스트 주문"으로 표시됨
- 테스트 구매는 **자동으로 14일 후 환불** (수동 즉시 환불도 가능)
- 카드 정보를 등록해야 하지만 실제 과금되지 않음
- 구매 확인 다이얼로그에 "테스트 주문 — 청구되지 않습니다" 문구 표시

**주의사항:**
- 라이선스 테스트 계정은 **기기의 기본(primary) Google 계정**이어야 함
- Play Console 개발자 계정과 라이선스 테스트 계정이 **같아도** 됨
- 내부 테스트 트랙 테스터 목록에도 해당 계정을 추가해야 함
- 계정 추가 후 반영까지 **수 분~수 시간** 소요될 수 있음

### 2.3 내부 테스트 트랙 테스터 설정

1. Play Console > **테스트** > **내부 테스트**
2. "테스터" 탭 > "이메일 목록 만들기" 또는 기존 목록에 추가
3. 테스터에게 **참여 링크** 공유 (opt-in URL)
4. 테스터가 링크를 열고 테스트 참여를 수락해야 앱 설치/업데이트 가능

---

## 3. IAP 테스트 단계

### 3.1 단위 테스트 (로컬)

Fangeul 프로젝트에는 이미 IAP 관련 단위 테스트가 구현되어 있다.

**기존 테스트 파일:**
- `test/services/iap_service_test.dart` -- SKU ID 상수 검증, 유니크성, 프리픽스 규칙
- `test/presentation/widgets/iap_purchase_section_test.dart` -- 번들 표시/비표시 로직, 구매 상태별 섹션 가시성
- `test/presentation/providers/monetization_provider_test.dart` -- 구매 상태 관리, HMAC 서명, 시간 검증
- `test/data/datasources/monetization_local_datasource_test.dart` -- SecureStorage + HMAC 저장/로드

**실행:**
```bash
# IAP 관련 테스트만
flutter test test/services/iap_service_test.dart
flutter test test/presentation/widgets/iap_purchase_section_test.dart
flutter test test/presentation/providers/monetization_provider_test.dart

# 전체 테스트
flutter test
```

**추가 작성이 필요한 엣지 케이스 테스트:**

```dart
// IapService mock 기반 구매 플로우 테스트 예시
// (in_app_purchase 패키지의 InAppPurchase를 mock 주입)

class MockInAppPurchase extends Mock implements InAppPurchase {}

void main() {
  group('IapService purchase flow', () {
    late MockInAppPurchase mockIap;
    late IapService service;

    setUp(() {
      mockIap = MockInAppPurchase();
      service = IapService(iap: mockIap);
    });

    test('should handle network error gracefully', () async {
      // queryProductDetails 실패 시 빈 목록
      when(() => mockIap.queryProductDetails(any()))
          .thenThrow(Exception('network'));
      // initialize에서 에러 전파하지 않는지 확인
    });

    test('should skip unknown SKU in purchase stream', () async {
      // 알 수 없는 productID → addPurchasedPack 호출하지 않아야 함
    });

    test('should handle duplicate purchase (already owned)', () async {
      // 이미 purchasedPackIds에 있는 SKU → addPurchasedPack 중복 무시
    });

    test('should handle purchase cancellation', () async {
      // PurchaseStatus.canceled → 아무 상태 변경 없어야 함
    });
  });
}
```

### 3.2 Google Play Billing Library 테스트

실기기에서 Google Play Billing과 연동하여 실제 구매 플로우를 검증한다.

#### 사전 준비
1. 서명된 AAB를 내부 테스트 트랙에 업로드
2. 8개 인앱 상품 모두 등록 + **활성화**
3. 라이선스 테스트 계정을 기기 기본 계정으로 설정
4. 테스터 opt-in 링크 수락 완료
5. Play Store에서 앱 업데이트 (또는 `adb install`로 동일 서명 APK 설치)

#### 테스트 시나리오

**시나리오 A: 정상 구매 플로우**
1. 앱 실행 > 테마 피커 바텀시트 열기
2. IAP 구매 섹션에서 "배경/글자색 자유선택" 탭
3. Google Play 구매 다이얼로그 확인 ("테스트 주문" 표시 확인)
4. 구매 완료
5. **검증 포인트:**
   - `[IapProvider] purchased: fangeul_theme_custom_color` 로그 출력
   - `MonetizationNotifier.unlockThemePicker()` 호출 확인 (hasThemePicker = true)
   - `completePurchase()` 호출 확인 (pending 상태 해소)
   - 피커 UI가 즉시 해금 상태로 전환
   - SecureStorage에 HMAC 서명과 함께 저장

**시나리오 B: 구매 취소**
1. 구매 다이얼로그에서 "취소" 또는 뒤로가기
2. **검증 포인트:**
   - `[IapService] purchase canceled: ...` 로그 출력
   - 상태 변경 없음
   - UI 변화 없음

**시나리오 C: 구매 보류(Pending)**
1. 결제 수단이 '대기 결제'를 지원하는 경우 (일부 국가)
2. **검증 포인트:**
   - `[IapService] purchase pending: ...` 로그 출력
   - 엔타이틀먼트 미부여 (구매 확정까지 대기)
   - 이후 purchased 상태 전환 시 정상 처리

**시나리오 D: 구매 에러**
1. 결제 수단 문제 또는 네트워크 오류
2. **검증 포인트:**
   - `onError` 콜백 호출 확인
   - `completePurchase()` 호출 (에러 시에도 pending 해소 필수)
   - 사용자에게 에러 메시지 표시

#### 구매 순서 검증 (Critical)

Fangeul의 구매 처리 순서는 **크래시 안전**을 위해 엄격하게 정의되어 있다:

```
1. onPurchased(productId) 호출 → 엔타이틀먼트 저장 (SecureStorage)
2. completePurchase() 호출 → Google Play에 구매 확인 전송
```

이 순서가 **반드시** 지켜져야 한다. 만약 `completePurchase()`를 먼저 호출하고 앱이 크래시하면, 엔타이틀먼트가 저장되지 않은 채 Google에는 구매 완료로 기록되어 유저가 돈만 낸 셈이 된다.

코드에서 이 순서는 `IapService._handlePurchase()`에 구현되어 있다:
```dart
// 구매 성공 — 상태 저장 먼저, completePurchase 후
await onPurchased(purchase.productID);
if (purchase.pendingCompletePurchase) {
  await _iap.completePurchase(purchase);
}
```

### 3.3 통합 테스트

#### 앱 킬 후 복원 테스트
1. 구매 완료 후 앱 강제 종료 (`adb shell am force-stop com.tigerroom.fangeul`)
2. 앱 재시작
3. **검증 포인트:**
   - `MonetizationLocalDataSource.load()`에서 SecureStorage 로드
   - HMAC 서명 검증 통과
   - `MonetizationState.hasThemePicker` 등 구매 상태 복원
   - 테마 피커 UI가 해금 상태로 표시

#### 구매 복원 테스트 (기기 변경 대응)
1. 앱 데이터 삭제 (`adb shell pm clear com.tigerroom.fangeul`)
2. 앱 재시작 > 샵 화면 > 앱바 복원 버튼(복원 아이콘) 탭
3. **검증 포인트:**
   - `IapService.restorePurchases()` 호출
   - purchaseStream에 `PurchaseStatus.restored`로 이전 구매 수신
   - 각 SKU별 엔타이틀먼트 복원 (`addPurchasedPack` / `unlockThemePicker` 등)
   - ShopScreen에서 구매 완료 상태 반영

#### 환불 처리
- Google Play에서 환불 시 `VOIDED_PURCHASE` 이벤트 발생
- **현재 구현**: 클라이언트 측 환불 감지 미구현 (서버 없음)
- **MVP 대응**: 유저가 환불 후 앱 재설치하면 `restorePurchases()`에서 해당 상품이 누락되어 자연 해제
- **주의**: 앱 데이터를 삭제하지 않고 계속 사용하면 로컬 SecureStorage에 엔타이틀먼트가 남아있음. MVP 한계로 인정.

#### 듀얼 FlutterEngine 구매 동기화
Fangeul은 메인 Activity와 버블(MiniConverter) Activity가 별도 FlutterEngine을 사용한다.

- 구매는 메인 Activity에서만 수행
- 버블에서는 `SharedPreferences.reload()` 후 상태 읽기 (SecureStorage도 동일 원리)
- `didChangeAppLifecycleState(resumed)` 시 provider invalidate로 최신 상태 반영

### 3.4 프로덕션 전 체크리스트

#### 상품 설정 확인
- [ ] 8개 상품 모두 Play Console에서 **활성(Active)** 상태
- [ ] 상품 ID가 `IapProducts.allIds`와 정확히 일치 (대소문자, 언더스코어 포함)
- [ ] 각 상품의 제목/설명이 해당 국가 언어로 입력됨
- [ ] 기본 가격(KRW) 설정 완료
- [ ] 동남아 5개국 현지 가격 수동 설정 완료 (자동 변환 아님)

#### 결제 환경 확인
- [ ] 환율 변동으로 인한 가격 괴리 점검 (분기별 리뷰 권장)
- [ ] 테스트 계정이 아닌 실제 계정으로 최종 확인 (소액 상품 1건 실구매 후 환불)

#### 코드 확인
- [ ] `IapService.initialize()`에서 `purchaseStream.listen` 콜백이 `async`이고 `await` 사용
- [ ] SKU allowlist 검증 작동 (`IapProducts.allIds.contains(purchase.productID)`)
- [ ] `completePurchase()` 호출이 `onPurchased()` 이후에 위치
- [ ] `IapService.dispose()`가 `ref.onDispose`에 등록됨

#### Play Store 정책 준수
- [ ] 모든 인앱 상품의 기능 설명이 구매 전 명확히 표시됨
- [ ] "복원" 버튼이 앱 내에 존재 (ShopScreen 앱바)
- [ ] 구매 전 가격이 Play 결제 다이얼로그에 표시됨 (자동)
- [ ] 개인정보 처리방침에 IAP 관련 데이터 수집 명시

---

## 4. 일반적인 IAP 함정과 해결

### 4.1 상품이 안 뜨는 경우 (queryProductDetails 실패)

**증상:** `[IapService] not found SKUs: fangeul_theme_custom_color, ...`

| 원인 | 해결 |
|------|------|
| 상품 ID 불일치 | Play Console 상품 ID와 `IapProducts` 상수 비교. 대소문자, 언더스코어 주의 |
| 상품 비활성 | Play Console에서 상품 상태를 "활성"으로 변경 |
| AAB 미업로드 | 서명된 AAB를 내부 테스트 이상 트랙에 1회 이상 업로드 |
| 버전 코드 불일치 | 기기에 설치된 앱의 버전 코드가 Play Console 트랙의 버전 이상 |
| Play Store 캐시 | 기기에서 Play Store 앱의 캐시/데이터 삭제 후 재시도 |
| 패키지명 불일치 | `com.tigerroom.fangeul`이 Play Console 앱과 일치하는지 확인 |
| 전파 지연 | 상품 등록/활성화 후 최대 **수 시간** 소요. 기다려라 |
| 테스터 미등록 | 해당 Google 계정이 내부 테스트 트랙 테스터로 등록 + opt-in 완료 |

**디버깅 순서:**
1. `flutter run` 실행 후 로그에서 `[IapService]` 태그 확인
2. `_iap.isAvailable()` 반환값 확인 (에뮬레이터에서는 false일 수 있음)
3. `response.notFoundIDs` 목록 확인
4. Play Console 상품 상태 재확인

### 4.2 구매 복원이 안 되는 경우

**증상:** "복원" 버튼 탭 후 이전 구매가 반영되지 않음

| 원인 | 해결 |
|------|------|
| 다른 Google 계정으로 로그인 | 구매 시 사용한 계정으로 로그인 |
| consumable로 구매됨 | Non-consumable만 복원 가능. Fangeul은 `buyNonConsumable()` 사용하므로 정상 |
| 환불된 구매 | 환불된 상품은 복원 대상에서 제외됨 (정상 동작) |
| purchaseStream 미수신 | `IapService.initialize()` 호출이 `restorePurchases()` 전에 완료되었는지 확인 |

### 4.3 중복 구매 처리

Non-consumable 상품은 Google Play가 자체적으로 중복 구매를 차단한다.

- 이미 소유한 상품을 다시 `buyNonConsumable()` 하면 "이미 소유하고 있습니다" 에러 발생
- Fangeul 코드에서도 `addPurchasedPack()`에서 중복 체크:
  ```dart
  if (current.purchasedPackIds.contains(packId)) return;
  ```
- 테마 SKU도 마찬가지: `unlockThemePicker()`는 `hasThemePicker`가 이미 true여도 안전하게 동작

### 4.4 PendingPurchase 처리

**PendingPurchase란?** 결제가 시작되었지만 아직 확정되지 않은 상태.

발생 경우:
- 슬로우 페이먼트 (편의점 결제 등, 동남아에서 흔함)
- 3D Secure 인증 대기
- 프로모션 코드 입력 대기

**Fangeul의 처리:**
```dart
case PurchaseStatus.pending:
  debugPrint('[IapService] purchase pending: ${purchase.productID}');
```

- Pending 상태에서는 엔타이틀먼트를 부여하지 않음 (정상)
- 결제 확정 시 purchaseStream에 `PurchaseStatus.purchased`로 다시 전달됨
- 앱을 종료했다가 다시 열어도 pending 구매는 purchaseStream으로 전달됨

**주의:** `completePurchase()`는 `pending` 상태에서 호출하지 않는다 (`purchase.pendingCompletePurchase`가 false).

### 4.5 purchaseStream 누락

`purchaseStream`은 앱 시작 시 구독해야 하며, 구독 전에 발생한 이벤트는 수신할 수 없다.

**Fangeul의 보장:**
- `iapServiceProvider`는 `keepAlive: true`이므로 앱 생명주기 동안 유지
- `initialize()`에서 `_subscription`을 설정하고, `ref.onDispose(service.dispose)`로 해제
- 콜백이 `async`이고 `await`를 사용하여 상태 저장이 완료될 때까지 대기

---

## 5. Fangeul 프로젝트 특화 체크리스트

### 5.1 3-SKU 개별 구매 테스트

각 테마 SKU를 개별적으로 테스트하되, **테스트 구매 환불 후 다음 시나리오를 진행**한다.

#### 테스트 A: 피커(themeCustomColor) 단독 구매
1. 테마 피커 바텀시트 > "배경/글자색 자유선택" 구매
2. **검증:**
   - `hasThemePicker = true`, `hasThemeSlots = false`
   - 색상 피커 UI 해금 (HCT 피커 사용 가능)
   - 슬롯 추가 기능은 여전히 잠금
   - IAP 섹션에서 피커 버튼 사라짐, 슬롯 버튼 유지, **번들 버튼 사라짐** (둘 중 하나라도 구매하면 번들 비노출)

#### 테스트 B: 슬롯(themeSlots) 단독 구매
1. 테마 피커 바텀시트 > "테마 슬롯 3개 추가" 구매
2. **검증:**
   - `hasThemePicker = false`, `hasThemeSlots = true`
   - 색상 피커 UI는 여전히 잠금
   - 테마 슬롯 3개 추가 해금
   - IAP 섹션에서 슬롯 버튼 사라짐, 피커 버튼 유지, **번들 버튼 사라짐**

#### 테스트 C: 번들(themeBundle) 구매
1. 테마 피커 바텀시트 > 번들 (추천 뱃지 표시) 구매
2. **검증:**
   - `hasThemePicker = true`, `hasThemeSlots = true` (동시 해금)
   - 색상 피커 + 슬롯 모두 해금
   - **IAP 섹션 전체 비표시** (피커+슬롯 모두 구매 완료)
   - `unlockThemeBundle()` 내부:
     ```dart
     current.copyWith(hasThemePicker: true, hasThemeSlots: true)
     ```

#### 테스트 D: 피커 구매 후 슬롯 추가 구매
1. 피커 먼저 구매 > 슬롯 구매
2. **검증:**
   - 최종 상태: `hasThemePicker = true`, `hasThemeSlots = true`
   - IAP 섹션 전체 비표시
   - 번들 구매와 동일한 최종 상태

### 5.2 컬러 팩 구매 테스트

1. ShopScreen에서 각 컬러 팩 구매
2. **검증:**
   - `purchasedPackIds`에 해당 SKU 추가
   - ColorPackCard UI에 구매 완료 상태 반영
   - 해당 팩의 테마 컬러 적용 가능

### 5.3 IAP와 즐겨찾기 무제한 해금 연동

```dart
// hasAnyIap Provider: 아무 IAP든 구매하면 즐겨찾기 무제한
bool hasAnyIap = state.hasThemePicker ||
    state.hasThemeSlots ||
    state.purchasedPackIds.isNotEmpty;
```

1. IAP 구매 전: 허니문 종료 후 즐겨찾기 5슬롯 제한
2. 아무 IAP 1건 구매
3. **검증:**
   - `hasAnyIapProvider = true`
   - 즐겨찾기 슬롯 제한 해제 (무제한)

### 5.4 보상형 광고와 IAP 충돌 없음 확인

보상형 광고와 IAP는 독립적인 해금 경로이다.

| 해금 항목 | 보상형 광고 | IAP |
|-----------|-----------|-----|
| 테마 팔레트 영구 해금 | `themeUnlocked = true` | - |
| 프리미엄 테마 24h 체험 | `themeTrialExpiresAt` 설정 | - |
| 색상 피커 (자유선택) | - | `hasThemePicker = true` |
| 테마 슬롯 추가 | - | `hasThemeSlots = true` |
| 즐겨찾기 무제한 | - | `hasAnyIap = true` |

**테스트 시나리오:**
1. 보상형 광고 시청 > 테마 체험 24h 활성화
2. 체험 중 IAP 구매 시도
3. **검증:**
   - 구매 플로우 정상 작동 (충돌 없음)
   - 체험 만료 후에도 IAP 해금 유지
   - 두 상태가 독립적으로 관리됨

### 5.5 HMAC 무결성 검증

구매 후 SecureStorage 데이터가 변조되지 않았는지 검증한다.

1. 구매 완료
2. 앱 재시작
3. **검증:**
   - `MonetizationLocalDataSource.load()`에서 HMAC 검증 통과
   - 구매 상태 정상 복원

**변조 감지 테스트 (개발 시에만):**
1. SecureStorage의 `monetization_data` 값을 수동 변경
2. 앱 재시작
3. **기대 동작:**
   - `[MonetizationLocalDataSource] HMAC mismatch — resetting` 로그 출력
   - 모든 수익화 상태 초기화 (변조 방어)
   - 사용자는 "복원" 버튼으로 IAP 재복원 가능

### 5.6 최종 릴리즈 전 E2E 체크리스트

- [ ] 8개 SKU 모두 Play Console 활성 + 가격 설정
- [ ] 테마 3-SKU 각각 구매/복원 테스트 통과
- [ ] 컬러 팩 5종 각각 구매/복원 테스트 통과
- [ ] 번들 구매 시 피커+슬롯 동시 해금 확인
- [ ] 피커→슬롯 순차 구매 후 번들과 동일 상태 확인
- [ ] 구매 후 앱 킬 > 재시작 > 상태 복원 확인
- [ ] 앱 데이터 삭제 > 복원 버튼 > 이전 구매 복원 확인
- [ ] 보상형 광고 체험 중 IAP 구매 충돌 없음
- [ ] IAP 구매 후 즐겨찾기 무제한 해금 확인
- [ ] PendingPurchase 시 엔타이틀먼트 미부여 확인
- [ ] 네트워크 끊김 시 graceful 에러 처리
- [ ] 동남아 현지 가격이 기대값과 일치
- [ ] ProGuard/R8 적용 후에도 IAP 정상 작동 (난독화로 클래스명 변경 시 문제 가능)
- [ ] `flutter test` 전체 통과 (현재 812 tests)

---

## 부록: 빠른 참조

### IAP 관련 핵심 파일

| 파일 | 역할 |
|------|------|
| `lib/services/iap_products.dart` | SKU ID 상수 정의 (8개) |
| `lib/services/iap_service.dart` | Google Play 구매 플로우 관리 |
| `lib/presentation/providers/iap_provider.dart` | IapService 초기화 + SKU별 엔타이틀먼트 분기 |
| `lib/presentation/providers/monetization_provider.dart` | 구매 상태 관리 (SecureStorage + HMAC) |
| `lib/core/entities/monetization_state.dart` | 구매 상태 데이터 모델 (freezed) |
| `lib/data/datasources/monetization_local_datasource.dart` | HMAC-SHA256 서명 기반 안전 저장/로드 |
| `lib/presentation/screens/shop_screen.dart` | 컬러 팩 샵 UI + 복원 버튼 |
| `lib/presentation/widgets/theme_picker_sheet.dart` | 테마 IAP 구매 UI (피커/슬롯/번들) |

### 구매 처리 흐름도

```
유저 탭 "구매"
  → IapService.buyPack(skuId)
    → InAppPurchase.buyNonConsumable()
      → Google Play 결제 다이얼로그

[purchaseStream 수신]
  → IapService._handlePurchase()
    → SKU allowlist 검증 (IapProducts.allIds)
    → PurchaseStatus.purchased:
      1. onPurchased(productId) → iap_provider.dart 분기:
         - themeCustomColor → unlockThemePicker()
         - themeSlots → unlockThemeSlots()
         - themeBundle → unlockThemeBundle()
         - colorPack → addPurchasedPack(productId)
      2. completePurchase() → Google Play에 확인
    → PurchaseStatus.error:
      1. completePurchase() (pending 해소)
      2. onError() → 사용자 에러 메시지
    → PurchaseStatus.canceled:
      - 로그만 출력, 상태 변경 없음
    → PurchaseStatus.pending:
      - 로그만 출력, 엔타이틀먼트 미부여
```
