# Fangeul — Korean for K-pop Fans

> **한국어를 배우지 않고도, 한국어로 팬 활동하는 도구**
>
> 최종 업데이트: 2026-02-27

---

## 1. 프로젝트 개요

### 1.1 한 줄 요약

글로벌 K-pop 팬(225M+)이 아이돌과 한국어로 소통할 수 있게 해주는 Android 유틸리티 앱. 한글 키패드, 텍스트 변환기, 팬 문구 라이브러리를 플로팅 버블 인터페이스로 제공한다.

### 1.2 핵심 컨셉

기존 영타로(영타 → 한글 변환 앱, 한국인 대상)의 기술을 **글로벌 K-pop 팬 시장**으로 확장한다. "학습"이 아닌 "행동"에 초점을 맞춘 유틸리티로, 팬이 Weverse/Twitter/YouTube에서 **지금 당장** 한국어로 댓글을 달 수 있게 한다.

### 1.3 타겟 플랫폼

Android Only (MVP). iOS는 시장 반응 확인 후 별도 결정.

**이유:**

- K-pop 팬 최대 시장(동남아, 라틴아메리카, 인도, 중동)의 Android 점유율 85~95%
- 플로팅 버블(오버레이) 기능이 Android에서만 가능
- iOS 키보드 확장은 Swift 네이티브 작업 필요 → 개발 기간 2배 이상 증가
- Android 단일 타겟 집중 시 퀄리티 확보가 쉬움

### 1.4 개발 스택

- **Framework:** Flutter (Dart)
- **타겟:** Android API 26+ (Android 8.0 Oreo 이상)
- **백엔드:** 불필요 (전부 온디바이스 처리)
- **광고:** Google AdMob (배너 + 보상형 동영상)
- **결제:** Google Play Billing Library
- **플로팅 버블:** 네이티브 Android 코드 (Kotlin) + Flutter Platform Channel

---

## 2. 시장 분석

### 2.1 시장 규모

- **글로벌 K-pop 팬:** 225M+ (119개국, 2024 기준)
- **한국어 학습 소프트웨어 시장:** 2025년 $150M → 2033년 CAGR 15% 성장 전망
- **K-pop 팬 앱 시장 선례:** Weverse 1.5억+ 다운로드, CHOEAEDOL 수백만 유저
- **핵심 수요 증거:**
  - Koreaboo "아이돌에게 보낼 한국어 문구" 기사 바이럴 (2018, 여전히 상위 검색)
  - Weverse 유저 리뷰 최대 불만: 번역 품질, 자막 유료화
  - TikTok에서 "how to translate weverse live" 대량 검색
  - Fantranslator 등 개인 개발자의 자생적 번역 도구 등장

### 2.2 타겟 유저 페르소나

**Primary:** 동남아/라틴아메리카 K-pop 팬 (16~30세, Android, 영어 기반)

- Weverse, Twitter, YouTube에서 매일 팬 활동
- 아이돌 포스트에 한국어로 댓글 달고 싶지만 방법을 모름
- 정규 한국어 학습은 너무 무거움 → 즉시 쓸 수 있는 도구 원함
- 구독보다 보상형 광고에 친숙

**Secondary:** 영미권/유럽 K-pop 팬 (구매력 높음, Pro 구독 전환 가능성)

### 2.3 경쟁자 분석

#### 직접 경쟁자: **없음**

"한글 키패드 + 키보드 위치 변환 + 로마자 발음 변환 + K-pop 문구 + 플로팅 버블"을 조합한 앱은 현재 존재하지 않는다.

#### 인접 경쟁자

| 앱 | 카테고리 | 강점 | 약점 (우리와의 차이) |
|---|---|---|---|
| **Korean Keyboard 류** (Neno Soft 등) | 키보드 | BTS 테마 등 K-pop 어필 시도 | 저품질, 광고 도배, 변환 기능 없음, 파키스탄/인도 개발사 |
| **Kpop Pro** (STRA Co.) | K-pop 학습 | KMCA 라이선스, 가사+로마자+번역, 5000+ 곡 | "학습/노래방" 방향, 유틸리티 아님, KMCA 비용 부담 |
| **BB: KPOP Korean Learning** (H2k) | K-pop 학습 | K-pop 가사 퀴즈 | 초기 단계, 리뷰 거의 없음 |
| **Bubble Screen Translate** 등 | 범용 번역 | 플로팅 번역 오버레이 | K-pop 특화 없음, 한글 입력/변환 없음 |
| **Google Translate** (Tap to Translate) | 범용 번역 | 기본 탑재, 플로팅 | 한글↔영타 변환 불가, 팬 문구 없음 |
| **KONOGRAM** | K-pop 한국어 콘텐츠 | 팬 문구/팬덤 용어 교육 | 웹사이트/블로그, 앱 아님 |
| **Teuida** | 한국어 학습 | K-pop 팬 타겟, 회화 학습 | 정규 학습 앱, 유틸리티 아님 |

#### 빠른 카피 위협도

