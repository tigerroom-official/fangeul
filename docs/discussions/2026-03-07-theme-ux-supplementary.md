# 보충 패널 토론 — 2026-03-07

사용자 피드백 반영, Undo 버튼 근본 개선 + 테마 시스템 "최애색" 리디자인

---

## 보충 토픽 A: Undo 버튼 근본 개선

### 사용자 피드백
> "AnimatedSize로 전환하더라도 나타나면 아래 콘텐츠가 밀렸다가, 사라지면 올라오는 건 마찬가지잖아. 근본적으로 개선해봐."

### 자유 토론

---

**한유진 (UX Designer):**

"유저가 이걸 보고 뭘 기대할까요? 근본적으로 생각해봅시다. Undo는 '실수 복구'예요. 그런데 팔레트 그리드에서 색상을 고르는 행위는 실수가 아니라 '탐색'이잖아요. 탭 한 번이면 다른 색으로 돌아가요. Undo가 진짜 필요한 순간은 **커스텀 피커에서 HSL을 세밀하게 조정한 이전 값**을 잃었을 때뿐이에요.

그래서 저는 **방안 1 변형**을 제안합니다. 타이틀 행 오른쪽에 아이콘 버튼으로 넣되, 커스텀 피커 섹션에서만 표시하는 거예요. 팔레트 그리드 영역에서는 아예 안 보이게. 높이 변화 제로, 맥락도 정확."

---

**박수익 (PM):**

"수치로 보면, Undo 버튼의 탭률 자체가 극히 낮을 거예요. 색상 탐색 UI에서 undo가 필요한 유저는 커스텀 피커 헤비유저, 즉 IAP 구매자 혹은 구매 직전 유저입니다. 이 소수를 위해 전체 레이아웃이 들썩이는 건 ROI가 안 맞아요.

**방안 4 + 1 하이브리드**를 지지합니다. 팔레트 그리드에서는 Undo 제거 -- 이전 색상은 그리드 자체가 히스토리니까. 커스텀 피커에서만 타이틀 행 인라인 아이콘 버튼. 구현 비용 최소, UX 임팩트 최대."

---

**김팬심 (K-pop 팬 UX Researcher):**

"덕질은 감정이에요. 최애색 고르는 순간은 진지한 거예요. 근데 색 바꿨는데 아래 카드가 위아래로 출렁거리면? '앱이 불안정하다'는 느낌을 줘요. 감정 몰입이 깨지죠.

저도 **방안 1**이요. 근데 한유진 님 말처럼 커스텀에서만이 아니라, **항상 타이틀 행 오른쪽에 아이콘으로 있되, 되돌릴 게 없으면 비활성(opacity 0.3)**이면 어때요? 공간 변화 제로면서, '되돌리기가 가능하다'는 어포던스를 항상 제공하는 거죠. 방안 5랑 비슷한데, 별도 행이 아니라 타이틀 행 인라인이라 높이 추가가 없어요."

---

**이구현 (Flutter UI Engineer):**

"Material 3 스펙에 따르면, 되돌리기 같은 보조 액션은 AppBar의 actions 영역이나 인라인 아이콘 버튼이 표준이에요. 별도 행을 만드는 건 Material 패턴에서 벗어나요.

구현 관점에서 정리하면:

- **방안 1 (타이틀 행 인라인 아이콘)**: `Row` children에 `Spacer()` + `IconButton(Icons.undo)` 추가. 높이 변화 제로. `AnimatedOpacity`로 활성/비활성. **가장 간단하고 안정적.**
- **방안 2 (SnackBar)**: `ScaffoldMessenger`가 DraggableScrollableSheet 내부에서 제대로 작동 안 할 수 있어요. 시트 밖의 Scaffold에 떠야 하는데, 그러면 시트와의 상호작용 컨텍스트가 끊겨요.
- **방안 3 (핸들 바 옆)**: 핸들 바 영역은 Material Bottom Sheet 스펙상 드래그 제스처 전용이에요. 여기에 버튼 넣으면 드래그 미스터치 유발.
- **방안 5 (항상 표시)**: 별도 행이면 48px 항상 차지. 타이틀 인라인이면 방안 1과 동일.

저는 **방안 1 + 김팬심 님의 비활성 상태 유지 변형**이 최선이라고 봅니다."

---

**최미학 (Visual Designer):**

"색상은 감정이에요. Undo 버튼이 색 고르는 공간을 방해하면 안 돼요.

타이틀 행 오른쪽 `undo` 아이콘 -- 이거 좋아요. 근데 디테일이 중요해요. 활성 시에는 `colorScheme.primary`로 또렷하게, 비활성 시에는 `colorScheme.onSurfaceVariant.withOpacity(0.25)`로 거의 안 보이게. **AnimatedOpacity 200ms**면 충분해요. 텍스트 라벨 없이 아이콘만. `Icons.undo_rounded`.

