# Fangeul — Future Reference (통합 참조 문서)

> 구현 완료된 내용은 코드가 정본. 이 문서는 **아직 미구현이거나 향후 참조가 필요한 내용만** 보존한다.
>
> 원본: `engine-guide.md`, `fangeul-product-spec.md`, `fangeul-engagement-system.md` (삭제됨, git 히스토리에 보존)
>
> 최종 업데이트: 2026-02-28

---

## 1. 핵심 미구현 스펙

### 1.1 플로팅 버블 (Phase 5 — 핵심 엣지)

> **Fangeul의 최대 차별화 기능.** 다른 앱 위에 떠있는 버블로 즉시 한글 변환/문구 복사 가능.
> 현재 `lib/platform/`은 비어 있고, `FloatingBubbleService.kt`도 미구현.

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

**동작:**
- 다른 앱(Twitter, Weverse, YouTube) 위에 떠있는 버블
- 탭하면 미니 변환기 팝업: 텍스트 입력 → 한글 변환/발음 변환 → 복사
- 문구 라이브러리 바로가기
- 드래그로 위치 이동 가능

**참조용 오픈소스** (사용하지 않음, 구현 패턴만 참고):
- `flutter_overlay_window` (pub.dev)
- `system_alert_window` (pub.dev)

**리스크:** Google Play 오버레이 정책 변경 시 → 앱 내 사용성 병행 유지 필수, 버블은 부가 편의 기능으로 포지셔닝

### 1.2 TTS 시스템

- 사전 생성 방식: RTX 5090 TTS 서버에서 배치 생성 → Cloudflare R2 호스팅 → 앱에서 다운로드 후 로컬 캐싱
- 파일 네이밍: `{pack_id}_{phrase_id}.mp3`, `{pack_id}_{phrase_id}_slow.mp3`
- 무료: 기본 문구팩 음성 앱 번들 포함 (일반 속도만, ~3~5MB)
- Pro: 느린 발음 + 추가 문구팩 음성 다운로드 + 반복 재생 + 어절별 하이라이트 + 플로팅 버블 내 TTS
- 재생: `just_audio` 패키지

### 1.3 앱 네이밍/ASO 전략

**Play Store 제목:** `Fangeul — Korean for K-pop Fans`

**ASO 키워드 (경쟁 약한 틈새):**
- `korean keyboard kpop`, `hangul typing for fans`, `korean phrases kpop`
- `hangul romanization`, `type korean for kpop`, `weverse korean keyboard`

**Malhae 활용 (BTS 팬 트래픽 흡수):**
- 스토어 설명: "Say it in Korean! (말해!) — Fangeul helps you speak to your idols"
- 키워드: `malhae, 말해, say korean, kpop korean, hangul type, fan korean`

**스토어 설명 현지화:** 영어, 인도네시아어, 태국어, 포르투갈어(브라질), 스페인어

### 1.4 Phrase JSON 스키마 (정본)

```json
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
    }
  ]
}
```

보상형 광고 해금 팩: `"is_free": false, "unlock_type": "rewarded_ad"`

### 1.5 아이돌 이름 사전 (v1.1)

```json
{
  "idols": [
    {
      "name_ko": "방탄소년단",
      "name_en": "BTS",
      "roman": "bangtan sonyeondan",
      "members": [
        {"name_ko": "김남준", "name_en": "RM", "roman": "gim namjun"}
      ]
    }
  ]
}
```

---

## 2. 보안 & 어뷰징 방어 (상세)

> 가드레일은 `.claude/rules/00-project.md`에 정의. 여기는 **상세 위협 모델과 구현 가이드**.

### 2.1 위협 모델

