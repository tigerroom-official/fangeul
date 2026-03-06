# Theme UX Differentiation - Expert Panel + Codex Review

> Date: 2026-03-07
> Participants: Claude Expert Panel (7) + Codex GPT-5.3 Independent Review
> Status: Consensus reached, implementation planned

## Problem Statement

1. `ColorScheme.fromSeed()` 기반 테마가 accent만 바꾸고 배경/카드/앱바는 거의 동일 -> 체감 변화 미미
2. "Pick Your Own" IAP의 차별화가 색상 자유도뿐이면 구매 동기 약함
3. `dynamicDark()`/`dynamicLight()`에 component theme 누락 -> fromSeed()의 surface 틴팅도 전파 안 됨 (버그)
4. 보상형 5팔레트에 4h 시간제 해금은 테마 특성(1회 설정)에 부적합

## Consensus

### 1. Surface Tinting = ALL Users (A안 채택, 만장일치 + Codex 동의)

- fromSeed()는 이미 surface를 약간 틴팅함 -> component theme만 추가하면 자동 적용
- 무료 품질이 유료 전환 동력 (행동경제학: endowment effect)
- 팬 이코노미에서 "무료가 별로 -> 유료도 안 팔림"이 더 위험한 시나리오
- 기술적으로 분기하는 게 더 복잡 (불필요한 코드 증가)
- 바이럴: 무료 스크린샷이 예뻐야 트위터/인스타 공유 -> 유기적 마케팅

**Codex 핵심 인용**: "free immersive baseline + paid precision/status customization, not free looks broken, paid looks complete"

### 2. Theme Palette Unlock = Permanent (4h 시간제 폐지, 만장일치)

**문제**: 테마는 "설정하면 끝"인 1회성 액션. 4h 해금은 콘텐츠 소비(문구/TTS)용 모델.

- 시나리오 A (한번만 설정): 광고 1회 -> 영구 사용 -> 사실상 무료 해금
- 시나리오 B (자주 변경): 매번 광고 -> "색 바꾸는데 왜 매번 광고?" 1-star 리뷰
- 업계 표준: Simeji, Facemoji, Samsung 키보드 -> 테마는 1회 해금 영구. "시간제 테마"는 없음

**결정**: 보상형 광고 1회 시청 -> 5팔레트 전체 영구 해금. MonetizationState에 `themeUnlocked: bool` 추가.

**퍼널 구조**:
```
[무료]     벚꽃, 바다, 숲 (3개)
              |
       광고 1회 (FanPass)
              |
[보상형]   노을, 별밤, 새벽, 석양, 보석 (5개, 영구 해금)
              |
         "정확히 내 색이 없어?"
              |
[IAP]     Pick Your Own (자유 HSL + 글자색 + 프리뷰 + Undo)
```

### 3. Pick Your Own IAP Differentiation = "조합의 깊이"

무료/보상형과의 차이:

| | 무료/보상형 | Pick Your Own (IAP) |
|---|-----------|-------------------|
| seed color | 8개 프리셋 | HSL 무제한 |
| surface 틴팅 | O (fromSeed 자동) | O (동일) |
| 글자색 | 자동 대비 | 커스텀 선택 + 프리셋 6종 |
| 프리뷰 | 기본 컬러 카드 | 키보드 레이아웃 + 최애 문구 카드 실시간 |
| Undo | - | O (이전 색 즉시 복구) |
| 가독성 가드레일 | - | WCAG 미달 시 경고 |
| 버블 싱크 (v1.1) | X (기본 틸) | O |

### 4. Preview UI = Killer Feature

기존 `_PreviewCard` (버튼+칩 샘플) -> 키보드 레이아웃 + 최애 이름 문구 카드 실사 프리뷰로 교체.
- 키보드: 자판 라벨 = 선택한 글자색, 키 배경 = seed 기반 surface
- 문구: 사용자의 최애 이름이 삽입된 실제 문구 + 선택한 글자색
- 미구매자에게도 HSL+프리뷰 표시, 적용만 잠금 -> 구매 전환 유도

### 5. Component Theme = P0 Fix (버그 수준)

`dynamicDark()`/`dynamicLight()`에 `dark()`/`light()`와 동일한 component theme 추가:
- appBarTheme, cardTheme, chipTheme, navigationBarTheme, inputDecorationTheme
- 하드코딩 색 대신 `colorScheme.*` 토큰 참조

## Implementation Roadmap

| Priority | Task | Version |
|----------|------|---------|
| P0 | dynamicDark/Light component theme 보강 | v1.0 |
| P0 | 보상형 팔레트 영구 해금 (themeUnlocked flag) | v1.0 |
| P0 | 피커 HSL 미구매자 표시 (적용만 잠금) | v1.0 |
| P1 | 글자색 커스텀 프리뷰 (키보드+문구) | v1.0 |
| P1 | Undo + 가독성 가드레일 | v1.0 |
| P2 | 테마 슬롯 저장 (컴백/콘서트/밤모드) | v1.1 |
| P2 | 버블 색상 싱크 (Kotlin native) | v1.1 |

## Codex Competitive Analysis Sources

- Weverse: https://weverse.io/notice/25045 (Digital Membership app icon, 2025.02)
- Bubble (Dear U): https://play.google.com/store/apps/details?hl=en_US&id=com.dearu.bubble.jyp
- Facemoji: https://apps.apple.com/us/app/facemoji-keyboard-fonts-emoji/id1103138272
- Kika: https://apps.apple.com/us/app/kika-keyboard-custom-themes/id1035199024

## Key Insight

> 테마 수익화의 핵심은 "잠금"이 아니라 "욕구 유발". 무료가 예뻐야 유료가 팔린다.
> 보상형은 퍼널의 중간 계단이지 수익원이 아니다. IAP 전환이 목표.