그리고 커스텀 피커에서 Undo 탭 시 색상이 롤백되는 순간, 미리보기가 부드럽게 전환되면 '아, 되돌아갔구나' 피드백이 명확해져요. 별도 토스트 불필요."

---

### 반론 및 수렴

**한유진:** "김팬심 님 + 이구현 님 의견 동의해요. 커스텀에서만 보이게 하는 것보다 항상 인라인에 두되 비활성이 더 나아요. 어포던스 일관성."

**박수익:** "팔레트 그리드에서도 Undo 아이콘이 있으면... 탭률은 낮겠지만 해치는 것도 없으니 수용합니다. 타이틀 행 인라인이면 레이아웃 변화 제로니까."

---

### 투표 결과

| 방안 | 유진 | 수익 | 팬심 | 구현 | 미학 | 합계 |
|------|:----:|:----:|:----:|:----:|:----:|:----:|
| 1-변형: 타이틀 행 인라인 아이콘 + 비활성 상태 유지 | **O** | **O** | **O** | **O** | **O** | **5/5** |
| 2: SnackBar/FAB | - | - | - | - | - | 0 |
| 3: 핸들 바 옆 | - | - | - | - | - | 0 |
| 4: 제거 | - | - | - | - | - | 0 |
| 5: 별도 행 항상 표시 | - | - | - | - | - | 0 |

**만장일치: 방안 1 변형 (타이틀 행 인라인 아이콘 + AnimatedOpacity 비활성)**

---

### 합의 구현 방안 (코드 레벨)

**현재 구조 (제거 대상):**
```dart
// 별도 행으로 Undo 표시 -> 48px 높이 변화 유발
if (canUndo)
  _UndoButton(onPressed: ...),  // 독립 위젯, 자체 높이 차지
```

**새 구조:**
```dart
/// _TitleSection 내부 -- 타이틀 텍스트와 같은 Row
class _TitleSection extends StatelessWidget {
  final String title;
  final bool canUndo;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          // Undo 아이콘 -- 항상 존재, 활성/비활성만 전환
          AnimatedOpacity(
            opacity: canUndo ? 1.0 : 0.25,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: IconButton(
              icon: const Icon(Icons.undo_rounded, size: 20),
              color: canUndo
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              onPressed: canUndo ? onUndo : null,
              tooltip: 'Undo',  // l10n: context.l10n.undo
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**핵심 포인트:**
- `AnimatedOpacity` -- 비활성 시 0.25, 활성 시 1.0, 200ms easeOut
- `onPressed: canUndo ? onUndo : null` -- null이면 Material이 자동으로 비활성 처리
- `VisualDensity.compact` + `constraints(32x32)` -- 타이틀 행 높이 증가 최소화
- 별도 Undo 행 위젯 완전 제거 -> **레이아웃 시프트 제로**

---

### 액션 아이템

| # | 작업 | 담당 | 비고 |
|---|------|------|------|
| A-1 | 기존 `_UndoButton` 독립 위젯 제거 | 구현 | AnimatedSize 관련 코드도 함께 제거 |
| A-2 | `_TitleSection`에 undo 아이콘 인라인 통합 | 구현 | 위 코드 패턴 |
| A-3 | 팔레트 그리드 / 커스텀 피커 양쪽에서 `canUndo` 상태 전달 확인 | 구현 | 기존 previousColor 로직 재활용 |
| A-4 | l10n 키 추가: `themePickerUndo` | 구현 | 툴팁용 |
| A-5 | 좁은 화면(320dp) 실기기 검증 | 유진 | 타이틀 잘림 없는지 확인 |

---
---

## 보충 토픽 B: 테마 시스템 근본 리디자인 -- "최애색"

### 사용자 피드백 (원문)
> "Theme Dark/Light/System은 그대로 유지하고, 'Theme Color' 대신 'Fangeul Color' or '최애색' 같은 감성적 컬러 설정 모드로. 이 설정팩은 Theme에 덧대는 게 아니라 무시하고 설정된 값으로 지정하게. 컬러팩은 니가 잘 정해서 글자색 잘 보이게 하고, 커스텀은 진짜 커스텀하게 맡겨. Auto contrast 기능은 유지. 자유도가 있어야 돈을 쓰지."

### 현재 문제 분석
1. "Theme Color" = "Dark/Light에 덧대는 accent 색" 느낌 -> 체감 미약
2. fromSeed()가 surface 채도를 자동 낮춤 -> 유저가 고른 색과 결과물 괴리
3. 커스텀 피커(Pick Your Own)에서도 fromSeed()가 중간에 "필터링" -> "내가 원하는 대로 설정하는데 한계"
4. 프리미엄 IAP 가치: 자유도 = 구매 동기

### 사용자가 원하는 모델
```
[밝기 레이어] Dark | Light | System   <-- 그대로 유지
       |
