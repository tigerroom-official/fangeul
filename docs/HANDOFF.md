# Fangeul — Session Handoff

BASE_COMMIT: 54e6f25 (이전 핸드오프)
HANDOFF_COMMIT: 8cc2d80
BRANCH: main

---

## 프로젝트 상태 (누적)

### 완료된 마일스톤
- Phase 1~6: Core 엔진 + 데이터 + UI + 버블 + 수익화 전체 완료
- **v1.0.0+10 프로덕션 빌드 → Play Store 심사 중** (2026-04-01)
- 14일 비공개 테스트 통과 → 프로덕션 출시 제출
- GitHub Pages 랜딩페이지: `tigerroom-official.github.io/fangeul/` (다국어 en/ko)
- Google Search Console 소유권 인증 완료
- Testers Community Google 그룹 등록
- IAP bypass 수정 (persist gate, slot guard, undo guard, restoreConfig clear)
- 데일리 카드 템플릿 치환 (아이돌/멤버 설정 반영)
- **키보드 전면 리팩토링**: 시스템 키보드(Gboard) 방식 단일 Listener + 최근접 키 해석
- **숫자/특수문자 토글** (!#1 ↔ ABC)
- **커서 위치 편집**: 영→한 전모드 + 한→영/로마자 pending 자모 조합
- **변환기 입력 최적화**: 150ms 디바운스, controller.value 단일 할당, 뮤터블 jamoList
- 앱 버전 하드코딩 → PackageInfo 런타임 표시

### 활성 작업
- **v1.0.0+10 프로덕션 출시 완료** — Play Store 공개
- **v1.0.0+11 비공개 테스트 배포** — IAP auto-restore 수정 포함
- v1.0.0+11을 프로덕션으로 승격 예정 (비공개 테스트 검증 후)
- 랜딩페이지 스크린샷 v2로 업데이트 완료

### 보류/백로그 — 출시 후
- **v1.1 TTS**: 카드 문구 탭에서 한글 TTS 재생 (GPU 서버 자체 생성, Qwen 등)
- **v1.1 기능**: 한글 퍼즐(Wordle 스타일), 한글 카드 컬렉션(가챠)
- **v1.1+ 기능**: 푸시 알림(firebase_messaging), 구독 모델
- LOW 이슈 잔여: L3(자동닫기 설정), L4(펄스 애니메이션), L5(복사 기록 암호화)
- 리뷰 연기 이슈: I1(IdolSelectScreen setState→Riverpod), I6(즐겨찾기 템플릿 메타데이터)
- P1: 핸들 좌측 멤버 이름 노출 (버블 UX)
- P1: 버블 딥링크 — openMainApp → ThemePickerSheet 자동 오픈
- Play Integrity API / AdMob SSV
- PaletteRegistry 20-25개 확장
- IAP "팬글 서포터" 리프레이밍 (Phase 7.1)

---

## 작업 요약

IAP bypass 수정 + 데일리 카드 템플릿 치환 + 키보드 전면 리팩토링(Gboard 방식 데드존 제로) + 숫자/특수문자 토글 + 커서 위치 편집 + pending 자모 조합 + 변환기 입력 최적화 + 랜딩페이지 배포 + 프로덕션 빌드(v1.0.0+10) Play Store 제출. 807+ tests pass.

## 완료된 작업

- [x] IAP bypass 5건 수정 — persist gate, slot guard, undo guard, revoke methods, restoreConfig undo clear (ed2b197, 14f9634)
- [x] 앱 버전 하드코딩 수정 → PackageInfo 런타임 (bfd491f)
- [x] 데일리 카드 템플릿 치환 — hasGroupName/hasMemberName 플래그 + provider 치환 (3bc6dcf)
- [x] GitHub Pages 랜딩페이지 — 다국어(en/ko) + 버블 폰 모형 + Google Search Console 인증
- [x] 정책 페이지 영어 기본 + 한국어 자동감지
- [x] **키보드 Gboard 방식 리팩토링** — 단일 Listener + AbsorbPointer + _findNearest() (ed1e1be)
- [x] 백스페이스 즉시 반응 (Listener 기반) + 300ms→70ms→35ms 가속 삭제
- [x] 40ms 이중입력 방지 가드
- [x] **숫자/특수문자 토글** — !#1/ABC, 3행 배치 (6c864fc)
- [x] **커서 위치 편집** — 영→한 insertAtCursor/deleteAtCursor (6c864fc)
- [x] **pending 자모 조합** — 한→영/로마자 중간삽입 시 실시간 조합 (54e6f25)
- [x] 변환기 최적화 — 150ms 디바운스, controller.value 단일 할당, 뮤터블 jamoList
- [x] 변환기 입력 필드 maxLines: null (다중 행 확장)
- [x] mini_converter_screen 동일 로직 적용
- [x] v1.0.0+10 프로덕션 AAB 빌드 + Play Store 제출
- [x] 807+ tests pass

## 진행 중인 작업
- v1.0.0+11 비공개→프로덕션 승격 대기 (IAP restore 검증 후)

## 핵심 교훈

- ★ GestureDetector + InkWell 중첩 시 tap/longPress 판별 지연으로 백스페이스 씹힘 → Listener 기반 즉시 반응
- ★ 키 사이 Padding이 Listener 바깥이면 데드존 발생 → Listener를 Padding 바깥으로 이동
- ★ 행 간 SizedBox 간격도 데드존 → 근본 해결은 키보드 레벨 단일 Listener + 최근접 키 해석 (Gboard 패턴)
- ★ AbsorbPointer로 개별 키 제스처 차단 + 키보드 Listener가 모든 터치 처리
- ★ GlobalKey로 각 키 RenderBox 위치 추적 → _findNearest()로 직접 히트 or 최소 거리 폴백
- ★ controller.text + controller.selection 개별 설정 = 리빌드 2회 → controller.value 단일 할당 = 1회
- ★ _jamoList = [...list, item] spread 복사 O(n²) → .add() 뮤터블 O(1)
- ★ 한→영 모드 중간 편집: _jamoList 커밋 후 _engBuffer 기반 + pending 자모 조합으로 실시간 조합 유지
- ★ 비공개 테스트 14일 통과 → 프로덕션 직행 가능 (공개 테스트는 선택)
- ★ 프로덕션 트랙은 국가/지역 별도 설정 필요 (비공개와 공유 안 됨)
- ★ EU 지역 차단 규정: 무료앱 + Google 자동 환산이면 해당 없음
- ★ Testers Community Google 그룹 + 앱 크레딧 시스템으로 12명 테스터 확보

## 다음 단계

### 1순위: v1.1 TTS 구현
1. **TTS 음성 생산** — GPU 서버에서 Qwen/오픈소스 TTS로 전체 문구 음성 생성
2. **Cloudflare R2 업로드** — mp3/ogg 파일 CDN 캐싱
3. **카드 문구 탭 TTS UI** — 재생 버튼 + just_audio 재생
4. **하단 배너 광고 노출** — 문구 탭 상주 시 자연스러운 광고 노출

### 2순위: 출시 후 즉시
- 스크린샷 갱신 (숫자 키보드, 최신 UI)
- Firebase Analytics 대시보드 구성
- 유저 피드백 수집 → 버그 수정

### 3순위: v1.1 로드맵
- 일일카드 TTS 번들 ₩1,900 (패널 합의)
- 스트릭 "축하" 감성 보상 + 마일스톤 시스템
- PaletteRegistry 20-25개 확장
- 버블 딥링크 (ThemePickerSheet 자동 오픈)

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| Gboard 방식 키보드 리팩토링 | 개별 키 Listener로는 데드존 완전 제거 불가 → 키보드 레벨 단일 Listener + 최근접 해석 |
| 숫자/특수문자 토글 추가 | 시스템 키보드 대비 기능 부족 → !#1/ABC 토글로 기본 UX 확보 |
| pending 자모 조합 | 중간 삽입 시 개별 자모 노출은 UX 문제 → IME 방식 pending composition |
| 프로덕션 전세계 출시 | 국가 제한 = 잠재 유저 차단, 미지원 언어는 영어 fallback |
| TTS 자체 GPU 서버 생산 | 오픈소스 모델(Qwen 등) 상업적 사용 가능 → 외부 API 비용 제거 + 차별화 |

## 참고 컨텍스트

- 랜딩페이지: `tigerroom-official.github.io/fangeul/` (별도 레포)
- 랜딩페이지 소스: `docs/index.html` (개발 레포 동기화)
- 정책 페이지: `docs/privacy-policy.html`, `docs/terms.html`
- 프로덕션 출시 노트: `/tmp/release-notes-v1.txt`
- IAP bypass 토론: `docs/discussions/2026-03-15-theme-slot-iap-bypass-fix.md`

## 커밋 히스토리 (이번 세션)

```
8cc2d80 chore: bump version to 1.0.0+12
e9902a1 feat: update landing page screenshots to v2 + scroll/hover fixes
d45419d chore: bump version to 1.0.0+11 for IAP restore testing
f222952 fix: auto-restore IAP purchases on app startup
54e6f25 feat: pending jamo composition for mid-text editing
6c864fc feat: number/symbol toggle + cursor-aware mid-text editing
ed1e1be fix: keyboard zero dead zone + input optimizations
3bc6dcf fix: daily card template substitution based on idol/member settings
4872dc8 feat: replace bubble screenshot with phone mockup + floating icon
b8ab842 feat: add Korean language support to landing page
7da5f18 feat: auto-detect Korean browser language for policy pages
e33b787 fix: set English as default language for privacy policy and terms
5e5ca59 feat: add landing page for GitHub Pages
177b030 chore: bump version to 1.0.0+9 for closed testing
14f9634 fix: restoreConfig clears undo history to prevent preview bypass
bfd491f fix: replace hardcoded appVersion with runtime PackageInfo
d573578 chore: bump version to 1.0.0+8 for closed testing
ed2b197 fix: IAP bypass — persist gate, slot guard, undo guard, revoke methods
```

## 세션 히스토리

| 세션 | 요약 |
|------|------|
| P1~P3 | Core 엔진 + 데이터 레이어 완료 |
| P4 | UI 화면 구현 (홈, 변환기, 문구, 설정) |
| P5 | 플로팅 버블 전체 구현 + 리뷰 수정 |
| Sprint 1~2 | MVP UX + 상황태그 + K-pop 캘린더 |
| MVP 통합 | 마이아이돌 + 템플릿 + 온보딩 |
| Phase B~6 | 멤버 개인화 + 수익화 설계+구현 |
| i18n~설정 | 7개 언어 + Firebase + 버블 UX + 설정 |
| AdMob~테마 | 광고 + 팬 컬러 + HCT + 슬롯 + IAP |
| 릴리즈준비 | ProGuard + 서명 + UX 수정 + v1.0.0+4 |
| 크래시+스토어 | BadPaddingException + 에셋 + v1.0.0+5 |
| **프로덕션 출시** | IAP bypass 수정 + 키보드 리팩토링(Gboard 방식) + 숫자 토글 + 커서 편집 + 랜딩페이지 + v1.0.0+10 프로덕션 제출 |
