# AdMob 배치 + 테마 수익화 전략 -- 전문가 패널 최종 합의

> 날짜: 2026-03-06
> 패널: 리나 빅토리아(동남아 수익화), 잭 레버리지(인디앱 그로스), 윤넛지(행동경제학 UX), 박플러터(Flutter 기술), 김애드옵스(AdMob 운영)
> 이전 토론: `docs/discussions/2026-03-04-phase6-monetization-consensus.md`

---

## 1. 경쟁앱 리서치 결과

| 앱 | 카테고리 | 배너 광고 | 수익 모델 |
|---|---------|----------|----------|
| Weverse | 팬 플랫폼 | 없음 | 팬클럽 멤버십($4/월) + 머천 |
| Bubble (DearU) | 1:1 메시지 | 없음 | 구독 $4/월/아티스트 |
| Choeaedol | 투표/랭킹 | 있음 (프리미엄 제거) | 광고 + 미니게임 + 프리미엄 |
| Duolingo Korean | 언어 학습 | 있음 (구독 제거) | 광고 + 구독 $6.99/월 |
| K-pop 테마앱 | 테마/위젯 | 있음 | 프리미엄 구독 |

**핵심**: 대형 K-pop 팬 플랫폼은 배너 미사용. Fangeul 비교 대상 = Choeaedol/Duolingo급 유틸리티앱.

---

## 2. 전문가 투표 테이블

| # | 결정사항 | 리나 | 잭 | 윤넛지 | 박플러터 | 김애드옵스 | 결과 |
|---|---------|------|-----|--------|---------|-----------|------|
| A | 배너: phrases_screen 하단 1곳, Day 7+ | O | O | O | O | O | **만장일치** |
| B | converter_screen 배너 = 출시 후 데이터 결정 | - | O | O | O | - | **3:0:2** |
| C | shop_screen/settings 배너 = 배제 | O | O | O | O | O | **만장일치** |
| D | FanPassButton = 컨텍스트 트리거 2곳 | O | O | O | O | O | **만장일치** |
| E | SDK 초기화: main.dart fire-and-forget | O | O | O | O | O | **만장일치** |
| F | preloadRewarded: home_screen initState | O | O | O | O | O | **만장일치** |
| G | 퍼널: Day 0~6 무광고 / Day 7+ 배너+보상형 | O | O | O | O | O | **만장일치** |
| H | 배너 시작일 3/4합의 Day 21 -> Day 7 변경 | O | O | O | - | O | **4:0:1** |
| I | 버블 = 광고 프리 존 (제한만 동기화) | O | O | O | O | O | **만장일치** |
| J | birthday/comeback 문구팩 -> 무료 전환 | - | O | O | O | - | **3:0:2** |
| K | 팬 컬러 테마 = 새 IAP 엣지포인트 | O | O | O | O | O | **만장일치** |
| L | 자유 컬러 피커 > 사전 정의 팩 (법적 안전) | O | O | O | O | O | **만장일치** |
| M | 2단계 UX (추천 팔레트 -> 자유 피커 토글) | O | O | O | O | O | **만장일치** |
| N | 무료 3팔레트 + 보상형 5팔레트 + IAP 피커 | O | O | O | O | O | **만장일치** |
| O | IAP: 피커 W990 / 번들(피커+광고제거) W1,900 | O | O | O | O | O | **만장일치** |
| P | 테마: 하이브리드 (배경 고정 + 액센트만 변경) | O | O | O | O | O | **만장일치** |
| Q | 글자색 커스터마이징 불필요 (자동 대비) | O | O | O | O | O | **만장일치** |

---

## 3. 확정 합의 사항

### 3.1 배너 광고 배치

- **phrases_screen 하단 고정** 1곳만 (MVP)
- Day 7+ 노출 시작 (3/4합의 Day 21에서 앞당김 -- AdMob 학습 기간 확보)
- 보상형 1회 시청 -> 세션 배너 숨김 (`sessionBannerHiddenProvider` 기구현)
- IAP W1,900 번들 -> 배너 영구 제거
- converter_screen, shop_screen, settings_screen, idol_select_screen = 배너 없음

### 3.2 FanPassButton 배치

- **컨텍스트 트리거** (상시 노출 아님)
- 진입점 2곳:
  1. `phrases_screen` 유료팩 접근 제한 시
  2. `shop_screen` 팬 패스 섹션
