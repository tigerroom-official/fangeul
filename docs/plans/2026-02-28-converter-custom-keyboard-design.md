# 변환기 커스텀 한글 키보드 설계서

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:writing-plans to create implementation plan from this design.

**Goal:** 시스템 키보드를 완전 대체하는 인앱 커스텀 QWERTY 한글 키보드를 변환기 화면 3탭 모두에 적용한다.

**Architecture:** Fangeul 기존 엔진(KeyboardConverter, HangulEngine, Romanizer) + 새 키보드 위젯 + FSM 자모 조합기

**Tech Stack:** Flutter widgets, Riverpod, HapticFeedback, 기존 core/engines

**참고 구현:** `/Users/dakhome/Develop/work-flutter/typing_convertor` ("영타로" 앱)

---

## 1. 핵심 컨셉

변환기 화면에서 시스템 키보드를 숨기고, 앱 자체의 커스텀 QWERTY 키보드를 항상 표시한다.
한글 자판이 없는 글로벌 K-pop 팬도 한글을 입력/변환할 수 있다.

### 모드별 동작

| 탭 | 키보드 라벨 | 탭 시 입력 | 변환 엔진 | 출력 |
|----|-----------|-----------|----------|------|
| 영→한 | 영문(주) + 한글(부) | 영문자 | `KeyboardConverter.engToKor()` | 한글 |
| 한→영 | 한글(주) + 영문(부) | 한글 자모 → FSM 조합 | `KeyboardConverter.korToEng()` | 영문 |
| 발음 | 한글(주) + 영문(부) | 한글 자모 → FSM 조합 | `Romanizer.romanize()` | 로마자 |

- **영→한**: 기존 `KeyboardConverter.engToKor()` 그대로 사용. 키 탭 → 영문자 누적 → 엔진 변환.
- **한→영/발음**: 키보드 위젯 내 FSM이 자모를 음절로 조합 → 조합된 한글을 엔진에 전달.

---

## 2. 키보드 레이아웃

QWERTY 두벌식 표준 배열. 3행 + 특수키.

```
Row 1 (10키):  Q/ㅂ  W/ㅈ  E/ㄷ  R/ㄱ  T/ㅅ  Y/ㅛ  U/ㅕ  I/ㅑ  O/ㅐ  P/ㅔ
Row 2 (9키+DEL): A/ㅁ  S/ㄴ  D/ㅇ  F/ㄹ  G/ㅎ  H/ㅗ  J/ㅓ  K/ㅏ  L/ㅣ  [⌫]
Row 3 (CAPS+7키+SPACE): [⇧]  Z/ㅋ  X/ㅌ  C/ㅊ  V/ㅍ  B/ㅠ  N/ㅜ  M/ㅡ  [___]
```

### 키 표시 방식

각 키에 두 줄 텍스트:
- **영→한 모드**: 상단 영문(크게), 하단 한글(작게)
- **한→영/발음 모드**: 상단 한글(크게), 하단 영문(작게)

### CAPS(쌍자음) 모드

CAPS 활성 시 해당 키만 쌍자음/추가모음으로 전환:
- Q→ㅃ, W→ㅉ, E→ㄸ, R→ㄲ, T→ㅆ, O→ㅒ, P→ㅖ
- 나머지 키는 변화 없음

---

## 3. 비주얼 스타일 — "Fangeul 프리미엄"

### 컬러

```
키보드 배경: darkBackground (#1E1E2E)
키 배경: darkSurface 밝게 (#2A2A3E)
키 눌림: teal 20% overlay

자음 키 한글: primary (#4ECDC4) 100%
모음 키 한글: primary (#4ECDC4) 60% opacity
영문 보조: onSurfaceVariant (#A0A0B8) 40% opacity

CAPS 활성 상태: 키 배경 teal 15%, 아이콘 teal
DEL: onSurfaceVariant 아이콘
SPACE: onSurfaceVariant + "Space" 텍스트
```

라이트 모드에서는 반전:
```
키보드 배경: lightBackground
키 배경: lightSurface
자음/모음: darkPrimary 계열
```

### 타이포그래피

- 주 라벨(한글 또는 영문): NotoSansKR Medium 16pt
- 부 라벨: NotoSansKR Regular 10pt
- CAPS/DEL/SPACE: 아이콘 20pt 또는 텍스트 12pt

### 키 크기

- 일반 키: `(screenWidth - 패딩) / 10` 너비, 높이 48dp (터치 타겟 준수)
- CAPS: 1.5배 너비
- SPACE: 2배 너비
- DEL: 1배 너비 (아이콘)
- 키 간 간격: 4dp
- 키 모서리: borderRadius 8dp
- 키 그림자: elevation 없음 (플랫), 배경색 차이로 구분

