# Fangeul — 금주의 문구 & 캘린더 수집 시스템 설계서

> 마이 아이돌 × 캘린더 × AI 문구 생성 = 매주 새로운 "지금 딱 맞는 한국어"
>
> 최종 업데이트: 2026-03-02
> 대상 버전: v1.1 (MVP 출시 후 2~4주)

---

## 1. 컨셉

### 한 줄 요약

유저가 설정한 **마이 아이돌**의 이번 주 이벤트(컴백, 생일, 음방 1위 등)를 자동 감지하고, **그룹명/멤버명이 들어간 맞춤 한국어 문구**를 Claude Code CLI로 자동 생성하여 6개 언어로 제공한다.

### 왜 엣지인가

| 기존 문구 라이브러리 | 금주의 문구 |
|---|---|
| "컴백 축하해요!" (범용) | "Whiplash로 1위 축하해요!! 역시 에스파 💜" (맥락형) |
| 항상 같은 문구 | 매주 새로운 문구 (복귀 이유) |
| 아이돌 이름 없음 | **내 아이돌 이름이 들어간 문구** |
| 수동 큐레이션 | API + AI 자동 생성 (운영 부담 최소) |

팬이 원하는 건 "한국어 문구"가 아니라 **"내 아이돌에게 지금 하고 싶은 말의 한국어 버전"**이다. 이걸 매주 자동으로 만들어주는 앱은 현재 존재하지 않는다.

### 전체 시스템 구성

```
[1단계: 캘린더 수집]     [2단계: 트렌드 감지]     [3단계: 문구 생성]
 Claude Code CLI          YouTube Data API v3       Claude Code CLI
 웹 브라우징 → 정보 수집    chart=mostPopular         이벤트 + 대상 → 문구
 → 규격화 JSON 출력        regionCode=KR             → 6개 언어 번역
        ↓                      ↓                         ↓
    schedule.json          trending.json             weekly_phrases.json
        └──────────┬───────────┘                         ↑
                   ↓                                     │
           [이벤트 통합 + 우선순위 결정] ─────────────────┘
                   ↓
           [R2 업로드 → 앱 다운로드]
```

---

## 2. 마이 아이돌 시스템

### 2.1 온보딩 플로우

1. 최초 가입 시 "좋아하는 아이돌을 선택하세요" 화면 표시
2. 그룹 목록에서 복수 선택 가능 (최소 1개, 제한 없음)
3. 그룹 선택 후 → 해당 그룹 멤버 목록 표시 → **최애 멤버** 선택 (옵션)
4. 설정 > 마이 아이돌에서 언제든 추가/삭제/변경 가능

### 2.2 지원 그룹 (v1.1 초기: 상위 30개)

4세대 중심으로 시작, 유저 요청에 따라 확장:

- HYBE: BTS, SEVENTEEN, TXT, ENHYPEN, LE SSERAFIM, NewJeans, BOYNEXTDOOR, ILLIT, &TEAM, KATSEYE
- SM: aespa, NCT (DREAM/127/WISH), Red Velvet, RIIZE
- JYP: Stray Kids, ITZY, NMIXX, TWICE
- YG: BLACKPINK, TREASURE, BABYMONSTER
- 기타: IVE, (G)I-DLE, ATEEZ, STAYC, Kep1er, xikers, ZEROBASEONE, KISS OF LIFE

### 2.3 데이터 구조

```json
{
  "groups": [
    {
      "id": "aespa",
      "name_ko": "에스파",
      "name_en": "aespa",
      "company": "SM",
      "debut_date": "2020-11-17",
      "members": [
        {
          "id": "karina",
          "name_ko": "카리나",
          "name_en": "Karina",
          "birthday": "04-11",
          "position": "리더, 메인댄서"
        },
        {
          "id": "winter",
          "name_ko": "윈터",
          "name_en": "Winter",
          "birthday": "01-01",
          "position": "리드보컬"
        }
      ]
    }
  ]
}
```

- 이 데이터는 초기 1회 수동 빌드 (공개 정보)
- 신규 그룹/멤버 추가는 수동 업데이트 (빈도 낮음)
- 앱 번들에 포함 (오프라인 사용 가능)

---

## 3. 캘린더 수집 시스템

### 3.1 수집 대상 이벤트 유형