| 위협 주체 | 위협 수준 | 이유 |
|---|---|---|
| Weverse (HYBE) | **낮음** | 번역 유료화로 수익 중, 무료 입력 도구 제공 인센티브 없음 |
| Google Translate | **매우 낮음** | 범용 제품, K-pop 특화 기능 추가 가능성 없음 |
| Kpop Pro (STRA) | **중간** | K-pop + 한국어 교차점 이해하지만, 학습→유틸리티 피봇에 최소 6개월~1년 |
| 인도/파키스탄 키보드 개발사 | **낮음** | 한글 조합 로직 + K-pop 문맥 이해 부족 |
| 인디 개발자 | **중간** | 단일 기능만 가능, 키보드+변환+문구 통합 역량 부족 |

---

## 3. 엣지 포인트 (경쟁 우위)

### 3.1 기술적 엣지: 영타로 경험

한글 자모 조합 로직과 영↔한 키보드 위치 매핑을 이미 구현한 경험이 있다. 이 로직을 처음부터 구현하려면 한국어 네이티브 수준의 자판 이해가 필요하며, 해외 개발사가 쉽게 따라올 수 없다.

### 3.2 카테고리 창조: "K-pop Fan Korean Toolkit"

현재 키보드, 학습, 번역은 각각 별개 카테고리다. 이 세 가지의 교차점에서 **"한국어를 배우지 않고도 한국어로 팬 활동하는 도구"**라는 새로운 카테고리를 만든다. 학습이 아니라 **행동**에 초점을 맞추는 것이 기존 앱들과의 근본적 차이.

### 3.3 플로팅 버블 + 한글 특화 조합

범용 플로팅 번역 앱은 "한국어로 쓰기"를 지원하지 않고, 한글 키보드 앱은 플로팅 오버레이가 없다. 이 두 가지의 조합은 현재 시장에 존재하지 않는다.

### 3.4 네이티브 한국인의 문화적 정확성

기존 K-pop 팬 문구 리소스(Koreaboo 기사, 블로그 등)의 문제:

- 2018년 기사가 아직 상위 검색 (업데이트 안 됨)
- 높임말/반말 구분 없음
- 최신 팬덤 용어 미반영
- 맥락 없는 문장 나열

한국 네이티브가 직접 큐레이션하는 "살아있는 문구 DB"는 해외 개발사가 따라하기 어렵다.

### 3.5 선점 효과

이 공백을 처음 채우는 앱이 "Korean for K-pop fans" ASO 키워드를 정의하게 된다. 2~3주 안에 MVP를 출시하고 카테고리 1위를 선점하는 것이 최대 방어벽.

---

## 4. 기능 목록

### 4.1 MVP (v1.0) — 목표: 2~3주 개발

#### 핵심 기능 4가지

**① 빌트인 한글 키패드**

- 영타로에서 재사용 가능한 한글 키패드 UI
- OS 키보드 설정 없이 앱 내에서 바로 한글 입력
- 자음 + 모음 조합 → 완성된 한글 실시간 출력
- 입력 결과 원탭 클립보드 복사

**② 키보드 위치 변환 (영타 변환)**

- 영→한: `gksrmf` → `한글` (영어 키보드에서 한글 자판 위치대로 친 것을 한글로)
- 한→영: `한글` → `gksrmf` (반대 방향)
- 양방향 변환 토글
- 기존 영타로 로직 포팅

**③ 로마자 발음 변환**

- 한글 → 로마자 발음: `사랑해요` → `saranghaeyo`
- 국립국어원 로마자 표기법(2000년 고시) 기반
- 발음 변화 규칙 적용 (연음, 비음화, 구개음화, 격음화, 경음화 등)
- 구현 방식: 오픈소스 로직 Dart 포팅 (상세 → 4.3절 참조)

**④ K-pop 팬 문구 라이브러리**

- 기본 문구팩 (무료): 범용 팬 표현 30~50개
- 카테고리별 구성: 일상 인사, 응원, 사랑 표현
- 각 문구: 한글 + 영어 뜻 + 로마자 발음 + 원탭 복사
- 예시:
  - `사랑해요` / I love you / saranghaeyo / [📋복사]
  - `오늘도 화이팅!` / Fighting today too! / oneuldo hwaiting! / [📋복사]
  - `보고 싶어요` / I miss you / bogo sipeoyo / [📋복사]

#### 부가 기능

**⑤ 플로팅 버블 (무료 핵심 기능)**

- Android SYSTEM_ALERT_WINDOW 권한 사용
- 다른 앱(Twitter, Weverse, YouTube) 위에 떠있는 버블
- 탭하면 미니 변환기 팝업: 텍스트 입력 → 한글 변환/발음 변환 → 복사
- 문구 라이브러리 바로가기
- 드래그로 위치 이동 가능

**⑥ 다국어 문구 표시 (My Language)**