[최애색 레이어] 팔레트팩 or 커스텀     <-- 완전 오버라이드, 덧대기 아님
       |
 결과: "최애색"이 앱 전체를 장악
```

---

### 자유 토론

---

**김팬심 (K-pop 팬 UX Researcher):**

"덕질은 감정이에요! '최애색'이라는 이름부터 완벽해요. 'Theme Color'는 개발자 용어잖아요. 팬한테 '테마 컬러 바꿀래?' 하면 '뭔 소리?' 하는데, '최애색 골라봐!' 하면 '아 내 최애 BTS 보라색!' 이렇게 바로 연결돼요.

근데 핵심은 이거예요 -- **유저가 고른 색이 진짜로 앱 전체를 장악해야 해요.** 지금 `fromSeed()`가 중간에서 채도를 낮추니까, 보라색 골랐는데 앱이 회보라색? '이거 내 색 아닌데?' 이런 괴리감이요. 팬은 자기 최애 그룹 컬러에 진심이에요. 정확한 그 색이 나와야 해요.

팔레트팩 이름도 '퍼플 드림'보다 더 감성적이면 좋겠어요. '콘서트 앙코르', '첫 팬미팅', '생일 카페'... 팬 경험 기반 네이밍."

---

**최미학 (Visual Designer):**

"색상은 감정이에요. 김팬심 님 200% 동의합니다.

기술적으로 핵심 문제를 짚자면 -- `ColorScheme.fromSeed()`는 Material 3의 HCT(Hue-Chroma-Tone) 알고리즘을 써요. 이게 **접근성을 위해 채도를 의도적으로 낮춰요.** Primary는 괜찮은데, surface 계열이 거의 무채색으로 빠지죠. 팬이 보라색을 골랐는데 배경이 그냥 회색이면 -- '최애색을 골랐다'는 느낌이 안 나요.

제 제안:

**팔레트팩 = 수동 튜닝 ColorScheme 풀셋.** fromSeed() 쓰지 않아요. 디자이너가 dark/light 양쪽 모두 primary, primaryContainer, surface, surfaceContainerLow/Medium/High, onSurface 전부 수동 지정. 이래야 '이 팔레트를 고르면 앱이 이 느낌'이라는 보장이 돼요.

**커스텀 피커 = fromSeed() 우회.** 유저가 고른 seed color에서:
- `primary` = seed color 그대로
- `primaryContainer` = seed HSL에서 lightness만 조정
- `surface` 계열 = seed hue 유지 + 채도 20~30% + lightness dark/light에 따라 조정
- `onSurface` = Auto contrast로 흑/백 자동 선택

이렇게 하면 '보라색 골랐는데 앱이 진짜 보라색'이 됩니다."

---

**이구현 (Flutter UI Engineer):**

"Material 3 스펙에 따르면... 사실 스펙을 좀 벗어나야 해요 여기서. `fromSeed()`는 Material Design 가이드라인의 dynamic color를 위한 것이고, 우리 유스케이스는 '팬 정체성 표현'이니까 다른 접근이 맞아요.

구현 아키텍처를 제안합니다:

```
FangeulTheme
+-- brightness: Brightness  <-- System/Dark/Light 설정에서 결정
+-- choeaeColor: ChoeaeColorConfig  <-- '최애색' 레이어
|   +-- PalettePackConfig(packId)     <-- 미리 정의된 풀 ColorScheme
|   +-- CustomConfig(seedColor, textColorOverride?)  <-- 유저 선택
+-- buildColorScheme() -> ColorScheme  <-- 최종 합성
```

핵심은 **seed hue를 surface까지 전파**하되, 채도를 원본의 15~30%로 유지하는 거예요. fromSeed()의 HCT 알고리즘은 채도를 5% 미만으로 떨어뜨리는데, 우리는 의도적으로 높게 가져가서 '색이 앱을 장악하는' 느낌을 줍니다."

---

**한유진 (UX Designer):**

"유저가 이걸 보고 뭘 기대할까요? '최애색을 골랐다' -> '앱이 내 색이 되었다'. 이 기대를 충족시키려면 최미학 님, 이구현 님 말처럼 surface까지 색이 닿아야 해요.

근데 우려가 있어요:

1. **가독성 안전장치.** surface에 채도를 올리면 위에 올라가는 텍스트 가독성이 떨어질 수 있어요. Auto contrast가 on/off 토글이 아니라 **항상 기본 활성**이어야 해요. 커스텀 글자색 오버라이드는 IAP 유저만 가능하되, WCAG AA 미달 시 경고 배지.

2. **'최애색' 브랜딩.** 설정에서 'Fangeul Color'보다 '최애색'이 한국어 유저에겐 훨씬 직관적이에요. 근데 영어권은? 'My Color', 'Bias Color'... 'Bias Color'가 K-pop 맥락에서 정확하긴 한데 일반인은 모르고... **'My Color'**가 가장 안전하지 않을까요?

3. **설정 UI 흐름.** '밝기(Dark/Light/System)' 섹션과 '최애색' 섹션을 명확히 분리해야 해요. 지금 'Theme Color'는 밝기와 같은 카테고리에 들어가 있어서 관계가 모호해요."

---

**박수익 (PM):**

"수치로 보면, 이 리디자인의 핵심 목적은 **커스텀 테마 IAP 전환율 향상**이에요.

현재 문제: fromSeed()가 유저 선택을 필터링 -> '돈 내고 커스텀했는데 별 차이 안 나네' -> IAP 가치 체감 하락. 이건 수익에 직결돼요.

제 관점에서 구조를 정리하면:

**무료 티어:**
- 기본 팔레트 3~4개 (Purple Dream, Ocean Blue, Rose Gold, Forest Green 같은)
- Auto contrast 기본 활성

**프리미엄 티어 (IAP):**
- 추가 팔레트팩 (콘서트 앙코르, 골든 아워 등 감성 팩) -- 팩당 990~1,900원
- **Pick Your Own 커스텀 피커** -- HSL 풀 제어 + 글자색 오버라이드
- 커스텀 피커가 IAP의 킬러 피처가 되려면, **진짜 '내가 원하는 대로'** 되어야 해요

수익 모델 관점에서 가장 중요한 건:
1. 무료 팔레트도 충분히 예쁘되, '딱 내 색은 아니다'는 갈증 유발
2. 커스텀 피커에서 '와 이건 내 앱이다' 체감 -> 전환 트리거
3. fromSeed() 우회로 **선택 = 결과** 보장 -> IAP 가치 신뢰"

---

**김팬심:** "한유진 님, 영어 l10n 키 -- 'My Color'도 좋은데, K-pop 앱이라는 정체성을 살리려면 **'Bias Color'**를 쓰고 처음 진입 시 '최애의 색으로 앱을 물들여보세요' 같은 온보딩 한 줄 넣는 건 어때요? 팬이면 'bias'가 뭔지 다 알아요."

**한유진:** "'Bias Color' -- K-pop 팬 타겟이 명확하니까 괜찮을 수 있어요. 근데 동남아 비영어권 유저 중 'bias'를 모르는 경우도 있을 수 있으니... l10n별로 다르게 가면 어떨까요? `ko`: 최애색, `en`: My Color, `ja`: 推し色. 각 문화권에서 자연스러운 단어로."

**김팬심:** "아 그거 좋다! 추시이로(推し色)! 일본 팬 사이에서 이미 쓰는 단어예요!"

**박수익:** "김팬심 님의 팔레트 네이밍 제안 좋아요. 'K-pop 경험 기반 네이밍'은 감성 구매 트리거로 작용합니다."

**김팬심:** "근데 무료를 구리게 만들면 1-star 리뷰 폭탄 맞아요... 무료도 예쁘되, **프리미엄이 '나만의 색' 느낌**이 확실하면 충분해요. 커스텀 피커가 그 역할이고요."

**박수익:** "맞아요, '구리게'가 아니라 '범용적'이라고 했어요. 무료 4개가 blue/purple/pink/neutral이면 대부분 커버되지만, '정확히 내 최애 그룹 컬러'는 안 되니까. 그 갈증이 커스텀 피커 IAP로 연결."

---

### 기술 아키텍처 심화 토론

**이구현:**

"구현 난이도를 정리해보면:

**1. 팔레트팩 수동 ColorScheme -- 난이도: 중**
- `PalettePack` 클래스에 `lightScheme` + `darkScheme` 직접 정의
- fromSeed() 미사용, 디자이너가 Figma에서 검증한 값 하드코딩
- 장점: 결과 보장, 디자이너 의도 100% 반영
- 단점: 팔레트 추가할 때마다 30+ 색상값 수동 입력

**2. 커스텀 피커 fromSeed() 우회 -- 난이도: 중상**
- HSL 기반으로 seed hue를 surface 전체에 전파
- **Auto contrast는 `computeLuminance()` > 0.179 기준으로 흑/백 자동 선택**
- 채도 비율(15~30%)은 튜닝 필요 -- 실기기 테스트 필수

**3. brightness 레이어와 최애색 레이어 합성 -- 난이도: 하**
- 최애색은 brightness 위에 colorScheme을 **완전 교체(override)**
- 덧대기(merge)가 아니라 교체. 최애색 레이어가 colorScheme 전체를 공급"

---

**최미학:** "팔레트팩 -- 초기 세트 제안:

**무료 (4개):**

| ID | 이름(ko) | 이름(en) | 컨셉 | Primary(dark) | Surface 톤 |
|---|---|---|---|---|---|
| `purple_dream` | 보라빛 꿈 | Purple Dream | 콘서트 보라 바다 | #BB86FC | 보라 틴트 |
| `ocean_blue` | 깊은 바다 | Ocean Blue | 시원한 블루 | #4FC3F7 | 청색 틴트 |
| `rose_gold` | 로즈 골드 | Rose Gold | 따뜻한 핑크 | #F48FB1 | 핑크 틴트 |
| `midnight` | 미드나이트 | Midnight | 기본 차분 | #90CAF9 | 최소 틴트 |

**프리미엄 (IAP, 예시):**

| ID | 이름(ko) | 이름(en) | 컨셉 |
|---|---|---|---|
| `concert_encore` | 콘서트 앙코르 | Concert Encore | 무대 조명 골드+레드 |
| `golden_hour` | 골든 아워 | Golden Hour | 석양 오렌지+앰버 |
| `cherry_blossom` | 벚꽃 엔딩 | Cherry Blossom | 봄 핑크 파스텔 |
| `neon_night` | 네온 나이트 | Neon Night | 사이버펑크 네온 그린+퍼플 |
| `mint_breeze` | 민트 브리즈 | Mint Breeze | 청량 민트+화이트 |
| `sunset_cafe` | 생카 노을 | Sunset Cafe | 생일 카페 따뜻한 톤 |

각 팩마다 light/dark ColorScheme 풀셋을 수동 제작. Figma에서 WCAG AA 검증, 실기기에서 OLED 번인 고려한 dark 밝기 상한(lightness <= 0.22) 적용."

---

**한유진:** "설정 UI 구조 제안:

```
설정 (Settings)
+-- 최애색 (My Color)              <-- 별도 섹션, 최상단 배치
|   +-- [현재 색 미리보기 카드]
|   +-- [변경하기]                  <-- 테마 피커 시트 열기
+-- 화면 밝기 (Appearance)
|   +-- 다크 / 라이트 / 시스템
+-- 언어 (Language)
|   +-- ...
```

'최애색'을 '화면 밝기'보다 **위에** 배치하는 게 핵심. 팬에게 가장 중요한 설정이니까. 현재 색 미리보기 카드를 설정 목록에 인라인으로 보여주면 '아 내 앱 색이 이거구나' 즉시 인지 가능."

---

### 투표 결과

**1. 팔레트팩 fromSeed() 대신 수동 ColorScheme?**

| | 유진 | 수익 | 팬심 | 구현 | 미학 | 합계 |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| 수동 풀셋 | **O** | **O** | **O** | **O** | **O** | **5/5** |
| fromSeed 유지 | - | - | - | - | - | 0 |

**만장일치: 팔레트팩은 수동 ColorScheme**

---

**2. 커스텀 피커 색상 강도?**

| | 유진 | 수익 | 팬심 | 구현 | 미학 | 합계 |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| HSL 기반 surface까지 seed hue 전파 (채도 15~30%) | **O** | **O** | **O** | **O** | **O** | **5/5** |
| fromSeed 유지 + alphaBlend 보정 | - | - | - | - | - | 0 |

**만장일치: fromSeed() 우회, HSL 기반 직접 생성**

---

**3. brightness x 최애색 합성 방식?**

| | 유진 | 수익 | 팬심 | 구현 | 미학 | 합계 |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| 최애색이 colorScheme 완전 교체 (override) | **O** | **O** | **O** | **O** | **O** | **5/5** |
| 기존 base theme에 덧대기 (merge) | - | - | - | - | - | 0 |

**만장일치: 완전 교체**

---

**4. l10n 키 네이밍?**

| | 유진 | 수익 | 팬심 | 구현 | 미학 |
|---|:---:|:---:|:---:|:---:|:---:|
| ko: 최애색 | O | O | O | O | O |
| en: My Color | O | O | - | O | O |
| en: Bias Color | - | - | O | - | - |
| ja: 推し色 | O | O | O | O | O |

**합의: ko=최애색, en=My Color (범용성), ja=推し色, 코드 내부 변수명은 `choeaeColor`**

김팬심: "en은 My Color로 양보할게요. 대신 피커 시트 상단 서브타이틀에 'Color your app with your bias' 같은 한 줄 넣어주세요."

---

### 합의 구현 방안 (코드 레벨)

#### 전체 아키텍처

```
lib/
+-- core/
|   +-- (변경 없음)
+-- data/
|   +-- theme/
|       +-- palette_pack.dart          # PalettePack 데이터 클래스
|       +-- palette_registry.dart      # 전체 팔레트 정의 (수동 ColorScheme)
+-- presentation/
    +-- theme/
        +-- choeae_color_config.dart   # freezed sealed class
        +-- choeae_color_notifier.dart  # Riverpod provider
        +-- custom_scheme_builder.dart  # fromSeed() 우회 빌더
        +-- fangeul_theme.dart         # 리팩토링: build(brightness, choeaeColor)
        +-- widgets/
            +-- theme_picker_sheet.dart # 리디자인된 피커 UI
