# Fangeul — Session Handoff

BASE_COMMIT: 7c31481 (이전 핸드오프)
HANDOFF_COMMIT: b341c06
BRANCH: main

---

## 프로젝트 상태 (누적)

### 완료된 마일스톤
- Phase 1~6: Core 엔진 + 데이터 + UI + 버블 + 수익화 전체 완료
- v1.0.0+10 프로덕션 출시 완료
- **v1.1.0+19 프로덕션 출시 완료** — TTS 재생 + Analytics + 키보드 리팩토링
- **v1.1.1+20 프로덕션 검토 중** — 버블 아이콘 간격 수정

### 활성 작업
- v1.1.1+20 Play Store 검토 대기

### 보류/백로그
- **팬 미션**: 데일리 문구 타이핑 챌린지 + K-pop 캘린더 연동 (설계 완료, 미구현)
- **키보드 키 하이라이트**: 변환 결과 자모 해당 키 하이라이트 (설계 완료, 미구현)
- **InAppReview requestReview()**: DAU 쌓인 후 적절한 타이밍에 자동 표시
- **Firebase Analytics screen_view**: GoRouter observer 추가
- **유저 속성**: language, idol, IAP status setUserProperty
- **K-pop 데이터 확장**: kpopatlas.com API 크롤 → R2/Firebase 호스팅
- 기존 백로그: 푸시 알림, 구독 모델, Play Integrity API, PaletteRegistry 확장
- LOW 이슈: L3(자동닫기), L4(펄스), L5(복사기록 암호화)
- 리뷰 연기: I1(IdolSelectScreen setState→Riverpod), I6(즐겨찾기 템플릿 메타데이터)

---

## 이번 세션 작업 요약

### 배너 광고 정책 전면 변경
- Day 7 지연 → 온보딩 완료 후 즉시 노출 (RC `banner_delay_days` 기본 0)
- 보상형/세션 기반 배너 숨김 완전 제거 → IAP 구매 시만 배너 숨김
- `sessionBannerHiddenProvider` 코드 완전 삭제

### TTS 문구 재생 기능 (v1.1.0)
- 90개 mp3 파일 Fish Audio로 생성 → Cloudflare R2 CDN 업로드
- `TtsService`: R2 URL 구성 + 로컬 캐싱 (atomic .tmp → rename)
- `TtsPlayButton`: 공용 위젯, 펄스 애니메이션, 들은 문구 filled 아이콘
- PhraseCard + CompactPhraseList + DailyCard에 🔊 버튼
- 5회/일 제한 Day 0부터 (허니문 TTS 무제한 폐지)
- 보상형 +2회 (RC `tts_rewarded_bonus`), IAP 영구 무제한
- 데일리 카드 TTS 무료 (`freePlay: true`)
- 카운터 뱃지 (non-IAP 유저), 제한 팝업 (보상형 + IAP CTA)
- 같은 문구 재재생 카운트 안 함 (`sessionPlayedIds`)
- 재생 성공 후에만 카운트 소모 (네트워크 실패 시 쿼터 보호)

### Analytics 이벤트 전면 배선 (20개)
- IAP 퍼널: viewShop, startPurchase, purchaseSuccess, purchaseFailed, restore
- 광고: bannerImpression, rewardedComplete
- Fan pass: activated
- 제한: favLimitReached, ttsLimitReached, conversionTriggerShown/Clicked
- 라이프사이클: honeymoonEnded, ddayGiftActivated
- TTS: ttsPlay, ttsRewardedWatch
- 데일리 카드: phraseCopy (source: daily_card)

### 크래시 방어 (9파일)
- Firebase, IAP, AdService, Analytics, Calendar, Favorites, Bubble — 전부 try-catch
- `_safeLaunch()` for mailto/URL
- `_safeComplete()` for IAP completePurchase

### 팩 필터 칩 다국어 (8개 언어)
- pack id → arb 키 매핑 (`_localizedPackName`)

