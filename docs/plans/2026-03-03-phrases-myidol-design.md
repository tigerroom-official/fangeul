# PhrasesScreen 마이아이돌 개인화 — 설계서

> 2026-03-03 | Phase: MVP 보완 (Phase 5.5)

## 1. 목표

메인 앱 문구 탭(PhrasesScreen)에 마이아이돌 개인화 문구를 노출한다.
현재 버블 간편모드에만 존재하는 마이아이돌 필터를 메인 앱으로 확장하고,
향후 멤버 레벨 개인화의 토대를 마련한다.

### 배경

- 설계서 §4.2에 "내 아이돌 필터 칩 좌측 고정 (설정 유저만)" 계획됨 — MVP 통합 시 미구현
- 버블의 `CompactPhraseFilterProvider`에는 `.myIdol()` 케이스가 완전 구현됨
- 사용자가 PhrasesScreen 진입 시 아이돌 관련 문구가 없어 당혹

## 2. 설계: 하이브리드 B+C — 개인화가 기본 경험

### 2.1 핵심 원칙

1. **아이돌 설정 유저 = 개인화가 기본 랜딩** — 첫 칩이 아이돌
2. **칩 바에 아이돌 칩 + 태그 칩 공존** — 같은 줄, 모드 전환 없음
3. **화면 분할 없음** — 아이돌 문구도 태그 문구도 동일한 리스트 영역
4. **미설정 유저 = 기존 경험 그대로** — 아이돌 칩 안 보임

### 2.2 칩 바 레이아웃

```
아이돌 설정됨:
[♡ {group}] [전체] [사랑] [응원] [일상] [인사] [감성] [칭찬] [팬덤]

아이돌 미설정:
[전체] [사랑] [응원] [일상] [인사] [감성] [칭찬] [팬덤]
```

- 아이돌 칩: solid fill 강조 (ChoiceChip selected 스타일), 좌측 고정
- 아이돌 칩 선택 = 아이돌 템플릿 문구 표시 (태그 필터 해제)
- 태그 칩 선택 = 일반 문구 표시 (아이돌 칩 해제)
- 상호 배타적 선택 (아이돌 or 태그, 동시 아님)

### 2.3 기본 선택 로직

| 조건 | 기본 선택 |
|------|-----------|
| 아이돌 설정됨 | 아이돌 칩 (개인화 랜딩) |
| 아이돌 미설정 | "전체" 칩 (기존 동작) |

PhrasesScreen 진입 시 자동 판별. 탭 전환 시 매번 재평가.

### 2.4 아이돌 문구 표시

아이돌 칩 선택 시:
1. `allPhrasesProvider`에서 `isTemplate: true` 문구 수집
2. `resolveTemplatePhrase(phrase, displayName)` 호출
3. 치환된 문구를 리스트로 표시 (기존 `PhraseCard` 재사용)

빈 상태: 아이돌 설정됐는데 템플릿 문구가 0개인 경우 → 빈 상태 메시지

## 3. 멤버 레벨 개인화 (Phase B)

### 3.1 개념

- 팬은 그룹뿐 아니라 특정 멤버에 대한 문구를 원함
- 시스템은 멤버명을 **절대 추천하지 않음** — 유저가 직접 입력 (IP/소송 회피)
- 예: "원필아 오늘도 고마워", "정국이 생일 축하해"

### 3.2 데이터 모델

**Phase A (현재 구현 범위):**
```
SharedPreferences:
  my_idol_group_id: "bts" | "custom:DaySix"     (기존)
```

**Phase B (멤버 확장):**
```
SharedPreferences:
  my_idol_group_id: "bts" | "custom:DaySix"     (기존 유지)
  my_idol_member_name: "원필"                     (신규, nullable)
```

- 별도 키로 저장 → 기존 그룹 로직 무파괴
- 멤버명은 항상 유저 입력 (선택 목록 없음)
- 멤버명 null = 그룹 레벨만 적용

### 3.3 템플릿 확장

**Phase A:**
```
{{group_name}} 사랑해요!  →  DaySix 사랑해요!
```

**Phase B:**
```
{{member_name}}아 오늘도 고마워  →  원필아 오늘도 고마워
{{group_name}}의 {{member_name}}  →  DaySix의 원필
```

- `resolveTemplatePhrase()`에 `memberName` 파라미터 추가
- `{{member_name}}` 미설정 시 해당 문구는 필터링 (표시하지 않음)

### 3.4 칩 바 (Phase B)

```
멤버 설정됨:
[♡ 원필] [DaySix] [전체] [사랑] [응원] ...

멤버 미설정, 그룹만:
[♡ DaySix] [전체] [사랑] [응원] ...
```

- 멤버 칩 = 멤버 전용 템플릿 (`{{member_name}}` 포함 문구)
- 그룹 칩 = 그룹 전용 템플릿 (`{{group_name}}` 포함, `{{member_name}}` 미포함)
- 둘 다 있으면 멤버 칩이 첫 번째

### 3.5 Phase B 범위 (현재 구현하지 않음)