```

#### 1. PalettePack 정의

```dart
/// lib/data/theme/palette_pack.dart

/// 미리 디자인된 팔레트팩.
/// fromSeed() 미사용 -- 모든 색상 수동 지정.
class PalettePack {
  const PalettePack({
    required this.id,
    required this.nameKey,
    required this.lightScheme,
    required this.darkScheme,
    required this.isPremium,
    required this.previewColor,
  });

  /// 고유 식별자 (e.g., 'purple_dream')
  final String id;

  /// l10n 키 (e.g., 'palettePurpleDream')
  final String nameKey;

  /// 디자이너 수동 튜닝 ColorScheme
  final ColorScheme lightScheme;
  final ColorScheme darkScheme;

  /// 프리미엄 여부 (IAP 필요)
  final bool isPremium;

  /// 그리드 미리보기용 대표 색상
  final Color previewColor;

  /// brightness에 따라 적절한 scheme 반환
  ColorScheme schemeFor(Brightness brightness) =>
      brightness == Brightness.dark ? darkScheme : lightScheme;
}
```

#### 2. ChoeaeColorConfig sealed class

```dart
/// lib/presentation/theme/choeae_color_config.dart
@freezed
sealed class ChoeaeColorConfig with _$ChoeaeColorConfig {
  /// 미리 정의된 팔레트팩
  const factory ChoeaeColorConfig.palette(String packId) = _Palette;