### Android 15 edge-to-edge
- `WindowCompat.setDecorFitsSystemWindows` — MainActivity + MiniConverterActivity
- deprecated `window.statusBarColor`/`navigationBarColor` 제거

### 아이돌 키보드 Gboard 리팩토링
- 단일 Listener + `_findNearest()` + AbsorbPointer — 데드존 제거

### 기타
- Tiger Room 대표 홈페이지 (tigerroom.app)
- 랜딩페이지 모바일 너비 수정 + 문구 개선 (결과 중심)
- `openStoreListing()` for Rate this app (requestReview → openStoreListing)
- 디버그 패널 TTS 칩 (count/reset/max)
- 버블 팝업 아이콘 균일 간격 (`Row(spacing: 12)`)
- r/BeginnerKorean 레딧 홍보 + 유저 피드백 대응

---

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| 배너 Day 0 (온보딩 후) | Day 7 리텐션 12~15%, 85%+ 유저 이탈 |
| 배너 숨김 = IAP만 | 보상형 배너숨김은 월 $300 누수 |
| TTS 허니문 무제한 폐지 | 유저 10명 미만, 정책 변경 최적 타이밍 |
| TTS 보상형 +2회 도입 | IAP only → 이탈. 보상형으로 98% 유저 붙잡기 |
| 데일리 카드 TTS 무료 | 리텐션 엔진, "오늘의 선물" |
| 카운터에 ∞ 금지 | 나중에 숫자로 바뀔 때 손실감 |

## 핵심 교훈

- ★ TTS 허니문 폐지: 유저 <10명일 때가 정책 변경 유일한 타이밍
- ★ 배너/TTS 다른 정책: 패시브(배너)=즉시, 액티브(TTS)=의도적 제한 — but 유저 없으면 둘 다 즉시가 맞음
- ★ `clearSessionPlayedIds` 불필요: 보상형 보너스 후 세션 기록 초기화하면 들은 표시 사라짐 + 카운트 중복
- ★ Analytics 상수 정의 ≠ 배선: 20개 이벤트 중 6개만 실사용, 14개 죽은 코드
- ★ 재생 성공 후 카운트: count-then-play → 네트워크 실패 시 쿼터 낭비. play-then-count가 올바름
- ★ `canPlayTtsProvider` 죽은 코드: playTtsProvider가 직접 gating하므로 불필요
- ★ mp3 캐시 partial write: `.tmp` → rename 패턴으로 atomic write
- ★ `Row(spacing:)` > `SizedBox(width:)` 수동 배치: 균일 간격 보장

## 다음 세션

### 1순위
- v1.1.1+20 검토 완료 확인
- Firebase Analytics 대시보드 구성 — 이벤트 확인
- screen_view 추적 추가 (GoRouter observer)

### 2순위
- 팬 미션 구현 ("오늘의 팬 미션" — 문구 타이핑 챌린지)
- 키보드 키 하이라이트 (변환 결과 자모 해당 키 반짝이기)

### 3순위
- K-pop 데이터 확장 (kpopatlas.com API 크롤)
- IAP subtitle 다국어 업데이트 ("+ TTS 무제한")
- InAppReview requestReview() 적절한 타이밍 구현

## 참고 컨텍스트

- TTS 패널 토론: `docs/discussions/2026-04-08-tts-ux-and-fan-mission.md`
- TTS 구현 계획: `docs/superpowers/plans/2026-04-09-tts-playback.md`
- TTS 문구 목록: `docs/tts-phrase-list.txt`
- 배너 정책 스펙: `docs/superpowers/specs/2026-04-06-banner-day0-migration-design.md`
- 릴리즈 노트: `docs/release-notes-v1.1.0.txt`, `docs/release-notes-v1.0.1.txt`
- 레딧 포스트: `docs/reddit-post-beginnerkorean.md`
- R2 CDN: `tts.tigerroom.app/ko/{pack}/{audio_id}.mp3`
- Firebase RC 파라미터: `banner_delay_days=0`, `tts_rewarded_bonus=2`, `daily_tts_limit=5`