| 유형 | 예시 | 빈도 | 문구 생성 여부 |
|---|---|---|---|
| 생일 | 카리나 생일 4/11 | 고정 (연 1회/멤버) | ✅ |
| 데뷔 기념일 | 에스파 데뷔 11/17 | 고정 (연 1회/그룹) | ✅ |
| 컴백 | 에스파 미니 5집 3/15 | 비정기 | ✅ (최우선) |
| 음방 1위 | 에스파 Whiplash 엠카 1위 | 비정기 | ✅ |
| 콘서트/팬미팅 | 에스파 서울 콘서트 5/10 | 비정기 | ✅ |
| 음방 출연 | 에스파 음악중심 출연 | 주간 (컴백 기간) | ⭕ (선택) |
| 멤버 개인 활동 | 카리나 드라마 출연 | 비정기 | ⭕ (선택) |

### 3.2 수집 소스

#### 정적 데이터 (1회 빌드, 수동 갱신)

- **생일**: 공개 프로필 정보 → `birthdays.json` 초기 빌드
- **데뷔 기념일**: 공개 정보 → `anniversaries.json` 초기 빌드
- 변경 빈도 극히 낮음 → 수동 관리 충분

#### 동적 데이터 (주기적 수집)

| 소스 | 수집 내용 | 방법 | 주기 |
|---|---|---|---|
| YouTube Data API v3 | 트렌딩 K-pop MV (컴백 감지, 조회수 폭발 감지) | 공식 API (chart=mostPopular, regionCode=KR, videoCategoryId=10) | 주 2~3회 |
| K-pop 팬 스케줄 계정 | 컴백 일정, 음방 출연, 팬미팅 | Claude Code CLI 웹 브라우징 | 주 2회 |
| 음원 차트 (Melon/Bugs) | 신규 진입곡 = 컴백 확인, 1위 감지 | 오픈소스 스크래퍼 (music-api-kr) 또는 Claude CLI | 주 2~3회 |
| 공식 SNS/공지 | 콘서트, 팬미팅, 특별 이벤트 | Claude Code CLI 웹 브라우징 | 주 1~2회 |

### 3.3 Claude Code CLI 기반 캘린더 수집 파이프라인

#### 왜 Claude Code CLI인가

- 웹 브라우징 MCP로 팬사이트/SNS를 사람처럼 접근 → 크롤링 차단 우회
- 비정형 텍스트(팬 게시글, 공지사항)에서 구조화된 이벤트 정보 추출에 LLM이 최적
- 별도 크롤러/파서 개발 불필요 → 프롬프트 하나로 수집+가공+출력
- Reddit/X 직접 크롤링의 법적 리스크 회피

#### 수집 프롬프트 설계

**프롬프트 1: 주간 K-pop 스케줄 수집**

```
역할: K-pop 스케줄 수집 에이전트

작업:
1. 아래 소스들을 웹 브라우징으로 확인하여 이번 주 ~ 다음 주 K-pop 이벤트를 수집해줘
   - @KPOPSchedule (X/Twitter)
   - Blip 앱 공식 스케줄
   - 각 기획사 공식 SNS (HYBE, SM, JYP, YG)
   - Soompi/AllKPop 뉴스 (컴백 확정 소식)

2. 대상 그룹: [마이 아이돌 목록에서 전달]

3. 수집할 이벤트 유형:
   - 컴백 (앨범 발매일, 타이틀곡명)
   - 음방 출연 (날짜, 프로그램명)
   - 콘서트/팬미팅 (날짜, 장소)
   - 특별 이벤트 (팬싸, 영상통화, 기타)

4. 출력 형식: 아래 JSON 규격 엄수
```

**프롬프트 2: 음방 1위 / 차트 성과 감지**

```
역할: K-pop 차트 성과 감지 에이전트

작업:
1. 이번 주 음악방송 1위 결과를 확인해줘
   - 엠카운트다운 (월)
   - 더쇼 (화)
   - 쇼챔피언 (수)
   - 뮤직뱅크 (금)
   - 음악중심 (토)
   - 인기가요 (일)

2. 대상 그룹: [마이 아이돌 목록에서 전달]

3. 해당 그룹이 1위를 했으면 이벤트로 기록

4. 출력 형식: 아래 JSON 규격 엄수
```

### 3.4 수집 출력 JSON 규격

