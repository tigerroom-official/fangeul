# UX 디테일 3가지 전문가 패널 토론

**날짜:** 2026-03-05
**참석자:** UX 디자이너(유진), 제품 전략가(민수), Flutter 개발자(세영), K-pop 팬 대리인(하늘)

## 논제
1. 설정에 앱 내 언어 변경 기능 추가
2. 팝업 ··· 메뉴에 리뷰/문의 추가 여부
3. 버블 버튼 디자인 변경 ('한' → 심볼)

---

## Topic 1: 앱 내 언어 변경 설정

### 합의 (찬성 2, 중립 2)
- **추가 결정** — 공수 30분 수준, QA 가치 높음
- `localeNotifierProvider` + `SharedPreferences` 저장 + SegmentedButton/Dropdown
- 우선순위 **P1** — 출시 전 또는 직후
- 기존 `themeModeNotifierProvider` 패턴 복제

---

## Topic 2: 리뷰/문의 메뉴

### 합의 (4:0 만장일치)
- **미니 컨버터 ··· 메뉴에는 넣지 않음** — 유틸리티 도구의 간결함 유지 (현재 2개 항목)
- **메인앱 설정에 추가**:
  - "리뷰하기" → `in_app_review` API
  - "문의하기" → `mailto:` 인텐트 (url_launcher)
- `in_app_review` **자동 트리거**: Day 14+ & 복사 10회+ 등 조건 기반
- Google 쿼터 제한: 30일 내 같은 유저 1회만

---

## Topic 3: 버블 버튼 디자인

### 합의 (4:0 만장일치)
- **"한" 텍스트 제거** — 타겟(10~20대 여성)에 맞지 않음, 비한국어 사용자에게 의미 없음
- **MVP**: Kotlin `TextView` → `ImageView` + 벡터 드로어블(VectorDrawable)
  - 해상도 대응 자동 (1개 XML)
  - 디자인 후보: 말풍선+하트, 앱 아이콘 축소, 'F'+하트 등
  - 틸 그라데이션 배경 유지
- **Post-launch**: 마스코트/캐릭터 (디자이너 필요)

### 기술 참고
- 현재 구현: `FloatingBubbleService.kt` line 147~177
- `GradientDrawable`(틸 원) + `TextView("한")` → `ImageView` + `R.drawable.ic_bubble` 교체
- 벡터 드로어블이면 mdpi~xxxhdpi 별도 에셋 불필요

---

## Topic 3 심층: 버블 아이콘 모티프 & 스타일 결정

### 모티프 선정 (4:0 만장일치)

**채택: 말풍선(Speech Bubble) + 'ㅎ' 자음**
- 말풍선 = 소통/대화 → 한국어 도구의 본질
- 'ㅎ' = 한국어 대표 자음 + 'ㅎㅎ' 웃음 연상 → 친근함
- 56dp에서도 가독성 확보 (단순 형태)

**제외된 후보:**
| 모티프 | 제외 사유 |
|--------|----------|
| 음표 | 음악 앱으로 오인 |
| 마이크 | 노래방 앱으로 오인 |
| 포토카드 | 56dp에서 디테일 손실 |
| 별/하트 단독 | 범용적, 앱 정체성 부족 |

### 스타일 결정 (4:0 만장일치)

- **형태**: 둥근 말풍선 실루엣 (선택적 하트 꼬리)
- **내부**: 'ㅎ' 자음 (흰색, 라운드체)
- **배경**: 틸→퍼플 대각선 그라데이션 (#4ECDC4 → #9B59B6)
- **효과**: 좌상단 미세 세미글로시 하이라이트
- **포맷**: VectorDrawable XML (1개 파일, 해상도 무관)

### AI 도구 추천

| 도구 | 적합성 | 비고 |
|------|--------|------|
| **Recraft** | **최적** | SVG 네이티브 출력, 아이콘 특화 |
| IconifyAI | 차선 | 앱 아이콘 특화, PNG 출력 |
| ComfyUI | 비추천 | 래스터 기반, 벡터 변환 필요 |
| Google Nano | 비추천 | 텍스트/코드 특화, 이미지 미지원 |

### Recraft 프롬프트

```
Round chat bubble icon, Korean consonant 'ㅎ' inside,
teal to purple diagonal gradient (#4ECDC4 to #9B59B6),
white letter, subtle glossy highlight top-left,
flat design with minimal depth, clean vector style,
56x56dp, SVG format, dark background
```

---

## Topic 3 후보 평가: star1.svg vs heart1.svg

### 후보 파일
- `docs/assets/bubble-icon-candidates/star1.svg` — 말풍선+반짝이별(✦), 틸(#7BD0D9)+퍼플(#9F5ACA) 그라데이션, path 15개
- `docs/assets/bubble-icon-candidates/heart1.svg` — 말풍선+하트+소용돌이, 틸(#18EEB9)→퍼플(#BA4DD4) 그라데이션, path 5개
- (기각) star2.svg, heart2.svg — 56dp에서 디테일 과다로 부적합

### 56dp 가독성 평가
- star1: 회색조 3레이어(FEFEFE/8F95A3/3F4151)가 56dp에서 흰색 얼룩으로 뭉침 → **단순화 필수**
- heart1: path 5개로 56dp 선명. 소용돌이는 축소 시 자연 소멸되어 하트 강조 효과
- **공통**: 검정 배경 rect 제거 필요, 그라데이션 방향 조정 필요 (꼬리와 일치)

### K-pop 팬 감성 & 차별화 (3:1 star1 우위)
- 별(✦): 콘서트 응원봉, 팬 계정 닉네임 — 팬 고유 기호. Weverse/Bubble/인스타와 **차별화**
- 하트(♥): 유니버설하지만 **과포화** — "또 하나의 하트 앱" 리스크
- 감성 컬러 팩 SKU 확장 시 별 모티프가 다양화 용이 (골드별, 실버별 등)

### 기술 구현
- 양쪽 모두 VectorDrawable 변환 가능 (linearGradient → `<gradient>`, API 24+, minSdk 26)
- star1: path 최적화 필요하나 `<group>` 구조화 → AnimatedVectorDrawable 확장 용이
- heart1: 즉시 변환 가능, MVP 타이밍에 유리

### 결정: **보류 — 추가 후보 생성 후 재논의**
- star1 단순화(3:1 다수 지지) 방향이나, Recraft에서 추가 후보 생성 후 최종 결정
- 대안: heart1 MVP 출시 → star1-v2 포스트런치도 합리적 옵션

---

## Action Items

| # | 태스크 | 우선순위 |
|---|--------|----------|
| 1 | 메인앱 설정에 "리뷰하기" 추가 (in_app_review) | **P0** |
| 2 | 메인앱 설정에 "문의하기" 추가 (mailto:) | **P0** |
| 3 | in_app_review 자동 트리거 조건 구현 | **P1** |
| 4 | 설정에 언어 변경 기능 추가 | **P1** |
| 5 | 버블 "한" → 벡터 드로어블 심볼 교체 | **P1** |
| 6 | 앱 아이콘 + 버블 통일 디자인 (마스코트) | **P2** |