| 위협 | 방법 | 영향 |
|---|---|---|
| APK 디컴파일 → 단어 풀 추출 | apktool, jadx | 퍼즐 답 유출, 스포일러 확산 |
| SharedPreferences 조작 | root + 파일 편집 | 스트릭/카드 무한 획득 |
| 시간 조작 (기기 시계 변경) | 설정 수동 변경 | 하루 여러 번 데일리 보상 수령 |
| 메모리 해킹 | GameGuardian 등 | 포인트/카드 수 변조 |
| 보상형 광고 콜백 위조 | 네트워크 패킷 조작 | 광고 안 보고 보상 수령 |

### 2.2 방어 전략

**데일리 퍼즐 답 보호:**
- 단어 풀 AES-256 암호화 (APK 내)
- 복호화 키 분산 저장, 런타임에만 조합
- 솔트+해시 기반 일일 인덱스 (패턴: `01-code-conventions.md` 참조)

**로컬 데이터 무결성:**
- `flutter_secure_storage` (Android Keystore 기반)
- HMAC-SHA256 서명 (패턴: `01-code-conventions.md` 참조)

**시간 조작 방어:**
- 단조증가 타임스탬프: 현재 시간 < 마지막 완료 시간 → 시간 조작 판정
- 48시간 이상 미래 점프 → 1일치만 인정
- 네트워크 가능 시 R2 서버 시간과 교차 검증 (차이 > 5분 → 차단)

**보상형 광고 검증:**
- AdMob `onUserEarnedReward` 콜백 + 중복 지급 방지
- 같은 보상 5분 내 재수령 불가, 하루 10회 제한
- 향후: AdMob SSV (Server Side Verification)

**APK 무결성:**
- 릴리즈 빌드 ProGuard/R8 난독화
- 런타임 APK 서명 해시 검증 (리패키징 감지)
- Play Integrity API로 root 감지 → root 기기에서 보상 기능만 비활성화

### 2.3 방어 우선순위

| 우선순위 | 항목 | 난이도 |
|---|---|---|
| P0 (필수) | 로컬 데이터 HMAC 서명 | 낮음 |
| P0 (필수) | 시간 조작 감지 (단조증가) | 낮음 |
| P0 (필수) | 보상형 광고 중복 지급 방지 | 낮음 |
| P1 (중요) | 단어 풀 AES 암호화 | 중간 |
| P1 (중요) | ProGuard/R8 난독화 | 낮음 (빌드 설정) |
| P2 (후순위) | APK 서명 런타임 검증 | 중간 |
| P2 (후순위) | Play Integrity API | 중간 |
| P3 (나중) | 서버 사이드 광고 검증 (SSV) | 높음 (서버 필요) |

---

## 3. 수익화 & KPI

### 3.1 수익 구조 (3 Tier)

**Free:**
- 전체 핵심 기능 (키패드, 변환, 발음, 플로팅 버블)
- 기본 문구팩 (30~50개)
- 하단 배너 광고

**보상형 광고 해금:**
- 추가 문구팩 (생일, 컴백, 콘서트, 위로, 일상)
- 컬러 테마 스킨
- 스트릭 프리즈, 추가 카드 (v1.1)

**Pro 구독 (월 $0.99, 지역별 현지화):**
- 광고 완전 제거
- 커스텀 문구 무제한
- 아이돌 이름 사전 전체
- 홈 위젯
- TTS 프리미엄 (느린 발음, 반복 재생, 어절별 하이라이트, 버블 내 TTS)
- 자동 프리즈 1개/주, 중복 카드 출현 50% 감소 (v1.1)
- 지역 가격: ID IDR15,000 / PH PHP49 / BR BRL5.90 / 영미권 $1.99~2.99

### 3.2 Engagement ↔ 수익화 매핑 (v1.1+)

| 기능 | 무료 | 보상형 광고 | Pro |
|---|---|---|---|
| 데일리 퍼즐 | 하루 1판 | - | 힌트 기능 |
| 스트릭 | 기본 | 프리즈 획득 | 자동 프리즈 1개/주 |
| 한글 카드 | 출석 1장 + 퍼즐 1장 | 추가 1장 | 중복 50% 감소 |
| Flash Phrase | 참여 가능 | - | 보너스 카드 2장 |
| 캘린더 | 상위 10그룹 | 추가 그룹 | 전체 + 커스텀 알림 |