- 기기 시스템 언어 자동 감지 → 초기 설정
- 설정에서 "My Language" 수동 변경 가능
- 문구 표시 구조 (4줄):
  ```
  사랑해요
  saranghaeyo
  🇬🇧 I love you
  🇮🇩 Aku cinta kamu    ← My Language (유저 설정)
  ```
- 영어는 항상 표시 (글로벌 공통), 모국어는 옵션
- MVP 지원 언어 (5개):
  - 인도네시아어 (Bahasa Indonesia) — K-pop 팬 최대 시장
  - 태국어 — 동남아 2위
  - 포르투갈어 (브라질) — 라틴 최대 시장
  - 스페인어 — 라틴 + 유럽 커버
  - 베트남어 — 급성장 시장
- 번역 파이프라인:
  1. Claude Opus 4.6으로 초안 번역 (팬 문구 특화 프롬프트)
  2. 동일 모델로 네이티브 관점 검수 (자연스러움, 팬 문맥 적합성)
  3. 각 언어별 크로스체크 프롬프트로 최종 QA
  4. 커뮤니티 피드백 반영 (출시 후)
- 번역 볼륨: 기본 50문구 × 5언어 = 250문장 (Claude로 1~2시간 내 완료 가능)
- 확장: v1.1 이후 커뮤니티 기여로 언어 추가 (일본어, 아랍어, 힌디어 등)

**⑦ 한국어 발음 재생 (TTS)**

- 각 문구 옆 🔊 버튼 탭 → 한국어 네이티브 발음 재생
- **사전 생성 방식:** RTX 5090 TTS 서버에서 배치 생성 → Cloudflare R2 호스팅 → 앱에서 다운로드 후 로컬 캐싱
- Google TTS 대비 장점: 높은 음질, 오프라인 재생 가능, 일관된 음성
- 아키텍처:
  ```
  [RTX 5090 TTS 서버] → 배치 생성 → [MP3 파일]
       ↓ 업로드
  [Cloudflare R2 버킷] (무료 티어: 10GB 스토리지, 이그레스 무료)
       ↓ CDN URL
  [앱 → 다운로드 → 로컬 캐시 → 오프라인 재생]
  ```
- 파일 네이밍: `{pack_id}_{phrase_id}.mp3`, `{pack_id}_{phrase_id}_slow.mp3`
  ```
  audio/
  ├── basic_love_001.mp3          # 사랑해요 (일반 속도)
  ├── basic_love_001_slow.mp3     # 사랑해요 (느린 속도)
  ├── basic_love_002.mp3          # 오늘도 화이팅!
  ├── birthday_001.mp3            # 생일 축하해요!
  └── ...
  ```
- 무료 티어: 기본 문구팩 음성 앱 번들 포함 (일반 속도만, 약 3~5MB)
- Pro 티어: 느린 발음 모드 + 추가 문구팩 음성 다운로드 + 반복 재생(3회/5회) + 어절별 하이라이트 재생 + 플로팅 버블 내 TTS
- 문구팩 추가 시: RTX 5090에서 배치 생성 → R2 업로드 → 앱에서 새 음성 감지 후 다운로드

**⑧ 영어 UI + 다국어 스토어 설명**

- 앱 UI: 영어
- Play Store 설명: 영어, 인도네시아어, 태국어, 포르투갈어(브라질), 스페인어

### 4.2 Post-MVP 로드맵

#### v1.1 (출시 후 2~4주)

- 아이돌 이름 사전: 한글 이름 ↔ 영어 이름 매핑 DB (예: `방탄소년단` = BTS)
- K-pop 용어 사전: `막내` = maknae, `음방` = music show, `컴백` = comeback 등
- 추가 문구팩 (보상형 광고로 해금):
  - 생일 팩: `생일 축하해요 오빠!`, `태어나줘서 고마워요`, `올해도 건강하고 행복하세요`
  - 컴백 팩: `컴백 축하해요!`, `신곡 너무 좋아요`, `음원 1위 하자!`
  - 콘서트/공연 팩: `앵콜!`, `무대 찢었어요`, `한국에서 꼭 보고 싶어요`
  - 위로/응원 팩: `힘내세요 우리가 있잖아요`, `천천히 쉬어요`, `항상 응원해요`
  - 일상 소통 팩: `밥 먹었어요?`, `오늘 뭐 했어요?`, `잘 자요~`
- 홈 화면 위젯: 빠른 변환 + 오늘의 문구

#### v1.2 (출시 후 1~2개월)

- 컬러 테마 스킨 (팬덤 시그니처 컬러 기반, 아이돌 이름/이미지 미사용)
  - "퍼플 드림" (보라 계열), "민트 프레시" (초록), "로제 골드" (핑크골드), "미드나잇 블루" 등
- 커스텀 문구 저장: 유저가 직접 문구 추가/편집/폴더 관리
- 클립보드 감지: 한글 텍스트 복사 시 자동으로 로마자 발음 알림

#### v2.0 (출시 후 3개월+)