---

## 4. 특수 키 동작 (기존 대비 개선)

### DEL — 가속 삭제 (시스템 키보드 모방)

기존 "영타로": 고정 80ms 간격 반복.
개선: **시스템 키보드처럼 단계적 가속**.

```
Phase 1: 첫 탭 → 1글자 삭제
Phase 2: 400ms 홀드 → 반복 시작 (150ms 간격, 1글자씩)
Phase 3: 1500ms 이후 → 가속 (50ms 간격, 빠른 삭제)
Phase 4: 손 떼면 즉시 중단
```

### CAPS — 원샷 vs 잠금

기존: 토글 (한번 누르면 계속 유지).
개선: **원샷 기본 + 더블탭 잠금**.

```
1탭: 다음 1글자만 쌍자음 (입력 후 자동 해제)
2탭 (빠르게): 쌍자음 잠금 (다시 누를 때까지 유지)
시각: 원샷 = 아이콘 teal, 잠금 = 아이콘 teal + 밑줄
```

### SPACE

- 탭: 공백 입력
- 한→영/발음 모드에서 조합 중인 음절을 확정하고 공백 추가

### 햅틱 피드백

| 동작 | 피드백 |
|------|--------|
| 일반 키 탭 | `HapticFeedback.selectionClick()` |
| DEL 탭 | `HapticFeedback.lightImpact()` |
| CAPS 토글 | `HapticFeedback.mediumImpact()` |
| DEL 가속 진입 | `HapticFeedback.heavyImpact()` 1회 |

---

## 5. FSM 자모 조합기 (한→영/발음 모드)

한→영 및 발음 모드에서 키보드가 직접 한글 자모를 음절로 조합한다.

### 상태 다이어그램

```
Empty ──[초성]──→ Initial ──[중성]──→ Medial ──[종성]──→ Final
  ↑                  │                  │                 │
  │                  │[중성X]           │[종성X]          │[초성]
  │                  ↓                  ↓                 ↓
  │              자모 출력          음절 확정          음절 확정 +
  │                                                   새 초성으로
  └─────────────────────────────────────────────────────┘
```

### 상세 전환 규칙

1. **Empty + 초성** → `Initial` (초성 대기)
2. **Empty + 중성** → 모음 단독 출력, `Empty`로 복귀
3. **Initial + 중성** → `Medial` (초성+중성 조합 중)
4. **Initial + 초성** → 이전 자음 출력, 새 초성으로 `Initial`
5. **Medial + 종성 후보** → `Final` (초+중+종 조합 중)
6. **Medial + 중성** → 복합모음 시도 (`HangulTables.compoundVowelCombine`)
   - 성공: `Medial` 유지 (복합모음)
   - 실패: 현재 음절 확정, 새 모음 단독 출력
7. **Final + 초성** → 종성이 다음 음절의 초성이 될 수 있는지 확인
   - 다음 글자가 모음이면: 종성을 분리하여 새 초성으로
   - 아니면: 현재 음절 확정, 새 `Initial`
8. **Final + 종성** → 겹받침 시도 (`HangulTables.doubleFinalCombine`)
   - 성공: `Final` 유지 (겹받침)
   - 실패: 현재 음절 확정, 새 `Initial`

### DEL 동작 (조합 중)

조합 중인 상태에서 DEL은 **마지막 자모만 삭제** (음절 전체 삭제가 아님):
- `Final` → `Medial` (종성 제거)
- `Medial` → `Initial` (중성 제거)
- `Initial` → `Empty` (초성 제거)

### 음절 조합

```dart
HangulEngine.compose(initialIdx, medialIdx, finalIdx)
```

기존 `HangulEngine`의 `compose()` 메서드를 그대로 활용.

---

## 6. 아키텍처

### 파일 구조

```
lib/presentation/
├── widgets/
│   ├── korean_keyboard.dart          # 키보드 UI 위젯 (ConsumerWidget)
│   └── keyboard_key.dart             # 개별 키 위젯
├── providers/
│   └── keyboard_providers.dart       # KeyboardNotifier + JamoAssembler
└── screens/
    └── converter_screen.dart         # 기존 — 시스템 키보드 → 커스텀 키보드로 교체
```

### Provider 설계