### 3.3 수익 참고

- 동남아 배너 eCPM: $0.3~1.0 / 보상형 동영상 eCPM: $2~5
- 높은 사용 빈도 (매일 팬 활동) → 세션 수 높음 → 광고 노출 비례 상승
- Google Play 지역 가격 정책 활용 필수

### 3.4 KPI 목표

| 지표 | 1개월 | 3개월 | 6개월 |
|---|---|---|---|
| 다운로드 | 5,000 | 30,000 | 100,000+ |
| DAU | 500 | 3,000 | 15,000+ |
| Day 1 리텐션 | - | 40%+ | - |
| Day 7 리텐션 | 25%+ | 30%+ | 35%+ |
| Day 30 리텐션 | - | 20%+ | - |
| DAU/MAU | - | 30%+ | - |
| Pro 전환율 | 1% | 2% | 3% |
| 평균 세션 시간 | 1분 | 3분+ | - |
| 바이럴 계수 | 0 | 0.3+ | - |
| 평균 별점 | 4.0+ | 4.3+ | 4.5+ |

---

## 4. Post-MVP 로드맵

> 패널 토론 결과 반영. 원본: `docs/discussions/`

### v1.0 추가 (구현 예정)

| 기능 | 상태 | 비고 |
|---|---|---|
| 플로팅 버블 (Phase 5) | 미구현 | §1.1 참조 |
| 수익화 (Phase 6) | 미구현 | §3 참조 |
| 푸시 알림 (일일 리마인더) | 미구현 | K-pop 감성 알림, 최대 하루 2회 |

### v1.1 (출시 후 2~4주)

| 기능 | 비고 |
|---|---|
| 한글 카드 컬렉션 + 도감 | 포카 수집 문화 + 가챠, 카테고리별 도감 완성 보상 |
| K-pop 캘린더 + 문구 연동 | 생일/컴백/음방 스케줄, 상위 30그룹, R2 데이터 |
| Flash Phrase (BeReal 모델) | 랜덤 시간 퀴즈 + 30분 제한, 옵셔널 |
| 이벤트 연동 알림 | 생일 D-3, 컴백 D-1, 음방 출연일 |
| 아이돌 이름 사전 | 한글↔영어 매핑 DB |
| K-pop 용어 사전 | 막내, 음방, 컴백 등 |
| 추가 문구팩 5종 | 보상형 광고 해금 |
| 홈 화면 위젯 | 빠른 변환 + 오늘의 문구 |
| 데일리 퍼즐 (한글 Wordle) | 패널 토론: v1.1 조건부 (리텐션 데이터 확인 후) |

### v1.2+ (출시 후 1~2개월)

| 기능 | 비고 |
|---|---|
| 컬러 테마 스킨 | 팬덤 컬러 기반, 아이돌 이름/이미지 미사용 |
| 커스텀 문구 저장 | 유저 직접 추가/편집/폴더 관리 |
| K-pop 커넥션 (주간 보너스) | NYT Connections 모델 |
| 시즌 한정 카드 | 벚꽃, 크리스마스, 설날 |
| 로마자 → 한글 역변환 | saranghaeyo → 사랑해요 |

### v2.0+ (3개월+)

- 문장 빌더 (영어 의도 → 한국어 팬 표현 추천)
- 팬덤별 문구 팩 (커뮤니티 기여)
- 한글 쓰기 연습 (획순 가이드)
- 친구 초대 + 버디 스트릭 (Firebase)
- 리더보드 (주간 퍼즐 랭킹, Firebase)

### 스트릭 보상 체계 (참조)

| 스트릭 | 보상 |
|---|---|
| 3일 | 한글 카드 1장 보너스 |
| 7일 | 컬러 테마 1종 해금 |
| 14일 | 문구팩 1종 해금 (보상형 광고 대체) |
| 30일 | Pro 기능 3일 무료 체험 |
| 50일 | 특별 뱃지 + 앱 아이콘 변경권 |
| 100일 | 레전드 뱃지 + 전체 테마 해금 |

