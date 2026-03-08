# 사용자 데이터 보존 전략 — 재설치/기기변경 대응

**일시**: 2026-03-08
**패널**: 박서버(백엔드 아키텍트), 김프라(인디 개발자), 이시큐(결제/보안), 최덕팬(K-pop 팬 경제), 한클라(Firebase 솔루션 아키텍트)

---

## 배경

앱 재설치/기기변경 시 사용자 데이터(즐겨찾기, IAP, 테마 설정) 손실 문제.

### 현재 상태
- SharedPreferences: 설정, 즐겨찾기, 테마 (재설치 시 삭제)
- SecureStorage + HMAC: 수익화/IAP 상태 (재설치 시 삭제)
- IAP: Google Play `restorePurchases()`로 구매 복원 가능
- Firebase: Analytics/Crashlytics/RC만 사용, Auth/Firestore 미사용
- 인증: 없음 (익명 사용)

---

## 투표 결과

| 항목 | 찬성 | 반대 |
|------|------|------|
| v1.0 JSON export/import | 5 (전원) | 0 |
| v1.0 Auth 도입 | 0 | 4 (한클라 중립) |
| v1.0 Firestore | 0 | 5 (전원) |
| v1.1 Auth+Firestore 동시 | 5 (전원) | 0 |

## 합의 사항

### v1.0 (MVP)
1. **서버리스 유지** — Firestore/Auth 미도입
2. **JSON export/import** — 설정 화면에 "내 팬 설정 저장/불러오기"
   - 백업 대상: 즐겨찾기, 테마, 아이돌 설정, 로케일
   - 제외: IAP/보안 데이터 (restorePurchases()로 복원)
   - 스키마: `backupVersion: 1`, ISO 8601 날짜, 타입 검증
   - 방식: `share_plus`로 공유 (카카오톡/드라이브)
   - import: 덮어쓰기 (확인 다이얼로그)
3. **Analytics uid** = Firebase Installation ID (Auth 없이 코호트 분석)

### v1.1 (출시 후 3~5주)
4. **Firebase Auth (Google 로그인, 선택적)** + **Firestore 동기화** 동시 출시
5. **단일 document 구조** `users/{uid}` — 세션당 1 read, DAU 20K까지 무료
6. **Local-first + last-write-wins** — `lastSyncedAt` 타임스탬프 기반
7. 동기화: 포그라운드 pull + 백그라운드 push + 5분 디바운스
8. purchases 컬렉션 미생성 (v1.2까지)

### v1.2 (v1.1 후 2주)
9. **Cloud Functions IAP 영수증 서버 검증**
10. `users/{uid}/purchases/{pid}` — Cloud Functions만 write

### v1.3 (v1.2 후 2~3주)
11. 구독 모델 + 구독 전용 콘텐츠

## Firestore 데이터 모델

```
users/{uid}                    ← 단일 document
  theme: { seedColor, textColor, paletteId }
  idol: { groupName, memberName, selectedAt }
  locale: "ko"
  favorites: [ { phraseId, ko, en, savedAt }, ... ]
  backupVersion: 1
  lastSyncedAt: Timestamp

users/{uid}/purchases/{pid}    ← v1.2, Cloud Functions only
  productId, purchaseToken, verifiedAt, status
```

## Security Rules (v1.1)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    match /users/{uid}/purchases/{purchaseId} {
      allow read: if request.auth != null && request.auth.uid == uid;
      allow write: if false;  // Cloud Functions only
    }
  }
}
```

## 핵심 논거

- **10대 K-pop 팬에게 로그인 = 이탈 지점** → v1.0 익명 유지, v1.1 선택적 도입 (최덕팬)
- **"30분 세팅"은 환상** — 에지 케이스/테스트/오프라인 큐잉까지 1주일 (김프라)
- **Firestore 무료 티어 한계** — DAU 20K까지 단일 document로 커버 (한클라)
- **IAP 서버 검증은 Auth 직후** — purchases가 Firestore에 올라가기 전 검증 (이시큐)
- **JSON export/import가 Firestore 마이그레이션 브릿지** — 스키마 1:1 매핑 (한클라)

## Firestore 무료 티어 계산 (단일 document)

| DAU | 일일 reads | 일일 writes | 무료 한도 | 상태 |
|-----|-----------|------------|----------|------|
| 10K | 10K | 15K | 50K/20K | 여유 |
| 20K | 20K | 30K | 50K/20K | writes 초과 |
| 30K | 30K | 45K | 50K/20K | Blaze 필요 (~$5~10/월) |
