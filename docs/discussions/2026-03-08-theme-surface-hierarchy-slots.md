# 테마 Surface 계층 + 슬롯 UX 패널 토론 (2026-03-08)

## 결론

### 확정 사항
1. **scaffold 배경 = `surface`(seed tone 그대로)** — "내 색 = 배경색" 일치
2. **AppBar = `surfaceContainerLow`(tone+2)** — seed와 거의 동일
3. **card = `surfaceContainer`(tone+5)** — scaffold와 tone gap 5로 계층 분리
4. **tone spread 24→17로 축소** — 수동 팔레트(8~9톤 차이)와 정합
5. **슬롯 힌트 = 첫 저장 스낵바 1회 + Semantics onLongPressHint**

### 결정 근거
- 사용자가 선택한 색과 앱 배경이 일치해야 IAP ₩990 가치를 느낌
- 다르면 "속은 느낌" → 전환율 파괴
- tone+2는 JND 이하 우려 있으나, "내 색 충실도"가 이 앱의 핵심 가치

### Dark mode 오프셋 합의안
| 토큰 | tone | chroma |
|------|------|--------|
| surfaceContainerLowest | -4 | sc-3 |
| surfaceDim | -2 | sc-2 |
| surface | 0 | sc |
| surfaceContainerLow | +2 | sc |
| surfaceContainer | +5 | sc+2 |
| surfaceContainerHigh | +8 | sc+3 |
| surfaceContainerHighest | +11 | sc+4 |
| surfaceBright | +13 | sc+3 |

### FangeulTheme 매핑 변경
- scaffoldBackgroundColor: surfaceContainerLowest → surface
- appBarTheme.backgroundColor: surfaceContainerHigh → surfaceContainerLow
- cardTheme.color: surface → surfaceContainer

### 슬롯 UX
- 첫 저장 성공 시 스낵바 1회: "길게 눌러서 이름 변경·덮어쓰기 가능해요"
- Semantics.onLongPressHint: '테마 관리 메뉴 열기'

## 패널 구성
소연(UI/UX), Marcus(M3 시스템), 하나(접근성), Jake(수익화 PM), 민수(Flutter 개발)
