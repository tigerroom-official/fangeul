# Phase 5: Floating Bubble — Design Document

> **날짜:** 2026-02-28
> **상태:** 승인됨
> **Codex 리뷰:** 완료 (세션 019ca069-b534-7d91-8881-deb6abe6ffd4)

---

## 1. 개요

Fangeul의 핵심 차별화 기능인 플로팅 버블을 구현한다. 다른 앱(Weverse, Twitter, YouTube) 위에 떠있는 버블을 탭하면 미니 변환기/문구 복사 팝업이 열린다.

**핵심 원칙:** 프리미엄 UX, 타협 없는 풀 기능, 화면 가림 최소화.

---

## 2. 아키텍처: 하이브리드

```
버블 = Kotlin 네이티브 오버레이 (가볍고 안정)
팝업 = Flutter Activity (기존 UI/테마/키보드 재활용, 프리미엄 UX)
엔진 = FlutterEngineCache 프리워밍 → ~200ms 시작
```

**결정 근거:**
- Codex 리뷰: 네이티브 오버레이가 IME/라이프사이클 안정
- 팝업은 Flutter Activity: 기존 커스텀 키보드/테마/Provider 100% 재활용
- FlutterEngine 프리워밍으로 시작 딜레이 ~200ms (허용 범위)

---

## 3. 2단 모드 UX

### 3.1 간편모드 (기본, 화면 ~25%)

버블 탭 시 기본으로 열리는 컴팩트 팝업.

```
┌─────────────────────────────────┐
│  [ ⭐ 즐겨찾기 ]  [ 🕐 최근 ]   │  ← 탭 2개, 마지막 선택 기억
│─────────────────────────────────│
│  사랑해요                   📋  │
│  생일 축하해요              📋  │  ← 원탭 복사
│  화이팅!                    📋  │
│  보고싶어                   📋  │
│─────────────────────────────────│
│   🔍 변환기 열기                │  ← 확장 트리거
└─────────────────────────────────┘
```

- **즐겨찾기 탭**: 사용자가 찜한 문구 (앱 내 PhrasesScreen에서 즐겨찾기 등록)
- **최근 탭**: 복사/변환 이력 (시간순, 최대 20개)
- 마지막 탭 선택 `shared_preferences`에 저장
- 즐겨찾기 비어있으면: "문구 화면에서 ⭐ 탭하여 즐겨찾기 추가" 안내
- 복사 후 자동 dismiss → 바로 붙여넣기 가능 (설정에서 토글 가능)
- 바깥 탭 → dismiss → 버블 복귀

### 3.2 확장모드 (변환기, 화면 ~70%)

간편모드에서 "변환기 열기" 탭 시 확장.

```
┌─────────────────────────────────┐
│  ◀ 간편모드         Fangeul  ✕  │  ← 접기 + 닫기
│─────────────────────────────────│
│  [ 영→한 ]  [ 한→영 ]  [ 발음 ] │  ← 모드 탭 (기존 재활용)
│─────────────────────────────────│
│  ┌───────────────────────┐     │
│  │ Type here...          │     │  ← 입력 필드
│  └───────────────────────┘     │
│  ┌───────────────────────┐     │
│  │ 사랑해요              │ 📋  │  ← 변환 결과 + 원탭 복사
│  └───────────────────────┘     │
│─────────────────────────────────│
│  ┌───────────────────────────┐ │
│  │     커스텀 한글 키보드     │ │  ← KoreanKeyboard 재활용
│  └───────────────────────────┘ │
└─────────────────────────────────┘
```

- 기존 `ConverterScreen` 로직/위젯 최대 재활용
- "◀ 간편모드" → 간편모드로 접기 (애니메이션)
- 변환 결과 복사 → 최근 탭에 자동 추가

---

## 4. 버블 비주얼