  /// 유저 커스텀 (IAP)
  const factory ChoeaeColorConfig.custom({
    required Color seedColor,
    Color? textColorOverride,  // null이면 auto contrast
  }) = _Custom;

  const ChoeaeColorConfig._();

  /// brightness에 따라 최종 ColorScheme 생성
  ColorScheme buildColorScheme(Brightness brightness) {
    return switch (this) {
      _Palette(:final packId) =>
        PaletteRegistry.get(packId).schemeFor(brightness),
      _Custom(:final seedColor, :final textColorOverride) =>
        CustomSchemeBuilder.build(
          seedColor: seedColor,
          brightness: brightness,
          textColorOverride: textColorOverride,
        ),
    };
  }
}
```

#### 3. CustomSchemeBuilder (fromSeed 우회)

```dart
/// lib/presentation/theme/custom_scheme_builder.dart

/// 유저 선택 seed color에서 ColorScheme을 직접 생성한다.
/// Material 3 fromSeed()의 HCT 채도 저감을 우회하여
/// seed hue가 surface 전체에 강하게 반영된다.
class CustomSchemeBuilder {
  const CustomSchemeBuilder._();

  /// seed color + brightness -> 풀 ColorScheme.
  /// [textColorOverride]가 null이면 auto contrast 적용.
  static ColorScheme build({
    required Color seedColor,
    required Brightness brightness,
    Color? textColorOverride,
  }) {
    final hsl = HSLColor.fromColor(seedColor);
    return brightness == Brightness.dark
        ? _buildDark(hsl, textColorOverride)
        : _buildLight(hsl, textColorOverride);
  }