- 로마자 → 한글 역변환: `saranghaeyo` 입력 → `사랑해요` 출력
- 문장 빌더: 영어로 의도 입력 → 자연스러운 한국어 팬 표현 추천 (온디바이스 룰 기반 또는 경량 AI)
- 팬덤별 문구 팩: 팬덤 커뮤니티 기여 기반 확장
- 한글 쓰기 연습: 획순 가이드 (간단한 인터랙티브)

### 4.3 로마자 발음 변환 구현 상세

#### 왜 단순하지 않은가

한국어는 글자 그대로 읽지 않는 경우가 많다. 주요 발음 변화 규칙:

| 규칙 | 예시 (표기 → 발음) | 로마자 결과 |
|---|---|---|
| 연음법칙 | 없어요 → [업서요] | eopseoyo |
| 비음화 | 합니다 → [함니다] | hamnida |
| 구개음화 | 같이 → [가치] | gachi |
| 격음화 | 좋다 → [조타] | jota |
| 경음화 | 학교 → [학꾜] | hakkkyo |
| ㄹ의 비음화 | 심리 → [심니] | simni |
| 유음화 | 설날 → [설랄] | seollal |

이 외에도 규칙이 수십 개 있으며, 중첩 적용되는 경우도 존재한다.

#### 구현 전략

**처음부터 만들지 않는다.** 기존 오픈소스 로직을 Dart로 포팅한다.

**참조 가능한 오픈소스:**

- `zaeleus/hangeul` (Rust) — 한국어 로마자 변환, GitHub
  - https://github.com/zaeleus/hangeul
- KOROMAN (부산대) — 국립국어원 표기법 기반 변환 엔진
  - https://roman.cs.pusan.ac.kr/input_eng.aspx
- `KR-Romanizer` 류 JavaScript 구현체들 — 브라우저 기반, 로직 참조 용이
- 국립국어원 로마자 표기법 공식 문서
  - https://www.korean.go.kr/front/page/pageView.do?page_id=P000150

**구현 단계:**

1. 한글 유니코드 → 초성/중성/종성 분해 (UTF-16 연산, 단순)
2. 자모 → 로마자 기본 매핑 테이블 구축
3. 음절 경계 발음 변화 규칙 엔진 (종성 + 다음 초성 조합 분석)
4. 규칙 우선순위 처리 (중첩 규칙 해결)
5. 최종 로마자 문자열 조합

**예상 소요 시간:** 오픈소스 포팅 기준 2~3일. MVP에서는 주요 규칙(연음, 비음화, 격음화, 구개음화, 경음화)만 커버하고, 엣지 케이스는 점진적 개선.

**참고:** K-pop 팬이 자주 접하는 표현은 패턴이 정해져 있어서 (인사, 응원, 감정 표현 등) 완벽한 범용 변환이 아니더라도 실사용에 충분하다.

---

## 5. 수익화 모델

### 5.1 수익 구조 (3 Tier)

#### Free Tier (무료)

- 전체 핵심 기능: 한글 키패드, 키보드 위치 변환, 로마자 발음 변환
- 플로팅 버블 포함 (무료 핵심 기능)
- 기본 문구팩 (30~50개)
- 하단 배너 광고

#### 보상형 광고 해금

- 추가 문구팩 (상황별: 생일, 컴백, 콘서트, 위로, 일상)
- 컬러 테마 스킨
- K-pop 용어 사전 확장

#### Pro 구독

- 월 $0.99 (지역별 현지화 가격)
  - 인도네시아: IDR 15,000 (~$0.95)
  - 필리핀: PHP 49 (~$0.85)
  - 브라질: BRL 5.90 (~$1.10)
  - 영미권: $1.99~2.99
- 포함 기능:
  - 광고 완전 제거
  - 커스텀 문구 무제한 생성/저장/편집
  - 아이돌 이름 사전 전체
  - 홈 화면 위젯
  - 상세 발음 가이드 모드
  - TTS 프리미엄: 느린 발음 모드 + 반복 재생(3회/5회) + 어절별 하이라이트 재생 + 플로팅 버블 내 TTS + 추가 문구팩 음성 다운로드

### 5.2 수익 현실성 참고

- 동남아 배너 eCPM: $0.3~1.0 / 보상형 동영상 eCPM: $2~5
- 이 앱의 강점은 **높은 사용 빈도** — 매일 팬 활동 시마다 사용하므로 세션 수가 높고 광고 노출 횟수도 비례 상승
- Google Play 지역 가격 정책 활용 필수 → 현지 통화 기준 가격 설정

### 5.3 하지 않는 것 (법적 리스크 회피)

| 항목 | 이유 |
|---|---|
| **가사 표시** | KOMCA 저작권 라이선스 필요, 분기별 로열티 정산 의무. Kpop Pro가 실제로 비용 지불 중. 인디 개발자에게 비용/절차 부담이 큼 |
| **아이돌 이름/이미지/로고 직접 사용** | 초상권 + 상표권 이슈. HYBE/SM/JYP 등 소속사의 IP 관리 엄격. DMCA 테이크다운 리스크 |
| **팬덤명 직접 사용** (ARMY, BLINK 등) | 일부 팬덤명은 상표 등록됨. 안전하게 "컬러 테마"로 우회 |