```json
{
  "collected_at": "2026-03-02T09:00:00+09:00",
  "week": "2026-W10",
  "source_agent": "claude-code-cli",
  "events": [
    {
      "id": "aespa_comeback_whiplash_20260301",
      "type": "comeback",
      "group_id": "aespa",
      "group_name_ko": "에스파",
      "member_id": null,
      "member_name_ko": null,
      "title": "미니 5집 'Whiplash' 발매",
      "title_detail": "타이틀곡 'Whiplash'",
      "date": "2026-03-01",
      "date_end": null,
      "recurring": false,
      "source": "SM Entertainment 공식 공지",
      "confidence": "high",
      "tags": ["컴백", "미니앨범", "Whiplash"]
    },
    {
      "id": "aespa_win_mcountdown_20260303",
      "type": "music_show_win",
      "group_id": "aespa",
      "group_name_ko": "에스파",
      "member_id": null,
      "member_name_ko": null,
      "title": "엠카운트다운 1위",
      "title_detail": "'Whiplash'로 첫 1위",
      "date": "2026-03-03",
      "date_end": null,
      "recurring": false,
      "source": "Mnet 엠카운트다운 공식",
      "confidence": "high",
      "tags": ["음방", "1위", "엠카운트다운"]
    },
    {
      "id": "bts_jungkook_birthday_20260901",
      "type": "birthday",
      "group_id": "bts",
      "group_name_ko": "방탄소년단",
      "member_id": "jungkook",
      "member_name_ko": "정국",
      "title": "정국 생일",
      "title_detail": null,
      "date": "2026-09-01",
      "date_end": null,
      "recurring": true,
      "source": "프로필 정보",
      "confidence": "confirmed",
      "tags": ["생일"]
    },
    {
      "id": "newjeans_concert_seoul_20260510",
      "type": "concert",
      "group_id": "newjeans",
      "group_name_ko": "뉴진스",
      "member_id": null,
      "member_name_ko": null,
      "title": "NewJeans Fan Meeting 'Bunnies Camp'",
      "title_detail": "서울 KSPO DOME",
      "date": "2026-05-10",
      "date_end": "2026-05-11",
      "recurring": false,
      "source": "ADOR 공식 공지",
      "confidence": "confirmed",
      "tags": ["콘서트", "팬미팅", "서울"]
    }
  ]
}
```

#### JSON 필드 설명

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | string | `{group}_{type}_{detail}_{date}` 형식의 고유 ID |
| `type` | enum | `birthday`, `debut_anniversary`, `comeback`, `music_show_win`, `concert`, `fanmeeting`, `music_show_appearance`, `special` |
| `group_id` | string | 그룹 식별자 (groups.json의 id와 매칭) |
| `member_id` | string? | 멤버별 이벤트일 때만 사용 (생일 등) |
| `title` | string | 이벤트 제목 (한국어) |
| `title_detail` | string? | 부가 정보 (곡명, 장소 등) |
| `date` / `date_end` | string | ISO 날짜. 기간 이벤트는 end 포함 |
| `recurring` | boolean | 매년 반복 여부 (생일, 기념일) |
| `confidence` | enum | `confirmed` (공식 확인), `high` (신뢰도 높음), `rumor` (미확인) |
| `tags` | string[] | 검색/필터용 태그 |

### 3.5 수집 운영 스케줄

| 요일 | 작업 | 소요 시간 | 비용 |
|---|---|---|---|
| 월 | Claude CLI: 주간 스케줄 수집 + YouTube API: 트렌딩 MV 수집 | ~5분 (자동) | Claude CLI ~$0.05, YouTube API 3 units |
| 목 | Claude CLI: 음방 1위 결과 수집 + 차트 성과 확인 | ~5분 (자동) | Claude CLI ~$0.05 |
| 금 | 금주의 문구 생성 (섹션 4) + R2 업로드 | ~5분 (자동) | Claude CLI ~$0.10 |

- **월간 총 비용: ~$1 이하**
- RTX 5090 서버에서 크론잡으로 자동 실행
- 수집 후 Seo가 10분 내 검수 (초기에는 반수동, 안정화 후 완전 자동)

### 3.6 수집 데이터 검증

Claude CLI가 수집한 데이터는 아래 기준으로 자동 검증:

- `confidence`가 `rumor`인 이벤트는 앱에 반영하지 않음
- 같은 이벤트가 중복 수집되면 `id` 기준으로 dedupe
- `date`가 과거이면 "지난 이벤트"로 분류 (음방 1위 등 성과형은 유지)
- 새로 수집된 이벤트와 기존 데이터의 diff만 R2에 업로드 (앱 다운로드 최소화)

---

## 4. 금주의 문구 자동 생성

### 4.1 생성 파이프라인

```
[캘린더 이벤트 (이번 주)]
  + [YouTube 트렌딩 (K-pop MV)]
  + [음방 1위 결과]
        ↓ 통합
[이벤트 우선순위 결정]
  1순위: 컴백 (가장 활발한 팬 활동 시점)
  2순위: 음방 1위 (축하 문구 수요 폭발)
  3순위: 생일 (감성적 메시지)
  4순위: 콘서트/팬미팅 (응원 문구)
  5순위: 데뷔 기념일
        ↓
[Claude Code CLI: 문구 생성]
        ↓
[weekly_phrases_{week}.json]
        ↓
[Seo 검수 (10분)]
        ↓
[R2 업로드]
        ↓
[앱 다운로드 → "🔥 금주의 문구" 섹션에 표시]
```

### 4.2 문구 생성 프롬프트 설계

```
역할: K-pop 팬 한국어 문구 작성 전문가

맥락:
이번 주 이벤트:
- 에스파 미니 5집 'Whiplash' 컴백 (3/1)
- 에스파 엠카운트다운 1위 (3/3)
- 뉴진스 컴백 D-3 (3/15 발매 예정)
- 정국 생일 D-7 (9/1)

작업:
각 이벤트에 대해 아래 조건으로 한국어 문구를 생성해줘.

조건:
1. 대상별로 문구 생성:
   - 그룹 전체용: "{그룹명}"이 자연스럽게 포함
   - 멤버별 문구: "{멤버명}"이 자연스럽게 포함
   (멤버별은 해당 그룹 전 멤버에 대해 각각 생성)

2. 톤:
   - 팬이 아이돌에게 말하는 존댓말
   - 진심이 느껴지되 과하지 않게
   - 이모지 1~2개 자연스럽게 포함
   - 실제 Weverse/Twitter에 바로 붙여넣을 수 있는 자연스러운 문장

3. 각 이벤트 × 각 대상(그룹/멤버)별로 3개씩 생성
   - 짧은 버전 (1줄, ~30자)
   - 중간 버전 (2줄, ~60자)
   - 긴 버전 (3~4줄, ~120자)

4. 각 문구에 대해:
   - 로마자 발음 (romanization)
   - 6개 언어 번역: en, id, th, pt-BR, es, vi

5. 하지 말 것:
   - 비속어, 과도한 팬픽 톤
   - 특정 멤버 비교/순위
   - 사실과 다른 내용 (날짜, 앨범명 등 정확히)

출력: JSON (규격은 아래 참조)
```

### 4.3 생성 예시

**이벤트: 에스파 'Whiplash' 엠카운트다운 1위**

그룹 전체용:
```
짧은: "Whiplash 1위 축하해요!! 역시 에스파 💜"
중간: "에스파 Whiplash 1위 너무 축하해요! 이 노래 정말 중독성 있어요 💜🎵"
긴:  "에스파 엠카운트다운 1위 진짜 축하해요!! Whiplash 무대 볼 때마다
      소름이 돋아요. 이번 컴백 정말 대박이에요. 앞으로도 쭉 1위 하자! 💜"
```

카리나 지정:
```
짧은: "카리나 1위 축하해요!! 무대 최고였어요 🔥"
중간: "카리나 Whiplash 무대 너무 멋있었어요! 1위 축하해요!! 💜🔥"
긴:  "카리나 엠카운트다운 1위 축하해요!! Whiplash 무대에서 카리나
      파트 들을 때마다 심장이 두근거려요. 역시 리더! 앞으로도 응원할게요 💜"
```

### 4.4 출력 JSON 규격

