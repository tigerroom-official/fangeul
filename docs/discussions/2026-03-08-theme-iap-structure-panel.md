# Theme IAP Structure - Expert Panel

> Date: 2026-03-08
> Participants: 민지(수익화PM), 준혁(UX리서처), 소영(프리미엄전략가), 태현(인디개발자), 하나(동남아전문가)
> Status: Consensus reached

## 이전 합의 제약 (위반 금지)

1. **시간제 테마 해금 금지** — 테마는 영구 해금 (2026-03-07 만장일치)
2. **특정 그룹 컬러 조합 판매 금지** — IP 리스크 (소속사 문제)
3. **도구를 팔지, 색을 팔지 않는다** — WCAG 추천은 알고리즘 기반이라 IP 무관

## 핵심 합의

### 1. 배경 자유 선택 = IAP (무료 아님)

팔레트만 무료. 직접 고르기(자유 피커)는 IAP 뒤에 위치. 이전 합의 퍼널 유지.

### 2. 색상 피커 UX = 사각형 2D 피커 (HCT 기반)

- hue-only 슬라이더는 chroma/tone 고정으로 파스텔/네온/다크 불가 → 부족
- **사각형 영역**: X=chroma, Y=tone + **하단 바**: hue
- `Hct.from(hue, chroma, tone)` → sRGB gamut 자동 클램핑
- tone 15~85, chroma 최소 12로 제한 → 극단값(검정/흰색/회색) 방지
- HSL 슬라이더와 다른 점: HCT는 지각균일하여 범위 제한이 자연스러움
- IAP "프로 도구" perceived value 향상

### 3. 테마 슬롯 MVP 포함

유즈케이스:
- 콘서트용(밤) / 일상용(낮)
- 다중 그룹 팬 (BTS+세븐틴 등)
- (v1.1) K-pop 캘린더 연동 자동 전환

구현: SharedPreferences JSON 배열, 3개 슬롯 + 기본 1개 = 총 4개

### 4. 3-SKU 분리 판매

| SKU | 가격 | 내용 |
|-----|------|------|
| `theme_custom_color` | W990 | 배경 자유 선택(사각형 피커) + 글자색 피커 + WCAG 추천 |
| `theme_slots` | W990 | 테마 슬롯 3개 추가 (이름 커스텀, 원터치 전환) |
| `theme_bundle` | W1,500 | 위 두 개 포함 (24% 할인) |

근거:
- 2-tier = 가격 차별화 (price discrimination)
- 동남아 W990 = IDR 11K = 충동구매 가능 금액
- W990 단독 = 앵커, W1,500 번들 = 타겟 (앵커링 패턴)
- 슬롯 독립 구매 → 팔레트만 쓰되 슬롯 필요한 유저 세그먼트 신규 획득
- Play Store 일회성 IAP는 차액 결제 불가 → 독립 SKU가 현실적

업그레이드 경로:
- W990(글자색) 먼저 구매 → 나중에 W990(슬롯) 추가 = 총 W1,980
- 처음부터 번들 W1,500 = W480 절약
- 이미 한쪽 구매한 유저에겐 번들 비노출 (혼란 방지)

### 5. IAP 퍼널 최종

```
[무료]     팔레트 4개 + 자동대비 + 슬롯 1개(현재 상태)
              |
        광고 1회 (FanPass, 영구)
              |
[보상형]   +6 팔레트 (총 10개) 영구
              |
         프리뷰로 "맛보기" (적용만 잠금)
              |
    +---------+---------+
    |                   |
[W990]              [W990]
글자색 피커           테마 슬롯 3개
    |                   |
    +---------+---------+
              |
         [W1,500 번들] (24% 할인)
```

### 6. 팔레트 확장 보류

- 현재 10개가 주요 컬러 패밀리 커버
- HCT 엔진으로 품질은 이미 확보
- 추가 팔레트는 v1.1+ 업데이트 이벤트로 활용 (리텐션)

## 측정 지표

| 이벤트 | 의미 |
|--------|------|
| `iap_custom_color_purchase` | W990 글자색 전환율 |
| `iap_theme_slots_purchase` | W990 슬롯 전환율 |
| `iap_theme_bundle_purchase` | W1,500 번들 전환율 |
| `theme_slot_count` | 유저당 슬롯 사용 수 |
| `theme_slot_switch` | 슬롯 전환 빈도 |
| `theme_preview_to_purchase` | 프리뷰→구매 퍼널 |

## 참조

- 이전 합의: `docs/discussions/2026-03-07-theme-ux-differentiation.md`
- HCT 엔진: `lib/presentation/theme/custom_scheme_builder.dart`
- 수익화 규칙: `.claude/rules/00-project.md` (IP 제한, 시간제 금지)