- **크기**: 56dp 원형
- **컬러**: 틸 그라데이션 (#4ECDC4 → #3BA8A0) — Fangeul 브랜드
- **아이콘**: "한" 글자 중앙 (Pretendard Medium, 흰색)
- **애니메이션**: 미세 맥박 (scale 1.0↔1.05, 2초 주기)
- **그림자**: elevation 4dp
- **드래그**: 화면 양쪽 가장자리에 스냅 (자석 효과)
- **닫기**: 하단으로 드래그 시 닫기 존 표시 (빨간 X 원형)
- **Notification**: "Fangeul 버블 활성" + 중지 버튼

---

## 5. 파일 구조

```
android/app/src/main/kotlin/com/tigerroom/fangeul/
├── MainActivity.kt                    (기존 — FlutterEngine 프리워밍 추가)
├── FloatingBubbleService.kt           (Foreground Service + 버블 오버레이)
├── MiniConverterActivity.kt           (Flutter Activity — 캐시된 엔진 사용)
└── BubbleNotificationHelper.kt        (알림 채널/빌더 유틸)

lib/platform/
├── floating_bubble_channel.dart       (MethodChannel 래퍼)
└── bubble_state.dart                  (버블 상태 enum: off/showing/popup)

lib/presentation/screens/
└── mini_converter_screen.dart         (팝업 메인: 간편모드 + 확장모드)

lib/presentation/widgets/
├── compact_phrase_list.dart           (간편모드 문구 리스트)
├── favorite_phrase_tile.dart          (즐겨찾기 문구 타일)
└── recent_copy_tile.dart              (최근 복사 타일)

lib/presentation/providers/
├── bubble_providers.dart              (버블 상태 Provider)
├── favorite_phrases_provider.dart     (즐겨찾기 문구 Provider)
└── copy_history_provider.dart         (복사 이력 Provider)
```

---

## 6. Platform Channel 계약

### MethodChannel: `com.tigerroom.fangeul/floating_bubble`

| 방향 | 메서드 | 파라미터 | 반환 |
|------|--------|---------|------|
| Dart→Kotlin | `showBubble` | - | `bool` |
| Dart→Kotlin | `hideBubble` | - | `bool` |
| Dart→Kotlin | `isOverlayPermissionGranted` | - | `bool` |
| Dart→Kotlin | `requestOverlayPermission` | - | `void` |
| Dart→Kotlin | `getBubbleState` | - | `String` |

### EventChannel: `com.tigerroom.fangeul/bubble_events`

| 이벤트 | 데이터 |
|--------|--------|
| `bubbleTapped` | - |
| `bubbleDismissed` | - |
| `permissionChanged` | `bool granted` |

---

## 7. 권한 플로우

```
설정 화면 → "플로팅 버블" 토글
  ├── 권한 있음 → 서비스 시작 → 버블 표시
  └── 권한 없음
      ├── 설명 다이얼로그 ("다른 앱 위에서 바로 한글 변환!")
      ├── ACTION_MANAGE_OVERLAY_PERMISSION → 시스템 설정
      ├── 복귀 시 canDrawOverlays 재확인
      ├── 허용됨 → 서비스 시작
      └── 거부됨 → 토글 off, "앱 내에서도 모든 기능 사용 가능" 안내
```

### AndroidManifest 추가 필요

```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE"/>

<service
    android:name=".FloatingBubbleService"
    android:exported="false"
    android:foregroundServiceType="specialUse">
    <property
        android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE"
        android:value="floating_overlay_for_korean_input"/>
</service>

<activity
    android:name=".MiniConverterActivity"
    android:exported="false"
    android:theme="@style/TranslucentTheme"
    android:launchMode="singleTask"
    android:taskAffinity="com.tigerroom.fangeul.mini"/>
```

---

## 8. 보안

- `FloatingBubbleService`: `exported="false"`
- `MiniConverterActivity`: `exported="false"`
- MethodChannel payload 타입/크기/null 검증
- 오버레이 바운드 최소화 (풀스크린 터치 캡처 금지)
- 클립보드: 명시적 사용자 액션에서만 복사, 텍스트 로깅 금지
- `removeView` 가드 (서비스 종료 시 윈도우 누수 방지)

---

## 9. 테스트 전략

| 레이어 | 테스트 | 도구 |
|--------|--------|------|
| Dart Channel 래퍼 | 메서드 호출 계약, 에러 매핑 | `flutter_test` + mock MethodChannel |
| Bubble Provider | 상태 전이 (off→showing→popup→off) | `riverpod` + `mocktail` |
| Favorite Provider | 추가/제거/persist | unit test |
| Copy History Provider | 추가/20개 제한/시간순 | unit test |
| MiniConverterScreen | 간편↔확장 전환, 복사 동작 | widget test |
| Kotlin Service | 서비스 시작/중지, 윈도우 파라미터 | Robolectric |
| E2E | 권한→버블→간편→변환→복사 | 실기기 수동 |

---

## 10. Codex 리뷰 반영 사항

| Codex 권고 | 반영 |
|-----------|------|
| 네이티브 팝업 권장 | 하이브리드 채택 (버블=네이티브, 팝업=Flutter Activity) |
| FGS specialUse 타입 | AndroidManifest에 명시 |
| Window flags 이중화 | 버블=NOT_FOCUSABLE, 팝업=Activity로 분리 |
| 메서드 목록 확장 | isOverlayPermissionGranted, requestOverlayPermission, getBubbleState 추가 |
| EventChannel 검토 | bubble_events EventChannel 추가 |
| Service exported=false | 보안 섹션에 명시 |
| Android 15 SAW 변경 | 포그라운드 앱에서만 서비스 시작하도록 설계 |