**대안:**

- 가사 대신 → 팬 문구 라이브러리 (저작권 이슈 없음)
- 아이돌 이미지 대신 → 팬덤 시그니처 컬러 테마 (팬들이 알아서 인지)
- 팬덤명 대신 → 컬러명으로 표현 ("퍼플 드림", "민트 프레시" 등)

---

## 6. 기술 구현 목록

### 6.1 Flutter 프로젝트 구조

> **정본은 `CLAUDE.md`의 Clean Architecture 3-Layer 구조.** 아래는 기획 시점의 초안이며,
> 실제 구현은 `CLAUDE.md`의 `core/engines/`, `data/`, `presentation/` 디렉토리 구조를 따른다.
> 상세: `docs/engine-guide.md` 참조.

```
lib/
├── core/engines/            # 한글, 키보드, 로마자 엔진 (순수 Dart)
├── core/entities/           # 도메인 모델 (freezed)
├── core/usecases/           # 비즈니스 유스케이스
├── core/repositories/       # Repository 인터페이스
├── data/                    # Repository 구현체 + 데이터소스
├── presentation/            # screens, widgets, providers, theme
├── services/                # TTS, 클립보드 등
├── platform/                # 네이티브 통신 (Platform Channel)
assets/phrases/              # 문구팩 JSON
assets/audio/                # TTS MP3 번들
android/.../kotlin/          # FloatingBubbleService.kt (네이티브)
test/core/engines/           # 엔진 유닛 테스트
```

### 6.2 핵심 모듈별 구현 사항

#### hangul_engine.dart — 한글 자모 조합/분해

- 유니코드 한글 블록: U+AC00 ~ U+D7A3
- 분해 공식: `((code - 0xAC00) / 28 / 21)` = 초성, `((code - 0xAC00) / 28 % 21)` = 중성, `((code - 0xAC00) % 28)` = 종성
- 조합 공식: `0xAC00 + (초성 * 21 + 중성) * 28 + 종성`
- 겹받침 처리 (ㄳ, ㄵ, ㄶ, ㄺ, ㄻ, ㄼ, ㄽ, ㄾ, ㄿ, ㅀ, ㅄ)
- 실시간 입력 상태 관리: 자음 입력 → 모음 대기 → 조합 → 종성 판단

#### keyboard_converter.dart — 영↔한 키보드 위치 변환

- 영→한 매핑 테이블: `{'a': 'ㅁ', 'b': 'ㅠ', 'c': 'ㅊ', ...}` (두벌식 표준 자판 기준)
- 한→영 매핑 테이블: 역방향
- Shift 상태 처리: `{'A': 'ㅁ', 'E': 'ㄸ', 'Q': 'ㅃ', 'R': 'ㄲ', 'T': 'ㅆ', 'W': 'ㅉ'}`
- 한글 조합 후처리: 개별 자모 → 완성된 한글 음절 조합

#### romanizer.dart — 한글 → 로마자 발음 변환

- 초성 매핑: `{ㄱ: 'g', ㄲ: 'kk', ㄴ: 'n', ㄷ: 'd', ㄸ: 'tt', ...}`
- 중성 매핑: `{ㅏ: 'a', ㅐ: 'ae', ㅑ: 'ya', ㅒ: 'yae', ...}`
- 종성 매핑: `{ㄱ: 'k', ㄴ: 'n', ㄷ: 't', ㄹ: 'l', ...}`
- 음절 경계 발음 변화 규칙 (우선순위 순):
  1. 연음법칙: 종성 + ㅇ초성 → 종성이 다음 음절 초성으로 이동
  2. 비음화: ㄱ/ㄷ/ㅂ + ㄴ/ㅁ → ㅇ/ㄴ/ㅁ
  3. 격음화: ㄱ/ㄷ/ㅂ/ㅈ + ㅎ → ㅋ/ㅌ/ㅍ/ㅊ
  4. 구개음화: ㄷ/ㅌ + ㅣ → ㅈ/ㅊ
  5. 경음화: ㄱ/ㄷ/ㅂ + ㄱ/ㄷ/ㅂ/ㅅ/ㅈ → 뒤 자음 된소리
  6. ㄹ의 비음화/유음화
- **구현 참조:** zaeleus/hangeul (Rust), KOROMAN (부산대)

#### FloatingBubbleService.kt — 플로팅 버블 (네이티브)

- `SYSTEM_ALERT_WINDOW` 권한 요청
- `WindowManager`로 오버레이 뷰 추가
- Foreground Service로 버블 유지
- Flutter Platform Channel로 양방향 통신:
  - Kotlin → Flutter: 버블 탭 이벤트, 클립보드 텍스트 전달
  - Flutter → Kotlin: 변환 결과 전달, 버블 표시/숨김
- **직접 Kotlin으로 구현** (외부 패키지 금지, `.claude/rules/00-project.md` 참조)
- 로직 참조용 오픈소스 (사용하지 않음, 구현 패턴만 참고):
  - `flutter_overlay_window` (pub.dev)
  - `system_alert_window` (pub.dev)