  static ColorScheme _buildDark(HSLColor hsl, Color? textOverride) {
    final primary = hsl.withLightness(
      hsl.lightness.clamp(0.55, 0.70),
    ).toColor();
    final onPrimary = textOverride ?? _autoContrast(primary);
    final surface = hsl.withLightness(0.10).withSaturation(
      (hsl.saturation * 0.25).clamp(0.0, 1.0),
    ).toColor();

    return ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: hsl.withLightness(0.25).withSaturation(
        (hsl.saturation * 0.70).clamp(0.0, 1.0),
      ).toColor(),
      onPrimaryContainer: textOverride ?? Colors.white,
      secondary: hsl.withHue((hsl.hue + 30) % 360).withLightness(0.60)
          .withSaturation((hsl.saturation * 0.60).clamp(0.0, 1.0)).toColor(),
      onSecondary: textOverride ?? Colors.white,
      secondaryContainer: hsl.withHue((hsl.hue + 30) % 360)
          .withLightness(0.20).withSaturation(
        (hsl.saturation * 0.50).clamp(0.0, 1.0),
      ).toColor(),
      onSecondaryContainer: textOverride ?? Colors.white,
      error: const Color(0xFFCF6679),
      onError: Colors.black,
      surface: surface,
      onSurface: textOverride ?? Colors.white,
      onSurfaceVariant: textOverride?.withAlpha(200) ??
          Colors.white.withAlpha(200),
      surfaceContainerLowest: hsl.withLightness(0.06).withSaturation(
        (hsl.saturation * 0.15).clamp(0.0, 1.0),
      ).toColor(),
      surfaceContainerLow: hsl.withLightness(0.12).withSaturation(
        (hsl.saturation * 0.20).clamp(0.0, 1.0),
      ).toColor(),
      surfaceContainer: hsl.withLightness(0.15).withSaturation(
        (hsl.saturation * 0.22).clamp(0.0, 1.0),
      ).toColor(),
      surfaceContainerHigh: hsl.withLightness(0.18).withSaturation(
        (hsl.saturation * 0.25).clamp(0.0, 1.0),
      ).toColor(),
      surfaceContainerHighest: hsl.withLightness(0.22).withSaturation(
        (hsl.saturation * 0.28).clamp(0.0, 1.0),
      ).toColor(),
      outline: hsl.withLightness(0.40).withSaturation(
        (hsl.saturation * 0.30).clamp(0.0, 1.0),
      ).toColor(),
      outlineVariant: hsl.withLightness(0.25).withSaturation(
        (hsl.saturation * 0.20).clamp(0.0, 1.0),
      ).toColor(),
    );
  }

  static ColorScheme _buildLight(HSLColor hsl, Color? textOverride) {
    final primary = hsl.withLightness(
      hsl.lightness.clamp(0.30, 0.45),
    ).toColor();
    final surface = hsl.withLightness(0.96).withSaturation(
      (hsl.saturation * 0.12).clamp(0.0, 1.0),
    ).toColor();

    return ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: textOverride ?? Colors.white,
      primaryContainer: hsl.withLightness(0.85).withSaturation(
        (hsl.saturation * 0.50).clamp(0.0, 1.0),
      ).toColor(),
      onPrimaryContainer: textOverride ?? hsl.withLightness(0.15).toColor(),
      secondary: hsl.withHue((hsl.hue + 30) % 360).withLightness(0.40)
          .withSaturation((hsl.saturation * 0.50).clamp(0.0, 1.0)).toColor(),
      onSecondary: textOverride ?? Colors.white,
      secondaryContainer: hsl.withHue((hsl.hue + 30) % 360)
          .withLightness(0.90).withSaturation(
        (hsl.saturation * 0.40).clamp(0.0, 1.0),
      ).toColor(),
      onSecondaryContainer: textOverride ?? hsl.withLightness(0.15).toColor(),
      error: const Color(0xFFB00020),
      onError: Colors.white,
      surface: surface,
      onSurface: textOverride ?? Colors.black87,
      onSurfaceVariant: textOverride?.withAlpha(200) ??
          const Color(0xFF424242),
      surfaceContainerLowest: hsl.withLightness(0.99).withSaturation(
        (hsl.saturation * 0.05).clamp(0.0, 1.0),
      ).toColor(),
      surfaceContainerLow: hsl.withLightness(0.95).withSaturation(
        (hsl.saturation * 0.10).clamp(0.0, 1.0),
      ).toColor(),
      surfaceContainer: hsl.withLightness(0.93).withSaturation(
        (hsl.saturation * 0.12).clamp(0.0, 1.0),
      ).toColor(),
      surfaceContainerHigh: hsl.withLightness(0.90).withSaturation(
        (hsl.saturation * 0.15).clamp(0.0, 1.0),
      ).toColor(),
      surfaceContainerHighest: hsl.withLightness(0.87).withSaturation(
        (hsl.saturation * 0.18).clamp(0.0, 1.0),
      ).toColor(),
      outline: hsl.withLightness(0.50).withSaturation(
        (hsl.saturation * 0.25).clamp(0.0, 1.0),
      ).toColor(),
      outlineVariant: hsl.withLightness(0.80).withSaturation(
        (hsl.saturation * 0.15).clamp(0.0, 1.0),
      ).toColor(),
    );
  }

  /// 배경색 luminance 기반 흑/백 자동 선택
  static Color _autoContrast(Color background) {
    return background.computeLuminance() > 0.179
        ? Colors.black87
        : Colors.white;
  }
}
```

#### 4. FangeulTheme 리팩토링

```dart
/// lib/presentation/theme/fangeul_theme.dart (리팩토링)
class FangeulTheme {
  const FangeulTheme._();

