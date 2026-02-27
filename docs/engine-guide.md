# Fangeul — Core Engine 구현 가이드

> CLAUDE.md에서 분리된 엔진 상세 가이드. 구현 시 참조.

## 1. 한글 엔진 (`core/engines/hangul_engine.dart`)

순수 Dart, Flutter 의존성 없이 구현. 유닛 테스트 100% 커버리지.

### 유니코드 한글 블록

- 범위: U+AC00 (가) ~ U+D7A3 (힣)
- 총 11,172자 = 19초성 × 21중성 × 28종성

### 분해 공식

```
offset = charCode - 0xAC00
초성 = offset ÷ (21 × 28)
중성 = (offset % (21 × 28)) ÷ 28
종성 = offset % 28
```

### 조합 공식

```
0xAC00 + (초성 × 21 + 중성) × 28 + 종성
```

### 겹받침 (11개)

ㄳ, ㄵ, ㄶ, ㄺ, ㄻ, ㄼ, ㄽ, ㄾ, ㄿ, ㅀ, ㅄ

### 파일 분리

- `hangul_engine.dart` — HangulEngine 클래스 (분해/조합/판별)
- `jamo.dart` — Jamo 데이터 클래스 (초성/중성/종성 immutable)

## 2. 키보드 위치 변환 (`core/engines/keyboard_converter.dart`)

두벌식 표준 자판 매핑. 상세 매핑 테이블: `docs/fangeul-product-spec.md` 부록 B.

### 매핑 요약

```
일반:
q→ㅂ  w→ㅈ  e→ㄷ  r→ㄱ  t→ㅅ  y→ㅛ  u→ㅕ  i→ㅑ  o→ㅐ  p→ㅔ
a→ㅁ  s→ㄴ  d→ㅇ  f→ㄹ  g→ㅎ  h→ㅗ  j→ㅓ  k→ㅏ  l→ㅣ
z→ㅋ  x→ㅌ  c→ㅊ  v→ㅍ  b→ㅠ  n→ㅜ  m→ㅡ

Shift:
Q→ㅃ  W→ㅉ  E→ㄸ  R→ㄲ  T→ㅆ  O→ㅒ  P→ㅖ
```

### 변환 흐름

- **영→한:** 영문자 → 자모 매핑 → 복합모음/겹받침 조합 → HangulEngine.compose
- **한→영:** HangulEngine.decompose → 자모 역매핑 → 영문자열
- Shift 상태: 쌍자음(ㅃㅉㄸㄲㅆ) + 추가 모음(ㅒㅖ)

## 3. 로마자 발음 변환 (`core/engines/romanizer.dart`)

국립국어원 로마자 표기법(2000년 고시) 기반. **테이블 드리븐 규칙 엔진** (하드코딩 조건문 금지).

### 참조 오픈소스

- `zaeleus/hangeul` (Rust) — https://github.com/zaeleus/hangeul
- KOROMAN (부산대) — https://roman.cs.pusan.ac.kr/input_eng.aspx

### 발음 변화 규칙 (우선순위 순)

| # | 규칙 | 예시 | 결과 |
|---|------|------|------|
| 1 | 연음법칙 | 없어요 → [업서요] | eopseoyo |
| 2 | 비음화 | 합니다 → [함니다] | hamnida |
| 3 | 격음화 | 좋다 → [조타] | jota |
| 4 | 구개음화 | 같이 → [가치] | gachi |
| 5 | 경음화 | 학교 → [학꾜] | hakkkyo |
| 6 | ㄹ 비음화 | 심리 → [심니] | simni |
| 7 | 유음화 | 설날 → [설랄] | seollal |

### 구현 아키텍처: 2-pass 방식

```
Pass 1: 전처리 — 전체 음절을 _SyllableInfo 리스트로 변환,
         음절 경계에서 발음 변화 규칙을 적용하여 초성/종성 변경
Pass 2: 로마자 변환 — 전처리된 음절 리스트를 로마자로 매핑
```

- `Jamo` 클래스는 immutable 유지
- 내부 `_SyllableInfo` 래퍼 클래스로 mutable 상태 관리
- 규칙 테이블은 `Map<String, Map<String, ...>>` 구조

## 4. 플로팅 버블 (네이티브 Kotlin)

**외부 패키지 사용 금지.** 직접 Kotlin으로 구현.

```
android/app/src/main/kotlin/com/tigerroom/fangeul/FloatingBubbleService.kt
lib/platform/floating_bubble_channel.dart
```

- Android Foreground Service + WindowManager 오버레이
- SYSTEM_ALERT_WINDOW 권한 요청 플로우
- Flutter ↔ Kotlin Platform Channel (MethodChannel)
- 채널명: `com.tigerroom.fangeul/floating_bubble`
- 메서드: `showBubble`, `hideBubble`, `onBubbleTap`, `sendConvertResult`

> Product spec에 나열된 `flutter_overlay_window`, `system_alert_window` 등은
> 로직 참조용이며, 실제로는 직접 구현한다.
