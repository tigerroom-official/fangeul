# Fangeul IAP 설정 및 테스트 가이드

> **대상**: Fangeul 개발자
> **패키지**: `in_app_purchase: ^3.2.0`
> **상품 유형**: Non-consumable (일회성 구매)
> **최종 업데이트**: 2026-03-13
> **현재 상태**: v1.0.0+6, 785 tests pass

---

## 목차

1. [상품 목록 및 Play Console 등록](#1-상품-목록-및-play-console-등록)
2. [테스트 환경 설정](#2-테스트-환경-설정)
3. [IAP 테스트 시나리오](#3-iap-테스트-시나리오)
4. [트러블슈팅](#4-트러블슈팅)
5. [릴리즈 전 체크리스트](#5-릴리즈-전-체크리스트)

---

## 1. 상품 목록 및 Play Console 등록

### 1.1 전체 SKU 목록

코드: `lib/services/iap_products.dart`

#### 테마 3-SKU

| 코드 상수 | Play Console 상품 ID | 설명 | KRW |
|-----------|---------------------|------|-----|
| `IapProducts.themeCustomColor` | `fangeul_theme_custom_color` | 배경·글자색 자유선택 (HCT 피커) | ₩990 |
| `IapProducts.themeSlots` | `fangeul_theme_slots` | 테마 슬롯 3개 추가 | ₩990 |
| `IapProducts.themeBundle` | `fangeul_theme_bundle` | 피커 + 슬롯 번들 (24% 할인) | ₩1,500 |

> **총 3개 SKU.** 상품 ID는 생성 후 변경 불가 — 오타 주의.

### 1.2 Play Console 등록 경로

1. [Google Play Console](https://play.google.com/console) → 앱 선택
2. 좌측 메뉴: **수익 창출** > **인앱 상품** (또는 **일회성 제품**)
3. **"제품 만들기"** → 상품 ID 입력 → 이름/설명/가격 설정

> **전제 조건**: AAB를 최소 1회 트랙에 업로드해야 인앱 상품 메뉴가 활성화됨.
> 내부 테스트에 v1.0.0+4를 이미 올렸으므로 메뉴가 보여야 함.

### 1.3 가격 설정

#### 기본 가격 (KRW) 입력 후 자동 변환 적용

Play Console에서 기본 가격(KRW)을 입력하면 "가격 변환 적용"으로 전 세계 가격이 자동 생성됨.
동남아는 자동 변환 가격이 현지 심리적 가격대와 안 맞을 수 있으므로 수동 조정 권장.

#### 동남아 수동 가격 (권장)

| SKU | KRW | IDR | THB | VND | PHP |
|-----|-----|-----|-----|-----|-----|
| 피커/슬롯 (₩990) | ₩990 | Rp 15,000 | ฿29 | ₫25,000 | ₱49 |
| 번들 (₩1,500) | ₩1,500 | Rp 22,000 | ฿39 | ₫35,000 | ₱69 |

### 1.4 상품 활성화

- 등록 후 기본 상태는 **비활성(Inactive)** — 정보 입력 후 명시적으로 **활성화** 필요
- 비활성 상품은 `queryProductDetails()`에서 `notFoundIDs`에 포함됨
- 로그: `[IapService] not found SKUs: ...` → 활성화 필요 신호

---

## 2. 테스트 환경 설정

### 2.1 테스트 트랙

| 트랙 | 인원 | 용도 |
|------|------|------|
| **내부 테스트** | 최대 100명 | 개발팀 빠른 검증 (심사 없음, 즉시 배포) |
| **비공개 테스트 (Closed)** | 이메일 목록 | 베타 테스터 그룹 |
| **공개 테스트 (Open)** | 무제한 | 넓은 베타 (스토어 노출) |
| **프로덕션** | 전체 | 정식 출시 |

현재 상태: 내부 테스트에 v1.0.0+4 업로드 완료. v1.0.0+6 AAB 빌드 완료.

### 2.2 라이선스 테스트 계정

**설정**: Play Console > **설정** > **라이선스 테스트**

1. 테스트용 Gmail 주소 추가
2. 라이선스 응답: `LICENSED`
3. 해당 계정이 기기의 **기본(primary) Google 계정**이어야 함

**특징:**
- 실제 결제 없이 구매 플로우 완료 (테스트 주문)
- 구매 확인 다이얼로그에 "테스트 주문 — 청구되지 않습니다" 표시
- 테스트 구매는 14일 후 자동 환불 (수동 즉시 환불도 가능)
- 개발자 계정 = 테스터 계정 가능

### 2.3 테스터 등록

1. Play Console > **테스트** > 해당 트랙 > "테스터" 탭
2. 이메일 목록에 테스터 추가
3. **참여 링크** 공유 → 테스터가 opt-in 수락
4. Play Store에서 앱 설치/업데이트 가능

> 계정 추가 후 반영까지 수 분~수 시간 소요 가능.

---

## 3. IAP 테스트 시나리오

### 3.1 사전 준비

1. 서명된 AAB를 트랙에 업로드
2. 인앱 상품 등록 + **활성화**
3. 라이선스 테스트 계정으로 기기 로그인
4. 테스터 opt-in 완료
5. Play Store에서 앱 설치 (또는 동일 서명 APK `adb install`)

### 3.2 테마 3-SKU 테스트

#### A. 피커(themeCustomColor) 단독 구매

1. 테마 피커 바텀시트 → "배경·글자색 자유선택" 구매
2. 검증:
   - `hasThemePicker = true`, `hasThemeSlots = false`
   - HCT 색상 피커 해금
   - 슬롯은 여전히 잠금
   - 번들 버튼 사라짐 (한쪽이라도 구매 시 번들 비노출)

#### B. 슬롯(themeSlots) 단독 구매

1. 테마 피커 바텀시트 → "테마 슬롯 3개" 구매
2. 검증:
   - `hasThemePicker = false`, `hasThemeSlots = true`
   - 피커는 여전히 잠금
   - 슬롯 3개 해금
   - 번들 버튼 사라짐

#### C. 번들(themeBundle) 구매

1. 번들 구매
2. 검증:
   - `hasThemePicker = true`, `hasThemeSlots = true` (동시 해금)
   - IAP 섹션 전체 비표시

#### D. 피커 → 슬롯 순차 구매

1. 피커 먼저, 이후 슬롯 추가 구매
2. 최종 상태가 번들 구매와 동일한지 확인

### 3.3 구매 취소 / 에러 / 보류

| 시나리오 | 동작 | 기대 결과 |
|----------|------|-----------|
| 취소 | 결제 다이얼로그에서 뒤로가기 | 상태 변경 없음 |
| 에러 | 결제 수단 문제 | `onError` 콜백, 에러 메시지 표시 |
| 보류 (Pending) | 슬로우 페이먼트 | 엔타이틀먼트 미부여, 확정 시 자동 처리 |

### 3.4 복원 / 앱 킬 테스트

#### 앱 킬 후 복원

```bash
adb shell am force-stop com.tigerroom.fangeul
# 앱 재시작 → SecureStorage + HMAC 로드 → 구매 상태 복원 확인
```

#### 앱 데이터 삭제 후 복원

```bash
adb shell pm clear com.tigerroom.fangeul
# 앱 재시작 → 설정 또는 테마 피커에서 복원 버튼 탭
# → restorePurchases() → 이전 구매 복원 확인
```

### 3.5 IAP + 즐겨찾기 무제한 연동

아무 테마 IAP 1건 구매 → `hasAnyIapProvider = true` → 즐겨찾기 슬롯 제한 해제.

### 3.6 보상형 광고 + IAP 충돌 없음

보상형 시청(테마 체험 24h) 중 IAP 구매 → 충돌 없이 독립 동작 확인.

---

## 4. 트러블슈팅

### 상품이 안 뜨는 경우

로그: `[IapService] not found SKUs: ...`

| 원인 | 해결 |
|------|------|
| 상품 비활성 | Play Console에서 활성화 |
| 상품 ID 불일치 | 대소문자·언더스코어 정확히 비교 |
| AAB 미업로드 | 서명된 AAB를 트랙에 1회 이상 업로드 |
| 전파 지연 | 등록 후 수 시간 소요 가능 |
| Play Store 캐시 | 기기에서 Play Store 캐시/데이터 삭제 |
| 테스터 미등록 | opt-in 링크 수락 확인 |
| 에뮬레이터 | `[IapService] IAP not available` — 정상 (Play Store 없음) |

### 구매 복원이 안 되는 경우

| 원인 | 해결 |
|------|------|
| 다른 Google 계정 | 구매 시 계정으로 로그인 |
| 환불된 구매 | 복원 대상에서 자동 제외 (정상) |
| purchaseStream 미수신 | `initialize()` 완료 후 `restorePurchases()` 호출 확인 |

---

## 5. 릴리즈 전 체크리스트

### Play Console

- [ ] 3개 상품 모두 등록 + **활성** 상태
- [ ] 상품 ID가 `IapProducts.allIds`와 정확히 일치
- [ ] KRW 기본 가격 설정
- [ ] 동남아 현지 가격 수동 설정 (권장)
- [ ] 각 상품 제목/설명 입력

### 코드

- [ ] `purchaseStream.listen` 콜백 `async` + `await` 사용
- [ ] SKU allowlist 검증 (`IapProducts.allIds.contains`)
- [ ] `onPurchased()` → `completePurchase()` 순서 (크래시 안전)
- [ ] `IapService.dispose()` 등록
- [ ] `iapProductsLoadedProvider`로 상품 로드 → UI 리빌드 연동

### 정책 준수

- [ ] 구매 전 기능 설명 명확 표시
- [ ] "복원" 버튼 존재 (테마 피커 또는 설정)
- [ ] 개인정보 처리방침에 IAP 데이터 수집 명시

### 테스트

- [ ] `flutter test` 전체 통과 (현재 785 tests)
- [ ] 테마 3-SKU 각각 구매/복원 통과
- [ ] 번들 구매 시 피커+슬롯 동시 해금
- [ ] 앱 킬 → 재시작 → 상태 복원
- [ ] 앱 데이터 삭제 → 복원 버튼 → 이전 구매 복원
- [ ] ProGuard/R8 적용 후 IAP 정상 작동

---

## 부록: 핵심 파일

| 파일 | 역할 |
|------|------|
| `lib/services/iap_products.dart` | SKU ID 상수 (3개) |
| `lib/services/iap_service.dart` | Google Play 구매 플로우 관리 |
| `lib/presentation/providers/iap_provider.dart` | IapService 초기화 + SKU별 분기 |
| `lib/presentation/providers/monetization_provider.dart` | 구매 상태 관리 (SecureStorage + HMAC) |
| `lib/core/entities/monetization_state.dart` | 상태 모델 (freezed) |
| `lib/presentation/widgets/theme_picker_sheet.dart` | 테마 IAP 구매 UI |

## 부록: 구매 처리 흐름

```
유저 탭 "구매"
  → IapService.buyPack(skuId)
    → InAppPurchase.buyNonConsumable()
      → Google Play 결제 다이얼로그

[purchaseStream 수신]
  → _handlePurchase()
    → SKU allowlist 검증
    → purchased/restored:
      1. onPurchased(productId) → iap_provider.dart:
         - themeCustomColor → unlockThemePicker()
         - themeSlots       → unlockThemeSlots()
         - themeBundle      → unlockThemeBundle()
      2. completePurchase() → Google에 확인
    → error:
      1. completePurchase()
      2. onError()
    → canceled: 로그만
    → pending: 로그만 (엔타이틀먼트 미부여)
```