  /// 앱 전체 ThemeData 생성.
  /// [brightness] = Dark/Light/System에서 결정된 값.
  /// [choeaeColor] = 최애색 설정 (팔레트팩 or 커스텀).
  static ThemeData build({
    required Brightness brightness,
    required ChoeaeColorConfig choeaeColor,
  }) {
    // 최애색 레이어가 colorScheme 전체를 공급 (덧대기 아님)
    final colorScheme = choeaeColor.buildColorScheme(brightness);

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: 'NotoSansKR',
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.primaryContainer,
      ),
    );
  }
}
```

#### 5. ChoeaeColorNotifier

```dart
/// lib/presentation/theme/choeae_color_notifier.dart
@riverpod
class ChoeaeColorNotifier extends _$ChoeaeColorNotifier {
  @override
  ChoeaeColorConfig build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final type = prefs.getString('choeae_type') ?? 'palette';
    final value = prefs.getString('choeae_value') ?? 'purple_dream';

    return switch (type) {
      'custom' => ChoeaeColorConfig.custom(
          seedColor: Color(int.parse(value, radix: 16)),
          textColorOverride: _loadTextOverride(prefs),
        ),
      _ => ChoeaeColorConfig.palette(value),
    };
  }

  Future<void> selectPalette(String packId) async {
    state = ChoeaeColorConfig.palette(packId);
    await _save('palette', packId);
  }

  Future<void> setCustomColor(Color seed, {Color? textColor}) async {
    state = ChoeaeColorConfig.custom(
      seedColor: seed,
      textColorOverride: textColor,
    );
    await _save(
      'custom',
      seed.toARGB32().toRadixString(16).padLeft(8, '0'),
    );
    if (textColor != null) {
      await _saveTextOverride(textColor);
    }
  }

  Future<void> _save(String type, String value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('choeae_type', type);
    await prefs.setString('choeae_value', value);
  }

  Color? _loadTextOverride(SharedPreferences prefs) {
    final hex = prefs.getString('choeae_text_override');
    if (hex == null) return null;
    return Color(int.parse(hex, radix: 16));
  }

  Future<void> _saveTextOverride(Color color) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(
      'choeae_text_override',
      color.toARGB32().toRadixString(16).padLeft(8, '0'),
    );
  }
}
```

#### 6. 설정 UI 최애색 섹션

```dart
/// settings_screen.dart 내 최애색 섹션
ListTile(
  leading: Container(
    width: 24,
    height: 24,
    decoration: BoxDecoration(
      color: currentChoeaePreviewColor,
      shape: BoxShape.circle,
      border: Border.all(
        color: colorScheme.outline,
        width: 1.5,
      ),
    ),
  ),
  title: Text(context.l10n.choeaeColor),  // "최애색" / "My Color" / "推し色"
  subtitle: Text(currentPaletteName),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => _openThemePickerSheet(context),
),
```

---

### 마이그레이션 영향 범위 요약

기존 `ThemeColorNotifier`를 참조하는 모든 파일이 `ChoeaeColorNotifier`로 전환 필요:
- `lib/presentation/theme/` -- notifier, theme builder
- `lib/presentation/screens/settings/` -- 설정 UI
- `lib/presentation/widgets/theme_picker_sheet.dart` -- 피커 UI
- `lib/app.dart` -- MaterialApp themeData 빌드
- 버블 엔진 동기화 로직

`FangeulTheme.dark()` / `FangeulTheme.light()` -> `FangeulTheme.build(brightness, choeaeColor)` 단일 진입점으로 통합.

`ColorScheme.fromSeed()` 호출 -> 팔레트팩은 수동 ColorScheme, 커스텀은 `CustomSchemeBuilder.build()`로 전량 교체.

---

### 액션 아이템

| # | 작업 | 담당 | 우선순위 | 비고 |
|---|------|------|---------|------|
| B-1 | `ChoeaeColorConfig` freezed sealed class 생성 | 구현 | P0 | 기존 ThemeColorNotifier의 state 교체 |
| B-2 | `CustomSchemeBuilder` 구현 (fromSeed 우회) | 구현 | P0 | HSL 기반, auto contrast 포함 |
| B-3 | `PalettePack` + `PaletteRegistry` 구현 | 구현+미학 | P0 | 무료 4개 + 프리미엄 6개 수동 ColorScheme |
| B-4 | `FangeulTheme` 리팩토링 -- `build(brightness, choeaeColor)` | 구현 | P0 | 기존 `dark()`/`light()` 제거 |
| B-5 | `ChoeaeColorNotifier` 구현 (SharedPreferences 연동) | 구현 | P0 | 기존 ThemeColorNotifier 대체 |
| B-6 | 설정 UI: "Theme Color" -> "최애색" 섹션 분리 + 미리보기 | 유진+구현 | P1 | 밝기 섹션 위에 배치 |
| B-7 | 테마 피커 시트 리디자인 -- 팔레트 그리드 + 잠금 아이콘 | 미학+구현 | P1 | 프리미엄 시각적 차별화 |
| B-8 | l10n 키 추가: `choeaeColor`, `myColor`, 팔레트 이름들 | 구현 | P1 | ko/en/ja/id/th/vi/pt/es |
| B-9 | Figma에서 무료 4팩 + 프리미엄 6팩 색상값 확정 | 미학 | P0 | WCAG AA 검증 + OLED 번인 고려 |
| B-10 | 실기기 테스트 -- 커스텀 피커 채도 비율 튜닝 | 유진+구현 | P1 | 극채도/저채도 seed color 엣지 케이스 |
| B-11 | 기존 코드 마이그레이션: `themeColorNotifier` -> `choeaeColorNotifier` 참조 전체 교체 | 구현 | P0 | 버블 엔진 포함 |
| B-12 | 버블 엔진 `_syncFromMainEngine()` 에서 최애색 동기화 | 구현 | P1 | `prefs.reload()` + invalidate |
| B-13 | 피커 시트 서브타이틀: "Color your app with your bias" / "최애의 색으로 앱을 물들여보세요" | 팬심+구현 | P2 | 감성 카피 |