```dart
// 키보드 상태
@freezed
sealed class KeyboardState with _$KeyboardState {
  const factory KeyboardState({
    @Default(false) bool isCapsLocked,
    @Default(false) bool isCapsOneShot,
    @Default(ConvertMode.engToKor) ConvertMode mode,
    @Default('') String composing,  // 조합 중인 자모 (한→영/발음 모드)
  }) = _KeyboardState;
}

// JamoAssembler — FSM 자모 조합기 (한→영/발음 모드 전용)
class JamoAssembler {
  AssemblerState state = AssemblerState.empty;
  int? initialIdx;
  int? medialIdx;
  int? finalIdx;

  String? addJamo(String jamo);  // 자모 추가 → 확정된 음절 반환 (없으면 null)
  String? backspace();           // 마지막 자모 삭제
  String? flush();               // 조합 중인 음절 강제 확정
}
```

### 데이터 흐름

```
[키보드 위젯]
     │ 키 탭
     ▼
[KeyboardNotifier]
     │ 모드 확인
     ├── 영→한: 영문자 → converterNotifier.convert(text, engToKor)
     └── 한→영/발음: 자모 → JamoAssembler → 조합된 한글 → converterNotifier.convert(text, mode)
     ▼
[ConverterNotifier] (기존)
     │ 엔진 호출
     ▼
[변환 결과 표시]
```

### converter_screen.dart 변경사항

- `TextField`에 `readOnly: true`, `showCursor: true` 설정 → 시스템 키보드 차단
- 기존 `ConverterInput` 위젯 하단에 `KoreanKeyboard` 위젯 배치
- 300ms 디바운스 제거 (커스텀 키보드는 키 단위 입력이므로 즉시 변환)
- 탭 전환 시 `KeyboardNotifier`의 모드 업데이트

---

## 7. 기존 대비 개선 포인트

| 영역 | 기존 (영타로) | 개선 (Fangeul) |
|------|-------------|---------------|
| DEL | 고정 80ms 반복 | 가속 삭제 (400ms→150ms→50ms) |
| CAPS | 토글 (잠금만) | 원샷 + 더블탭 잠금 |
| 햅틱 | `lightImpact` 단일 | 키 종류별 차등 햅틱 |
| 컬러 | 자음 초록/모음 빨강 | 브랜드 teal + 투명도 차이 |
| 상태관리 | ChangeNotifier | Riverpod freezed |
| DEL 조합 | 음절 전체 삭제 | 자모 단위 삭제 (FSM 역추적) |
| 터치 타겟 | 35dp 고정 | 48dp (Material 가이드라인) |
| 다크/라이트 | 없음 | 테마 연동 |

---

## 8. MVP 스코프 vs v1.1

| 항목 | MVP (Phase 4.5) | v1.1 |
|------|----------------|------|
| 키보드 렌더링 | Flutter 위젯 (Container + GestureDetector) | Rive 인터랙티브 키보드 |
| 터치 피드백 | Ripple + 차등 Haptic | Rive 키 애니메이션 (눌림 효과) |
| FSM 자모 조합 | 기본 조합 (겹받침, 복합모음) | 동일 |
| 키 팝업 | 미구현 | 누른 키 확대 팝업 |
| 결과 저장 | 미구현 | 즐겨찾기/히스토리 |
| 사운드 | 없음 | 옵션: 키 클릭 사운드 |
| 온보딩 | 없음 | Lottie 튜토리얼 오버레이 |

---

## 9. 테스트 전략

### 유닛 테스트
- `JamoAssembler`: FSM 상태 전환 전체 케이스
  - 기본 조합 (ㄱ+ㅏ→가)
  - 종성 (ㄱ+ㅏ+ㄴ→간)
  - 겹받침 (ㄱ+ㅏ+ㄹ+ㄱ→갈ㄱ vs 갈+모음→가+ㄹ+모음)
  - 복합모음 (ㅗ+ㅏ→ㅘ)
  - DEL 역추적 (간→가→ㄱ→빈값)
  - 연속 입력 (한글→한글 음절 경계)
- `KeyboardNotifier`: 상태 전환, CAPS 원샷/잠금

### 위젯 테스트
- 키 탭 → 올바른 문자 입력
- 모드 전환 → 라벨 반전
- CAPS → 쌍자음 키 라벨 변경
- DEL 롱프레스 → 가속 삭제

---

## 10. 참고 문서

| 문서 | 경로 |
|------|------|
| 전체 기획서 | `docs/fangeul-product-spec.md` |
| 엔진 가이드 | `docs/engine-guide.md` |
| Phase 4 설계서 | `docs/plans/2026-02-27-phase4-ui-design.md` |
| 기존 구현 참고 | `/Users/dakhome/Develop/work-flutter/typing_convertor` |
