# Fangeul — Hard Rules (위반 금지)

> 절대 위반하면 안 되는 가드레일. 코드 스타일/패턴은 `01-code-conventions.md` 참조.

## 절대 금지 (DO NOT)
- `setState()` 사용 금지 → Riverpod Provider만
- `print()` 금지 → `debugPrint()` 사용
- 상대경로 import 금지 → `package:fangeul/` 사용
- barrel export (index.dart) 금지
- `core/`에서 Flutter/외부 패키지 import 금지
- 비즈니스 로직을 위젯 안에 넣지 않음
- 하드코딩 문자열 금지 → JSON 또는 상수 파일
- 테스트 없이 `core/engines/` 코드 수정 금지
- `any`, `dynamic` 타입 최소화
- MVP에서 SQLite/Hive 사용 금지
- 앱 설정: `shared_preferences` 사용
- 게임/보상 상태: `flutter_secure_storage` + HMAC 필수 (§보안 참조)

## 의존성 방향
```
presentation/ → core/  ✅
data/         → core/  ✅
core/         → data/  ❌
core/         → presentation/ ❌
```

## Riverpod 규칙
- `ref.watch` → `build()` 메서드에서만
- `ref.read` → 이벤트 핸들러에서만
- State는 freezed sealed class (initial/loading/success/error)

## 읽지 않는 디렉토리
- `docs/raw-transcripts/` — 대화 원본 아카이브. 참조하지 않음. 정리본은 `docs/discussions/`.

## 법적/IP 제한 (위반 시 DMCA/소송 리스크)
- 가사 표시 금지 → KOMCA 저작권 라이선스 필요, 로열티 정산 의무
- 아이돌 이름/이미지/로고 직접 사용 금지 → 초상권 + 상표권
  - **예외:** 유저 선택 기반 개인화 내 이름 사용은 **템플릿 삽입으로 허용** (`{{group_name}}` → 런타임 치환)
  - 스토어/마케팅에서는 절대 특정 아이돌 이름 사용 금지 유지
- 팬덤명 직접 사용 금지 (ARMY, BLINK 등) → 일부 상표 등록됨
- 대안: 컬러 테마로 우회 ("퍼플 드림", "민트 프레시" 등)
- 앱 메인 액센트에 특정 K-pop 그룹 공식 컬러 사용 금지 (팬덤 편향 방지)

## 보안 & 어뷰징 방어
- 게임/보상 상태는 `flutter_secure_storage` + HMAC-SHA256 서명 필수
- 서명 불일치 시 데이터 초기화 (변조 감지)
- 시간 기반 보상: 단조증가 타임스탬프 검증 필수
- 보상형 광고: 중복 지급 방지 + 5분 쿨다운 + **하루 3회 제품 상한** (기술적 하드캡 10회는 어뷰징 방어용)
- 상세 위협 모델/방어 전략: `docs/fangeul-future-reference.md` §2 참조

## 수익화 규칙 (2026-02-28 확정, 2026-03-04 재검증, 2026-03-08 피벗, 2026-04-06 배너 정책 변경)
- 플로팅 버블 기본 기능(변환, 키보드, 띄우기)은 **전면 무료** — 페이월 금지
- 멤버 이름 치환(`{{member_name}}`)은 **영구 무료** — 개인화 = 입소문 엔진
- 수익화 대상 = 테마 커스터마이징(3-SKU IAP) + 배너/보상형 광고
- MVP = **광고(배너+보상형) + 일회성 IAP** (구독은 Phase 7 이후)
- 테마 IAP 3-SKU: ₩990(피커) + ₩990(슬롯) + ₩1,500(번들) + 동남아 현지 가격
- **보상형 광고 = 프리미엄 테마 24시간 체험 전용** — 기능(즐겨찾기/TTS) 시간제 해금 폐지
- 보상형 1회 시청 → 팔레트 영구 해금(`themeUnlocked`) 유지 (진입 장벽 낮추기)
- 체험 시간: Firebase Remote Config (`unlock_duration_hours`, 기본 24) — A/B 테스트 가능
- 배너: 온보딩 완료 후 즉시 노출 (RC `banner_delay_days` 기본 0) → **IAP 구매 시만** 숨김 (보상형 시청으로는 배너 숨김 안 함)
- 전환 퍼널: Day 0~13 허니문(무제한) → Day 14~ 즐겨찾기 5슬롯+TTS 5회/일 제한 → IAP/보상형
- 즐겨찾기 제한 해금 = **IAP만**
- TTS 제한 해금 = **IAP(영구 무제한) + 보상형(+2회/시청, RC `tts_rewarded_bonus`)** — 같은 문구 재재생은 카운트 안 함
- IAP 아무 SKU 구매 → TTS 무제한 + 즐겨찾기 무제한 + 배너 제거 (공통 혜택)
- D-day 선물 정책: 최애 생일/컴백 당일 24h 전면 해제 (단조증가 타임스탬프 검증 + 중복 방지)
- 수익 구조 목표: 광고 70% + IAP 30% (안정화 후)
- 상세: `docs/discussions/2026-03-08-rewarded-ad-strategy-pivot.md`

## 광고 정책
- 퍼즐/게임 플레이 중 배너 광고 표시 금지 (UX 최우선)
- 배너: 결과 화면, 카드 획득 화면, 캘린더 하단만 (IAP 구매 시 숨김)

## 플랫폼
- Android only (minSdk 26, targetSdk 34)
- 패키지명: `com.tigerroom.fangeul`
- 플로팅 버블: Kotlin 직접 구현, 외부 패키지 금지
- Platform Channel: `com.tigerroom.fangeul/floating_bubble`