- `phrases_screen` 상단 잔여 횟수 뱃지 (비침습, "N/3" 텍스트)
- 즐겨찾기 포화, TTS 한도 트리거 = v1.1 연기

### 3.3 SDK 초기화

- `main.dart`: `AdService().initialize()` fire-and-forget (await 금지)
- `home_screen` initState: `adService.preloadRewarded()`
- 허니문 중에도 SDK 초기화 (노출만 조건부)

### 3.4 전환 퍼널

| 구간 | 기간 | 전략 |
|------|------|------|
| 허니문 | Day 0~6 | 무광고. 테마 미리보기만 가능. |
| 보상형 습관 | Day 7~13 | 배너 시작 + 보상형 3회/일 (팔레트 4h 해금) |
| IAP 트리거 | Day 14~21 | 3회 소진 + 팔레트 체험 축적 -> IAP 팝업 |
| 이후 | Day 22+ | 컴백/생일 이벤트 시즌 |

### 3.5 버블 정책

- 광고 UI 0 (배너/FanPassButton 없음)
- 수익화 제한(팩/슬롯/TTS)은 동기화 적용
- 제한 도달 시 "메인 앱에서 팬 패스 사용" 안내 텍스트
- 테마 색상: SharedPreferences + reload 패턴으로 동기화

### 3.6 문구팩 무료 전환

- `birthday_pack.json`, `comeback_pack.json` -> `is_free: true` 변경
- 이유: 텍스트 문구의 perceived value 낮음 + 해금 수단 미배치 상태에서 잠금만 있으면 미완성 UX
- 95개 전체 문구 무료 접근 -> "풍부한 앱" 첫인상 + 리뷰 보호
- 간편모드 vs 메인앱 잠금 불일치 자동 해소

### 3.7 팬 컬러 테마 커스터마이징 (새 IAP 엣지)

#### 법적 근거
- 사전 정의 팬 컬러 팩(BTS 보라 등) = IP/상표 리스크 현실적으로 존재
- "I purple you" 상표 사건 선례. 2026.03 K-pop 불법 상품 단속 강화.
- **자유 피커 = 법적 리스크 구조적 제거** (앱이 색을 파는 게 아니라 커스터마이징 기능을 파는 것)

#### UX 설계

```
Step 1: 추천 팔레트 그리드 (8개, 자연 테마명)
        [ 벚꽃  |  노을  |  바다  |  별밤  ]
        [ 숲    |  새벽  |  석양  |  보석  ]

        [직접 고르기 -> ]

Step 2: (토글 시) 리니어 그래디언트 슬라이더 + 채도/명도 조절
        + HEX 코드 직접 입력
        + 실시간 미리보기 카드 (버튼/칩/텍스트 포함)
```

- 추천 팔레트 탭 -> 바로 적용 (대부분 유저)
- "직접 고르기" = 파워 유저용 (팬 컬러 정확히 아는 유저)
- 선택 피로도 방지: 추천이 기본, 자유가 토글

#### 기술 설계: 하이브리드 테마

```dart
// seed에서 생성
final generated = ColorScheme.fromSeed(
  seedColor: userColor,
  brightness: brightness,
);

// 기존 배경/surface 유지 + 액센트만 교체
final hybrid = currentScheme.copyWith(
  primary: generated.primary,
  onPrimary: generated.onPrimary,       // 자동 대비색
  primaryContainer: generated.primaryContainer,
  onPrimaryContainer: generated.onPrimaryContainer,
  secondary: generated.secondary,
  onSecondary: generated.onSecondary,
  tertiary: generated.tertiary,
  // surface, background, onSurface 등은 기존 값 유지!
);
```