```json
{
  "week": "2026-W10",
  "generated_at": "2026-03-07T10:00:00+09:00",
  "events": [
    {
      "event_id": "aespa_win_mcountdown_20260303",
      "event_type": "music_show_win",
      "event_title": "에스파 엠카운트다운 1위 (Whiplash)",
      "phrases": {
        "group:aespa": [
          {
            "length": "short",
            "ko": "Whiplash 1위 축하해요!! 역시 에스파 💜",
            "rom": "Whiplash il-wi chukahaeyo!! yeoksi aespa",
            "translations": {
              "en": "Congrats on #1 with Whiplash!! That's aespa for you 💜",
              "id": "Selamat juara 1 dengan Whiplash!! Memang aespa 💜",
              "th": "ยินดีด้วยกับอันดับ 1 Whiplash!! aespa สุดยอด 💜",
              "pt": "Parabéns pelo 1º lugar com Whiplash!! É a aespa 💜",
              "es": "¡Felicidades por el #1 con Whiplash!! Así es aespa 💜",
              "vi": "Chúc mừng hạng 1 với Whiplash!! Đúng là aespa 💜"
            }
          },
          {
            "length": "medium",
            "ko": "에스파 Whiplash 1위 너무 축하해요! 이 노래 정말 중독성 있어요 💜🎵",
            "rom": "aespa Whiplash il-wi neomu chukahaeyo! i norae jeongmal jungdokseong isseoyo",
            "translations": { "en": "...", "id": "...", "th": "...", "pt": "...", "es": "...", "vi": "..." }
          },
          {
            "length": "long",
            "ko": "에스파 엠카운트다운 1위 진짜 축하해요!! Whiplash 무대 볼 때마다 소름이 돋아요. 이번 컴백 정말 대박이에요. 앞으로도 쭉 1위 하자! 💜",
            "rom": "...",
            "translations": { "en": "...", "id": "...", "th": "...", "pt": "...", "es": "...", "vi": "..." }
          }
        ],
        "member:karina": [
          {
            "length": "short",
            "ko": "카리나 1위 축하해요!! 무대 최고였어요 🔥",
            "rom": "Karina il-wi chukahaeyo!! mudae choegoyeosseoyo",
            "translations": { "en": "...", "id": "...", "th": "...", "pt": "...", "es": "...", "vi": "..." }
          }
        ],
        "member:winter": [ "..." ],
        "member:giselle": [ "..." ],
        "member:ningning": [ "..." ]
      }
    }
  ]
}
```

### 4.5 생성 규모 추정

주간 이벤트 3~5개 × 대상 (그룹 1 + 멤버 4~7명) × 문구 3개(짧/중/긴) × 6개 언어

- 이벤트 4개 × 평균 대상 5개 × 3문구 = **60개 한국어 문구**
- × 6개 언어 번역 = **360개 번역 문구**
- JSON 파일 크기: 약 50~100KB (주간)
- Claude CLI 호출: 1~2회 (비용 ~$0.10)

---

## 5. 앱 내 표시 & 유저 플로우

### 5.1 홈 화면 배치

```
┌──────────────────────────┐
│  🔥 금주의 문구            │  ← 홈 상단 고정 섹션
│  ┌────────────────────┐  │
│  │ 에스파 Whiplash 1위 │  │  ← 이벤트 카드 (가로 스와이프)
│  │ "1위 축하해요!!"    │  │
│  │ [복사] [더보기]     │  │
│  └────────────────────┘  │
│  ┌────────────────────┐  │
│  │ 뉴진스 컴백 D-3    │  │  ← 다음 이벤트 카드
│  │ "컴백 기대돼요!!"   │  │
│  └────────────────────┘  │
│                          │
│  📚 문구 라이브러리       │  ← 기존 범용 문구 (아래)
│  ...                     │
└──────────────────────────┘
```

### 5.2 유저 인터랙션

1. **금주의 문구 카드 탭** → 해당 이벤트의 전체 문구 목록 펼침
2. **그룹/멤버 탭 전환** → "에스파 전체" ↔ "카리나" ↔ "윈터" ↔ ...
3. **문구 탭** → 짧은/중간/긴 버전 선택
4. **복사 버튼** → 클립보드 복사 + "Weverse에서 붙여넣기!" 토스트
5. **카드 이미지로 공유** → 문구 + 감성 배경 카드 생성 → SNS 공유 (바이럴)
6. **발음 듣기** → TTS 재생 (로마자 확인하며 따라하기)

### 5.3 마이 아이돌 기반 필터링