### 6.3 데이터 구조

#### 문구 데이터 (JSON)

```json
{
  "packs": [
    {
      "id": "basic_love",
      "name": "Love & Support",
      "name_ko": "사랑 & 응원",
      "is_free": true,
      "phrases": [
        {
          "ko": "사랑해요",
          "roman": "saranghaeyo",
          "context": "General love expression, polite form",
          "tags": ["love", "daily"],
          "translations": {
            "en": "I love you",
            "id": "Aku cinta kamu",
            "th": "ฉันรักคุณ",
            "pt": "Eu te amo",
            "es": "Te quiero",
            "vi": "Tôi yêu bạn"
          }
        },
        {
          "ko": "오늘도 화이팅!",
          "roman": "oneuldo hwaiting!",
          "context": "Daily encouragement",
          "tags": ["cheer", "daily"],
          "translations": {
            "en": "Fighting today too!",
            "id": "Semangat hari ini juga!",
            "th": "สู้ๆ วันนี้ด้วยนะ!",
            "pt": "Força hoje também!",
            "es": "¡Ánimo hoy también!",
            "vi": "Hôm nay cũng cố lên nhé!"
          }
        }
      ]
    },
    {
      "id": "birthday_pack",
      "name": "Birthday Messages",
      "name_ko": "생일 축하",
      "is_free": false,
      "unlock_type": "rewarded_ad",
      "phrases": [
        {
          "ko": "생일 축하해요!",
          "roman": "saengil chukahaeyo!",
          "context": "Polite birthday greeting",
          "tags": ["birthday"],
          "translations": {
            "en": "Happy birthday!",
            "id": "Selamat ulang tahun!",
            "th": "สุขสันต์วันเกิด!",
            "pt": "Feliz aniversário!",
            "es": "¡Feliz cumpleaños!",
            "vi": "Chúc mừng sinh nhật!"
          }
        },
        {
          "ko": "태어나줘서 고마워요",
          "roman": "taeeona jwoseo gomawoyo",
          "context": "Emotional birthday message, very popular among fans",
          "tags": ["birthday", "emotional"],
          "translations": {
            "en": "Thank you for being born",
            "id": "Terima kasih sudah terlahir",
            "th": "ขอบคุณที่เกิดมานะ",
            "pt": "Obrigado(a) por ter nascido",
            "es": "Gracias por haber nacido",
            "vi": "Cảm ơn vì đã được sinh ra"
          }
        }
      ]
    }
  ]
}
```

#### 아이돌 이름 사전 (v1.1)

```json
{
  "idols": [
    {
      "name_ko": "방탄소년단",
      "name_en": "BTS",
      "roman": "bangtan sonyeondan",
      "members": [
        {"name_ko": "김남준", "name_en": "RM", "roman": "gim namjun"},
        {"name_ko": "김석진", "name_en": "Jin", "roman": "gim seokjin"}
      ]
    }
  ]
}
```

---

## 7. 출시 전략

### 7.1 ASO (App Store Optimization)

**주요 키워드 (경쟁 약한 틈새):**

- `korean keyboard kpop`
- `hangul typing for fans`
- `korean phrases kpop`
- `hangul romanization`
- `type korean for kpop`
- `weverse korean keyboard`
- `korean fan message`

**스토어 설명 현지화:**

- 영어 (기본)
- 인도네시아어 (Bahasa Indonesia)
- 태국어
- 포르투갈어 (브라질)
- 스페인어 (라틴아메리카)

### 7.2 초기 유저 확보 전략

1. **Twitter/X K-pop 팬 커뮤니티:** #KpopFans, #LearnKorean, #WeverseTips 해시태그로 앱 홍보
2. **Reddit:** r/kpop, r/bangtan, r/kpophelp에 앱 소개
3. **TikTok:** "한국어로 아이돌에게 메시지 보내는 법" 짧은 튜토리얼 영상
4. **팬 계정 협업:** K-pop 팬 계정(번역 계정 등)에 앱 리뷰 요청

### 7.3 핵심 성과 지표

| 지표 | 1개월 목표 | 3개월 목표 | 6개월 목표 |
|---|---|---|---|
| 다운로드 | 5,000 | 30,000 | 100,000+ |
| DAU | 500 | 3,000 | 15,000+ |
| Day 7 리텐션 | 25%+ | 30%+ | 35%+ |
| Pro 전환율 | 1% | 2% | 3% |
| 평균 별점 | 4.0+ | 4.3+ | 4.5+ |

---

## 8. 개발 타임라인

> **참고:** 아래 "Timeline Phase"는 일정 기반 구분이며, `CLAUDE.md`의 "구현 Phase 1~7"과는
> 다른 체계다. 개발 순서는 `CLAUDE.md`의 Phase를 따른다.

### Timeline 1: MVP (Day 1~14)