- **배경/글자**: 기존 다크 네이비(#0F0F1A) + 밝은 텍스트(#E8E8F0) 그대로 유지
- **액센트(버튼/칩/프라이머리)**: seed 기반 변경 + `onPrimary` 자동 대비
- **글자색 커스터마이징 불필요**: Material 3 `fromSeed`가 `on*` 색상 자동 보장
- **미리보기 카드**: 피커에서 색 선택 시 버튼/칩/텍스트 미리보기 -> 가독성 직접 확인
- **성능**: 드래그 중 미리보기 카드만 변경, 손 떼면 전체 적용

#### 수익화 구조

| 티어 | 가격 | 내용 |
|------|------|------|
| 무료 | W0 | 기본 틸 테마(다크/라이트) + 무료 팔레트 3개 (벚꽃, 바다, 숲) |
| 보상형 | 4h 해금 | 추가 팔레트 5개 (노을, 별밤, 새벽, 석양, 보석) |
| 자유 피커 IAP | W990 일회성 | 무한 색상 + HEX 입력 + 영구 해금 |
| 번들 IAP | W1,900 일회성 | 자유 피커 + 배너 광고 영구 제거 |

---

## 4. 3/4 합의 대비 변경점

| 항목 | 3/4 합의 | 오늘 변경 | 이유 |
|------|----------|----------|------|
| 배너 시작일 | Day 21+ | Day 7+ | AdMob 학습 기간 확보 + 보상형 세션 숨김으로 UX 보호 |
| 배너 위치 | 결과/카드획득/캘린더 | phrases_screen 하단 | v1.0.0 화면 구조 (카드 획득 미구현, 캘린더 화면 없음) |
| IAP 엣지 | 감성 컬러 팩 (문구+스킨) | 자유 컬러 피커 | 법적 안전 + perceived value + IKEA 효과 |
| 문구 잠금 | birthday/comeback 잠금 | 전부 무료 | 텍스트 과금 가치 없음, 테마가 대체 |
| 팩 네이밍 | "퍼플 드림" 감성 이름 | 자연 테마명 (벚꽃/바다/숲) | IP 연상 리스크 완전 제거 |
| 컬러 선택 | 사전 정의 6색 | 유저 자유 선택 + 추천 8개 | 팬이 자기 색을 알고 있음 |
| IAP 가격 | W990/W1,900/W3,900 (3단계) | W990 (피커) / W1,900 (번들) | 단순화 |
| "광고 제거" | 미논의 | W1,900 번들 포함 | 배너 LTV 대비 74배 수익 |

---

## 5. 확정 수익화 치트시트

```
Fangeul v1.0.0 -- 수익화 최종 구조 (2026-03-06)

[무료]
  기본 틸 테마 (다크/라이트)
  무료 팔레트 3개 (벚꽃, 바다, 숲)
  전체 문구 95개 (잠금 없음)
  버블 기본 기능
  멤버 이름 치환

[보상형 광고 -- Day 7+]
  추가 팔레트 5개 (4h 해금, 3회/일)
  세션 배너 제거

[IAP -- 일회성]
  W990  -- 자유 피커 영구 해금 (무한 색상 + HEX)
  W1,900 -- 자유 피커 + 광고 영구 제거 번들

[배너]
  phrases_screen 하단 1곳, Day 7+
  보상형 시청 -> 세션 숨김
  IAP W1,900 -> 영구 제거

[퍼널]
  Day 0~6:  허니문 (무광고, 테마 미리보기만)
  Day 7+:   배너 + 보상형 (팔레트 4h 해금)
  Day 14+:  IAP 트리거 (3회 소진 + 팔레트 체험)

[영구 무료 보장]
  버블 기본 기능 (변환, 키보드, 띄우기)
  멤버 이름 치환 {{member_name}}
  전체 문구 95개
  기본 틸 테마 + 무료 팔레트 3개
```

---

## 6. 미해결 / v1.1 연기 항목

| 항목 | 연기 이유 |
|------|----------|
| converter_screen 배너 | 리텐션 데이터로 결정 |
| 즐겨찾기 포화 FanPassButton | MVP 복잡도 제한 |
| TTS 한도 FanPassButton | MVP 복잡도 제한 |
| 캘린더 전용 화면 | 스코프 크립. DAU 습관 형성 핵심이므로 v1.1 1순위 |
| 프리미엄 문구팩 재설계 | 감성 롱폼 메시지 등 새 포맷 검토 |
| 구독 모델 | Phase 7+ |

---

## 참조

- 이전 수익화 합의: `docs/discussions/2026-03-04-phase6-monetization-consensus.md`
- 수익화 규칙: `.claude/rules/00-project.md`
- K-pop IP 리서치: WIPO Magazine, allkpop 2026.03 단속 기사
- Flutter 기술: `ColorScheme.fromSeed()`, `flex_color_picker`