- 금주의 문구 섹션에는 **유저가 설정한 마이 아이돌의 이벤트만** 표시
- 마이 아이돌이 없으면 → 전체 상위 이벤트 표시 + "마이 아이돌 설정하기" 유도
- 마이 아이돌의 이벤트가 이번 주에 없으면 → "이번 주는 조용한 한 주! 다음 이벤트: {D-N}" 표시

### 5.4 푸시 알림 연동

금주의 문구가 업데이트되면:
- "이번 주 {에스파}에게 보낼 새 문구가 도착했어요! 💜"
- "🎂 {정국} 생일 D-3! 축하 문구 미리 준비해볼까?"
- 마이 아이돌 기준으로 개인화된 알림

---

## 6. YouTube Data API v3 활용

### 6.1 역할

캘린더 수집의 **보조 소스** + **트렌드 확인**용. 메인 수집은 Claude CLI 웹 브라우징이 담당하고, YouTube API는 아래 용도로 활용:

- 컴백 MV 공개 감지 (트렌딩 Music에 새 MV 등장)
- 조회수 폭발 감지 (이슈가 되고 있는 영상 = 문구 수요)
- 컴백 시기 교차 검증 (Claude CLI 수집 결과와 대조)

### 6.2 API 호출 구성

| 엔드포인트 | 파라미터 | 쿼터 | 용도 |
|---|---|---|---|
| `videos.list` | `chart=mostPopular`, `regionCode=KR`, `videoCategoryId=10`, `maxResults=50` | 1 unit/call | 한국 트렌딩 Music 영상 50개 |
| `videos.list` | 동일, `pageToken`으로 2~3페이지 | 1 unit/call | 추가 50~100개 |

- 주 2회 호출 × 3페이지 = **6 units/주**
- 일일 무료 한도 10,000 units 대비 **0.06%**

### 6.3 트렌딩 데이터에서 추출하는 것

YouTube 트렌딩 MV 제목/태그에서 직접 추출:

- **그룹명** (한글/영어): "에스파", "aespa"
- **곡명**: "'Whiplash'"
- **콘텐츠 유형**: "MV", "직캠", "안무 연습", "비하인드"
- **성과 지표**: 조회수, 좋아요 수 → "이 그룹이 지금 화제" 판단 근거

이 데이터는 금주의 문구 생성 시 **맥락 보강**에 활용:
- 트렌딩 1위 MV가 있으면 → 해당 곡명을 문구에 포함
- 조회수 1억 돌파 등 → 특별 축하 문구 생성 트리거

---

## 7. R2 업로드 & 앱 동기화

### 7.1 파일 구조

```
R2 버킷: fangeul-data/
├── groups.json                    (그룹/멤버 마스터 데이터, 비정기 업데이트)
├── schedule/
│   ├── birthdays.json             (생일 데이터, 연 1회 업데이트)
│   ├── anniversaries.json         (데뷔 기념일, 연 1회 업데이트)
│   └── events_2026_W10.json       (주간 동적 이벤트)
├── weekly_phrases/
│   ├── phrases_2026_W10.json      (금주의 문구)
│   ├── phrases_2026_W09.json      (지난주 문구, 아카이브)
│   └── ...
└── manifest.json                  (버전 관리, 앱에서 체크)
```

### 7.2 manifest.json

```json
{
  "version": 15,
  "updated_at": "2026-03-07T10:30:00+09:00",
  "files": {
    "groups": { "version": 2, "path": "groups.json" },
    "birthdays": { "version": 1, "path": "schedule/birthdays.json" },
    "current_events": { "version": 10, "path": "schedule/events_2026_W10.json" },
    "current_phrases": { "version": 10, "path": "weekly_phrases/phrases_2026_W10.json" }
  }
}
```

- 앱은 하루 1회 `manifest.json` 체크
- 버전 변경 감지 시 해당 파일만 백그라운드 다운로드
- 오프라인에서도 마지막 캐시 데이터로 동작

---

## 8. 운영 플로우 요약

### 주간 운영 사이클 (소요: 약 30분/주)