### 푸시 알림 시나리오 (참조)

**일일 리마인더 (오후 7~9시):**
- "오늘의 한글 퍼즐 아직 안 풀었어! 30초면 끝나~"
- "네 {N}일 스트릭이 위험해! 오늘 안에 한 번만 들어와"

**이벤트 연동 (캘린더 기반):**
- "{아이돌명} 생일 D-3! 생일 축하 문구 미리 준비해둘까?"
- "{그룹명} 컴백 D-1! 컴백 축하 문구팩 미리보기"

**정책:** 최대 하루 2회, 점진적 감소 (1주 매일 → 2주 격일 → 3주+ 위험시만), 유저 설정 가능

---

## 5. 리스크 & 참조 링크

### 5.1 리스크 매트릭스

| 리스크 | 확률 | 영향 | 대응 |
|---|---|---|---|
| 저품질 클론 앱 범람 | 높음 | 중간 | 품질 + UX + 리뷰 확보, 지속 업데이트 |
| Kpop Pro가 유틸리티로 피봇 | 중간 | 높음 | 빠른 출시로 6개월 선점, 카테고리 정의 |
| 동남아 광고 eCPM이 낮음 | 중간 | 중간 | 보상형 비중 높이기, Pro 현지화 가격 |
| 플로팅 버블 권한 거부율 | 중간 | 중간 | 온보딩 설명 + 버블 없이도 전체 기능 가능 |
| Google Play 오버레이 정책 변경 | 낮음 | 높음 | 앱 내 사용성 병행 유지 |

### 5.2 카피 위협도

| 위협 주체 | 수준 | 이유 |
|---|---|---|
| Weverse (HYBE) | 낮음 | 번역 유료화로 수익 중 |
| Google Translate | 매우 낮음 | 범용, K-pop 특화 불가 |
| Kpop Pro (STRA) | 중간 | 학습→유틸리티 피봇에 6개월+ |
| 인디 개발자 | 중간 | 통합 역량 부족 |

### 5.3 참고 모델

| 모델 | 원본 앱 | Fangeul 적용 |
|---|---|---|
| 데일리 퍼즐 | Wordle | 하루 1판 + 결과 공유 |
| 스트릭 + 손실 회피 | Duolingo | 한글 스트릭 + 프리즈 |
| 랜덤 긴급성 | BeReal | Flash Phrase |
| 수집 + 가챠 | 포카 문화 | 한글 카드 컬렉션 |
| 소셜 스트릭 | Snapchat | 버디 스트릭 (v1.2) |

### 5.4 기술 참조 링크

| 리소스 | URL |
|---|---|
| zaeleus/hangeul (Rust, 로마자 변환) | https://github.com/zaeleus/hangeul |
| KOROMAN (부산대) | https://roman.cs.pusan.ac.kr/input_eng.aspx |
| 국립국어원 로마자 표기법 | https://www.korean.go.kr/front/page/pageView.do?page_id=P000150 |
| flutter_overlay_window | https://pub.dev/packages/flutter_overlay_window |
| system_alert_window | https://pub.dev/packages/system_alert_window |
| Google AdMob Flutter | https://pub.dev/packages/google_mobile_ads |
| Google Play Billing | https://pub.dev/packages/in_app_purchase |
| just_audio | https://pub.dev/packages/just_audio |
| Cloudflare R2 | https://developers.cloudflare.com/r2/ |

### 5.5 초기 유저 확보 전략

1. Twitter/X: #KpopFans, #LearnKorean, #WeverseTips
2. Reddit: r/kpop, r/bangtan, r/kpophelp
3. TikTok: "한국어로 아이돌에게 메시지 보내는 법" 튜토리얼
4. 팬 계정 협업: K-pop 번역 계정에 앱 리뷰 요청