| 일차 | 작업 |
|---|---|
| Day 1~2 | Flutter 프로젝트 세팅, UI 와이어프레임, 한글 엔진 포팅 |
| Day 3~4 | 키보드 위치 변환기 구현 (영타로 로직 포팅) |
| Day 5~7 | 로마자 발음 변환기 구현 (오픈소스 포팅 + 주요 규칙) |
| Day 8~9 | 빌트인 한글 키패드 UI 구현 |
| Day 10~11 | 문구 라이브러리 (기본 팩 30~50개 + UI) |
| Day 12~13 | 플로팅 버블 (Kotlin 네이티브 + Platform Channel) |
| Day 14 | AdMob 통합, 테스트, Play Store 제출 |

### Timeline 2: 안정화 + v1.1 (Day 15~28)

| 일차 | 작업 |
|---|---|
| Day 15~17 | 버그 수정, 유저 피드백 반영 |
| Day 18~21 | 추가 문구팩 5종 제작 + 보상형 광고 통합 |
| Day 22~25 | 아이돌 이름 사전, K-pop 용어 사전 |
| Day 26~28 | Pro 구독 구현 (Google Play Billing) |

### Timeline 3: 성장 (Month 2~3)

- 컬러 테마 스킨
- 커스텀 문구 저장
- 홈 화면 위젯
- ASO 최적화 + 마케팅 강화
- 로마자 → 한글 역변환

---

## 9. 참조 링크

### 기술 참조

| 리소스 | URL | 용도 |
|---|---|---|
| zaeleus/hangeul (Rust) | https://github.com/zaeleus/hangeul | 로마자 변환 로직 참조 |
| KOROMAN (부산대) | https://roman.cs.pusan.ac.kr/input_eng.aspx | 국립국어원 표기법 기반 변환 |
| 국립국어원 로마자 표기법 | https://www.korean.go.kr/front/page/pageView.do?page_id=P000150 | 공식 표기 규칙 |
| learnkoreantools.com 변환기 | https://www.learnkoreantools.com/en/romanise-korean-text-hangeul | 결과 비교/검증 |
| flutter_overlay_window (pub) | https://pub.dev/packages/flutter_overlay_window | 플로팅 오버레이 참조 |
| system_alert_window (pub) | https://pub.dev/packages/system_alert_window | SYSTEM_ALERT_WINDOW 권한 |
| Google AdMob Flutter | https://pub.dev/packages/google_mobile_ads | 광고 통합 |
| Google Play Billing | https://pub.dev/packages/in_app_purchase | 구독 결제 |
| just_audio (pub) | https://pub.dev/packages/just_audio | 음성 파일 재생 |
| Cloudflare R2 | https://developers.cloudflare.com/r2/ | TTS 음성 파일 호스팅 (무료 티어: 10GB, 이그레스 무료) |

### 시장/경쟁자 참조

| 리소스 | URL | 용도 |
|---|---|---|
| 영타로 (기존 앱) | https://play.google.com/store/apps/details?id=com.dadak.typing_convertor | 기존 앱 레퍼런스 |
| Kpop Pro (경쟁자) | https://apps.apple.com/us/app/kpop-pro-karaoke-dance/id6447595959 | 경쟁자 분석 |
| BB: KPOP Korean Learning | https://play.google.com/store/apps/details?id=com.h2kresearch.bb | 경쟁자 분석 |
| Hangul Latin Converter | https://play.google.com/store/apps/details?id=com.wateryan.korean_converter | 로마자 변환 경쟁자 |
| Weverse (Play Store) | https://play.google.com/store/apps/details?id=co.benx.weverse | 타겟 유저가 사용하는 플랫폼 |
| Koreaboo 팬 문구 기사 | https://www.koreaboo.com/lists/fans-compile-extensive-list-useful-korean-phrases-can-tweet-idols/ | 수요 증거 |
| KONOGRAM Fan Letter | https://www.konogram.com/post/fan-letter-intro-the-first-step-to-connect-with-korean-stars-in-korean | 콘텐츠 방향 참조 |
| KONOGRAM Fan Lingo | https://www.konogram.com/p/words/hallyudict | K-pop 용어 참조 |
| Weverse Magazine 번역 기사 | https://magazine.weverse.io/article/view/688?lang=en | 번역 수요/문제 이해 |
| Screen Translator (경쟁자) | https://play.google.com/store/apps/details?id=com.galaxy.airviewdictionary | 플로팅 번역 경쟁자 |

### 문구 콘텐츠 소스

| 리소스 | URL | 용도 |
|---|---|---|
| Go Billy Korean 팬레터 가이드 | https://gobillykorean.com/how-to-write-a-letter-to-a-korean-celebrity-qa-13/ | 팬 문구 소스 |
| Hangul Hub 응원 문구 | https://koreanlanguageloving.wordpress.com/2023/02/17/korean-vocabulary-korean-phrases-to-encourage-your-kpop-idols/ | 팬 문구 소스 |
| VerbaCard K-pop 문구 | https://verbacard.com/blogs/news/kpop-korean-words-and-phrases | 팬 문구/용어 소스 |
| KoreanClass101 K-pop 문구 | https://www.koreanclass101.com/korean-vocabulary-lists/top-20-k-pop-words-phrases | 팬 문구 소스 |

