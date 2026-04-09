# Play Console — 포그라운드 서비스 권한 신고

## 작업 유형

기타 (Other)

## 설명 텍스트 (복사용)

Fangeul provides a floating bubble overlay that gives users quick access to a Korean (Hangul) keyboard and English↔Korean text converter while using other apps. The foreground service is required to keep the bubble visible on top of other applications (e.g., messaging apps, social media). The service must start immediately when the user activates the bubble and cannot be paused or deferred, because the bubble must remain responsive and visible at all times while the user is typing in other apps. Without a foreground service, Android would kill the overlay process in the background, making the bubble disappear unexpectedly. The service stops completely when the user dismisses the bubble.

## 동영상 촬영 가이드

1. Fangeul 앱 열기 → 버블 켜기
2. 홈으로 나가기 → 버블이 화면에 떠있는 것 보여주기
3. 카카오톡/인스타 등 다른 앱 열기 → 버블 탭 → 한글 변환 사용
4. 버블 닫기

YouTube 일부 공개(Unlisted)로 업로드 → 링크 제출

## 개발자 페이지 광고 문구 (복사용, 140자 이내)

### en-US

Korean tools built for K-pop fans — type Hangul, convert English to Korean, check pronunciation, and copy fan phrases instantly.

### ko

K-pop 팬을 위한 한국어 도구 — 한글 타이핑, 영한 변환, 발음 확인, 팬 문구 복사를 한 앱에서.

### es

Herramientas de coreano para fans de K-pop — escribe en Hangul, convierte inglés a coreano, verifica pronunciación y copia frases de fans.

### pt-BR

Ferramentas de coreano para fãs de K-pop — digite em Hangul, converta inglês para coreano, confira pronúncia e copie frases de fãs.

### id

Alat bahasa Korea untuk fans K-pop — ketik Hangul, konversi Inggris ke Korea, cek pelafalan, dan salin frasa fans.

### th

เครื่องมือภาษาเกาหลีสำหรับแฟน K-pop — พิมพ์ฮันกึล แปลงอังกฤษเป็นเกาหลี เช็คการออกเสียง และคัดลอกวลีแฟน

### vi

Công cụ tiếng Hàn cho fan K-pop — gõ Hangul, chuyển đổi Anh-Hàn, kiểm tra phát âm và sao chép câu nói fan.

### ja

K-popファンのための韓国語ツール — ハングル入力、英韓変換、発音確認、ファンフレーズのコピーをひとつのアプリで。

---

## YouTube 업로드 정보 (복사용)

### 제목

Fangeul - Foreground Service Demo (Floating Bubble)

### 설명

Demonstration of FOREGROUND_SERVICE_SPECIAL_USE permission usage in Fangeul app. The floating bubble overlay provides Korean keyboard and text conversion tools on top of other apps.