- `my_idol_member_name` SharedPreferences 키 추가
- `MyIdolNotifier`에 `selectMember()` / `clearMember()` 메서드
- `myIdolMemberNameProvider` 신규
- IdolSelectScreen에 멤버명 입력 필드 (optional)
- `{{member_name}}` 전용 템플릿 문구 JSON 추가
- `resolveTemplatePhrase()` 확장
- PhrasesScreen 멤버 칩 추가

## 4. Phase A 구현 범위 (현재)

### 4.1 수정 파일

| 파일 | 변경 내용 |
|------|-----------|
| `lib/presentation/screens/phrases_screen.dart` | 아이돌 칩 추가, 아이돌 문구 빌드 로직, 기본 선택 로직 |
| `lib/presentation/widgets/tag_filter_chips.dart` | 아이돌 칩 슬롯 지원 (또는 PhrasesScreen에서 직접 구성) |
| `lib/presentation/constants/ui_strings.dart` | 아이돌 빈 상태 메시지 등 |
| `test/presentation/screens/phrases_screen_test.dart` | 신규: 아이돌 칩 표시/미표시, 선택 동작, 기본 랜딩 |

### 4.2 수정하지 않는 파일

| 파일 | 이유 |
|------|------|
| `my_idol_provider.dart` | 이미 완전 구현됨 (race condition 수정 완료) |
| `template_phrase_provider.dart` | `resolveTemplatePhrase()` 그대로 사용 |
| `compact_phrase_filter_provider.dart` | 버블 전용, PhrasesScreen과 무관 |
| `compact_phrase_list.dart` | 버블 전용 |
| `my_idol_pack.json` | 기존 10개 템플릿 그대로 사용 |

### 4.3 신규 Provider

PhrasesScreen 전용 아이돌 문구 로딩은 **인라인 로직**으로 구현.
별도 provider 불필요 — PhrasesScreen 내에서 `allPhrasesProvider` + `myIdolDisplayNameProvider` 조합.

```dart
// PhrasesScreen 내부
List<Phrase> _buildMyIdolPhrases(List<PhrasePack> packs, String idolName) {
  return packs
      .expand((p) => p.phrases)
      .where((p) => p.isTemplate)
      .map((p) => resolveTemplatePhrase(p, idolName))
      .toList();
}
```

### 4.4 상태 관리

기존 `selectedTagProvider` (StateProvider<String?>) 확장:
- `null` = "전체" (기존)
- `'__my_idol__'` = 아이돌 칩 선택 (신규 sentinel 값)
- `'love'`, `'cheer'` 등 = 태그 선택 (기존)

또는 freezed sealed class로 전환:
```dart
sealed class PhrasesFilter {
  const factory PhrasesFilter.all() = _All;
  const factory PhrasesFilter.myIdol() = _MyIdol;
  const factory PhrasesFilter.tag(String tag) = _Tag;
}
```

**결정:** sentinel 값 방식 채택 — 기존 `selectedTagProvider` 타입(`StateProvider<String?>`) 유지, 변경 최소화. freezed는 오버엔지니어링.

### 4.5 기본 랜딩 결정 로직

```dart
@override
Widget build(BuildContext context) {
  final idolName = ref.watch(myIdolDisplayNameProvider);
  final hasIdol = idolName.valueOrNull != null;
  final selectedTag = ref.watch(selectedTagProvider);

  // 첫 진입 시 기본값 설정 (provider 초기값은 null = "전체")
  // hasIdol이면 아이돌 칩을 기본으로 → 별도 초기화 필요
}
```

초기화 시점: PhrasesScreen 최초 빌드 시 `hasIdol && selectedTag == null` → `ref.read(selectedTagProvider.notifier).state = '__my_idol__'`

### 4.6 3단계 템플릿 필터링 유지

1. **_flattenPacks()** — `!isTemplate` 필터 유지 (태그 선택 시)
2. **_buildMyIdolPhrases()** — `isTemplate` 필터 (아이돌 칩 선택 시)
3. **`{{group_name}}` 원문 노출 불가** — 아이돌 칩 선택 시에만 치환 후 표시

## 5. 테스트 전략

### 5.1 위젯 테스트

- 아이돌 설정 시 아이돌 칩 표시 확인
- 아이돌 미설정 시 아이돌 칩 미표시 확인
- 아이돌 칩 선택 시 템플릿 문구 치환 표시 확인
- 태그 칩 선택 시 아이돌 칩 해제 확인
- 아이돌 칩 선택 시 태그 칩 해제 확인
- 아이돌 설정 유저 기본 랜딩 = 아이돌 칩 선택

### 5.2 통합 테스트

- `{{group_name}}` 원문이 화면에 노출되지 않는지 확인
- 아이돌 선택 → 문구 탭 이동 → 치환된 문구 표시 E2E

## 6. 향후 확장 경로

```
Phase A (현재) → Phase B (멤버 레벨) → Phase C (맞춤 문구 생성)
  그룹 칩          멤버 칩 추가           유저가 템플릿 직접 작성
  기존 템플릿       멤버 전용 템플릿        커뮤니티 공유
```

Phase B는 별도 설계서 작성 후 진행. Phase A의 아키텍처가 Phase B를 자연스럽게 수용하도록 설계됨 (칩 추가 + 템플릿 파라미터 확장만으로 가능).