---

## 10. 리스크 & 대응

| 리스크 | 확률 | 영향 | 대응 |
|---|---|---|---|
| 저품질 클론 앱 범람 | 높음 | 중간 | 품질 + UX + 리뷰 확보로 차별화, 지속적 업데이트 |
| 인디 개발자가 유사 앱 출시 | 중간 | 중간 | 선점 효과 + 문구 DB 지속 업데이트가 방어벽 |
| Kpop Pro가 유틸리티로 피봇 | 중간 | 높음 | 빠른 출시로 6개월 선점, 카테고리 정의 |
| 동남아 광고 eCPM이 예상보다 낮음 | 중간 | 중간 | 보상형 광고 비중 높이기, Pro 구독 현지화 가격 공격적 설정 |
| 플로팅 버블 권한 거부율 높음 | 중간 | 중간 | 권한 필요성 온보딩에서 명확히 설명, 버블 없이도 앱 내에서 모든 기능 사용 가능하게 |
| Google Play 정책 변경 (오버레이 제한) | 낮음 | 높음 | 앱 내 사용성을 항상 병행 유지, 버블은 부가 편의 기능으로 포지셔닝 |
| 로마자 변환 정확도 이슈 | 중간 | 낮음 | MVP는 주요 규칙만, 유저 리포트 기반으로 점진적 개선 |

---

## 부록 A: 앱 네이밍 전략

### 최종 결정: **Fangeul**

- **조어:** Fan + Hangul
- **발음:** 팬글 (영어/한국어 모두 자연스러움)
- **패키지명:** `com.tigerroom.fangeul`
- **Play Store 제목:** `Fangeul — Korean for K-pop Fans`

### 선정 이유

| 기준 | Fangeul | Malhae (차점) | Talkul (탈락) |
|---|---|---|---|
| 독창성 | ✅ 완전히 새로운 단어, 검색 경쟁 0 | △ BTS "말해 뭐해" 등 기존 콘텐츠와 겹침 | △ 직관적이나 인상이 약함 |
| 브랜드 독점성 | ✅ 검색하면 우리 앱만 노출 | ✗ BTS 곡/가사/뮤비 사이에 묻힐 가능성 | ✅ 경쟁 없음 |
| 의미 전달 | ✅ "Fan" + "Hangul" → K-pop 팬을 위한 한글 도구 | △ "말해 = Say it" 한국어 아는 사람만 인지 | △ "Talk" + "Hangul" 조합이 어색할 수 있음 |
| ASO 키워드 | ✅ "fan", "hangul" 양쪽 키워드 동시 포착 | △ "malhae" 단독 키워드 가치 낮음 | △ "talk" 너무 범용적 |
| K-pop 팬 어필 | ✅ "Fan"이 정체성을 즉시 전달 | ✅ BTS 팬 사이 인지도 높음 | ✗ K-pop 연결성 약함 |
| 글로벌 발음 | ✅ 영어권/동남아 모두 발음 쉬움 | △ 한국어 모르면 발음법 모름 | ✅ 발음 쉬움 |

### ASO 키워드에 Malhae 활용

Malhae의 BTS 팬 트래픽 곁다리 유입 효과를 버리지 않기 위해, Play Store 메타데이터에 활용:

- **스토어 설명문 내 자연스럽게 삽입:**
  - "Say it in Korean! (말해!) — Fangeul helps you speak to your idols"
  - "From '사랑해요' to '말해 뭐해', type any Korean phrase with ease"
- **키워드 필드:** `malhae, 말해, say korean, kpop korean, hangul type, fan korean`
- **스크린샷 캡션:** "말해! Say it in Korean with Fangeul"

이렇게 하면 **Fangeul이라는 독점 브랜드를 확보하면서 + BTS/K-pop 팬 검색 트래픽도 흡수**하는 이중 효과.

---

## 부록 B: 영타 변환 매핑 테이블 (두벌식 표준)

```
일반:
q→ㅂ  w→ㅈ  e→ㄷ  r→ㄱ  t→ㅅ  y→ㅛ  u→ㅕ  i→ㅑ  o→ㅐ  p→ㅔ
a→ㅁ  s→ㄴ  d→ㅇ  f→ㄹ  g→ㅎ  h→ㅗ  j→ㅓ  k→ㅏ  l→ㅣ
z→ㅋ  x→ㅌ  c→ㅊ  v→ㅍ  b→ㅠ  n→ㅜ  m→ㅡ

Shift:
Q→ㅃ  W→ㅉ  E→ㄸ  R→ㄲ  T→ㅆ  O→ㅒ  P→ㅖ
```

---

*이 문서는 Flutter 구현의 기반 스펙으로 사용한다. 코드 작성 시 각 섹션을 참조하여 모듈별로 구현한다.*