| 요일 | 작업 | 자동/수동 | 소요 |
|---|---|---|---|
| 월 AM | 크론: Claude CLI 주간 스케줄 수집 | 자동 | 5분 |
| 월 AM | 크론: YouTube API 트렌딩 MV 수집 | 자동 | 1분 |
| 월 PM | Seo: 수집 결과 검수 (events JSON 확인) | 수동 | 5분 |
| 목 AM | 크론: Claude CLI 음방 1위 결과 수집 | 자동 | 5분 |
| 목 PM | Seo: 수집 결과 검수 | 수동 | 5분 |
| 금 AM | 크론: Claude CLI 금주의 문구 생성 | 자동 | 5분 |
| 금 PM | Seo: 문구 품질 검수 (한국어 자연스러움 확인) | 수동 | 10분 |
| 금 PM | R2 업로드 (자동 스크립트) | 자동 | 1분 |

### 비용 요약

| 항목 | 주간 | 월간 |
|---|---|---|
| Claude CLI (수집 + 문구 생성) | ~$0.20 | ~$0.80 |
| YouTube Data API | 6 units (무료 한도 내) | 24 units |
| Cloudflare R2 (저장 + 전송) | 무료 (10GB 이내) | 무료 |
| **총 비용** | **~$0.20** | **~$0.80** |

---

## 9. 리스크 & 대응

### 9.1 문구 품질 리스크

**문제:** Claude가 생성한 한국어가 어색하거나 부자연스러울 수 있음

**대응:**
- 초기 4주는 Seo가 직접 전수 검수 (주 10분)
- 검수 시 수정한 내용을 Claude 프롬프트에 피드백으로 반영 → 품질 점진 향상
- "이 문구가 어색해요" 유저 신고 버튼 → 다음 주 프롬프트 개선에 반영
- 안정화 후 (4주+) 검수 생략 가능 여부 판단

### 9.2 캘린더 수집 정확도

**문제:** Claude CLI가 잘못된 스케줄 정보를 수집할 수 있음

**대응:**
- `confidence` 필드로 신뢰도 분류 → `rumor`는 앱 비반영
- 2개 이상 소스에서 확인된 이벤트만 `confirmed` 부여
- 생일/기념일은 정적 데이터 → 오류 가능성 거의 없음
- 컴백/음방 결과는 공식 소스(기획사 SNS) 우선 참조

### 9.3 특정 팬덤 편향

**문제:** 상위 그룹 위주로 콘텐츠가 편중되면 소규모 팬덤 유저 이탈

**대응:**
- 마이 아이돌 설정한 그룹은 규모 무관하게 수집 대상에 포함
- 초기 30개 그룹 → 유저 요청에 따라 확장 (그룹 추가 요청 기능)
- 이벤트 없는 주에도 범용 문구("오늘도 응원해요!" 등)는 제공

### 9.4 확장성

**문제:** 그룹 수 × 멤버 수가 늘어나면 문구 생성량 폭증

**대응:**
- 금주의 문구는 **이벤트가 있는 그룹만** 생성 (전 그룹 매주 X)
- 이벤트 없는 그룹은 기존 범용 문구 라이브러리 활용
- Claude CLI 1회 호출로 여러 그룹 문구 배치 생성 가능 → 비용 선형 증가 아님

---

## 10. 구현 우선순위 (v1.1 내)

| 순서 | 항목 | 구현일 | 선행 조건 |
|---|---|---|---|
| 1 | 마이 아이돌 선택 UI + 데이터 저장 | 1.5일 | groups.json 준비 |
| 2 | groups.json 초기 빌드 (30개 그룹) | 1일 | 없음 |
| 3 | birthdays.json + anniversaries.json 빌드 | 0.5일 | groups.json |
| 4 | 캘린더 수집 프롬프트 작성 + 테스트 | 1일 | 없음 |
| 5 | YouTube API 트렌딩 수집 스크립트 | 0.5일 | API 키 발급 |
| 6 | 금주의 문구 생성 프롬프트 작성 + 테스트 | 1일 | 캘린더 데이터 |
| 7 | R2 업로드/다운로드 파이프라인 | 1일 | R2 버킷 설정 |
| 8 | 앱: 금주의 문구 섹션 UI | 2일 | 문구 JSON |
| 9 | 앱: 그룹/멤버 탭 전환 + 복사 기능 | 1일 | UI 완성 |
| 10 | 크론잡 설정 (RTX 5090 서버) | 0.5일 | 스크립트 완성 |
| 11 | 푸시 알림 연동 | 1일 | 기존 알림 시스템 |
| **소계** | | **~11일** | |