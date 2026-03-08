# Theme Picker UX Redesign Discussion

> Date: 2026-03-07
> Context: flex_color_scheme research + user feedback on custom picker UX

## Current Problems

### 1. HSL Color Space Limitations
- HSL is NOT perceptually uniform: same S=0.55 looks completely different for yellow vs blue
- At L=0.12 (dark surface), saturation changes are imperceptible (Weber-Fechner)
- `CustomSchemeBuilder` uses HSL with manual saturation multipliers (0.45~0.75x)
- Alternative: HCT/CAM16 (used by Material 3, flex_seed_scheme) is perceptually uniform

### 2. Slider UX Issues
- 3 sliders: Hue, Saturation, Lightness
- Saturation 0 = grey, Lightness 0/1 = black/white -> useless extremes
- No range limiting -> users can create unusable colors
- User feedback: "밝기나 채도를 맨 앞쪽이나 끝쪽으로 게이지 조절해버리면 아예 색이 달라져버리는데"

### 3. Text Color Limitations
- Only: auto-contrast + 6 preset colors (white, cream, light gray, sky, lavender, mint)
- No free color picker for text
- Light mode: selecting bright text color -> red "low contrast" warning chip appears (confusing UX)

### 4. Picker Type
- Current: linear hue gradient bar + separate sat/lightness sliders
- User request: color wheel (like Photoshop) for more intuitive selection
- Reference: `flutter_colorpicker`, `flex_color_picker` packages

## flex_color_scheme Research Summary

- **52 built-in themes** (all free), not 10
- **flex_seed_scheme**: HCT-based seed generation, perceptually uniform
- **FlexTones presets**: material, vivid, vividSurfaces, candyPop, highContrast, etc.
- **Surface blending**: `surfaceMode` + `blendLevel` for systematic dark mode tinting
- **Performance**: zero runtime overhead, ~2 deps (pure Dart)
- **Flutter 3.41.2**: fully compatible, 160/160 pub points, Flutter Favorite
- **Dark mode quality**: not a package issue — the "ugly dark" is M3 defaults. Package provides tools to fix it (vividSurfaces, blendLevel)

### Migration Strategy Options
- A) Full flex_color_scheme adoption (high migration cost, changes PaletteRegistry)
- B) flex_seed_scheme only — replace CustomSchemeBuilder HSL engine with HCT, keep PaletteRegistry
- C) Keep current approach, just fix UX (range limiting, color wheel)

## User Stance
- "HSL의 근본적 문제를 해결해서 퀄리티를 높인다면, 사용자들의 반응은 정말 좋을꺼야. 안할 이유가 없어"
- "아직 MVP 나간적도 없고 claude code 쓰는데 생산성,테스트? 이런 기간 신경쓰지마"
- Dark/light mode = Android OS base, palette colors on top = correct approach
- Fans estimated 80%+ dark mode usage (OLED devices, concert/night usage)

## Expert Panel Discussion Results (6-member panel)

### Panel Members
| # | Name | Role | Priority | Style |
|---|------|------|----------|-------|
| 1 | Min Seoyeong | Color Science Engineer (HCT/CAM16) | Perceptual uniformity > Implementation ease | "Eyes see colors, not numbers" |
| 2 | Park Jinwoo | Mobile UX Designer | Intuitiveness > Feature count | "If users can't understand in 3 seconds, it's a failure" |
| 3 | Lee Haneul | Flutter Performance Engineer | Stability > Perfection | "Working code beats beautiful code" |
| 4 | Kim Soyul | K-pop Fandom PM | Fan emotion > Technical accuracy | "Fans won't use it if it's not their color" |
| 5 | Jang Hyunsu | IAP Monetization Strategist | Conversion > Feature depth | "Free trials create purchases" |
| 6 | Choi Doyun | Accessibility/WCAG Consultant (skeptic) | Readability > Aesthetics | "Pretty but unreadable is meaningless" |

### Topic 1: HSL to HCT Engine Replacement
**Consensus:** HCT objectively superior (unanimous). MVP pre-launch = optimal timing for replacement.
- flex_seed_scheme's HCT Tone difference >= 40 is structurally safer than manual HSL correction
- Existing 6-hue WCAG golden tests MUST be re-verified after replacement
- FlexTones presets (candyPop, vivid) need individual WCAG contrast validation

### Topic 2: Slider UX (Remove vs Range-limit vs Color Wheel)
**Consensus:** Remove Sat/Lightness sliders -> Hue-only + engine auto-determines optimal values.
- Color wheel deferred to Post-MVP (accessibility concerns: color blindness 8% males, precision touch)
- Extreme values (black/white/grey) must be eliminated
- WCAG 4.5:1 contrast enforcement at engine level, not picker level
- IAP differentiation via preset packs, NOT by making picker UX inconvenient

### Topic 3: Free Text Color Picker
**Consensus:** Free picker allowed + auto-recommendation 3-5 colors (complementary, not replacement).
- 6 presets insufficient (unanimous)
- Warning-only approach (no blocking) — "fan identity infrastructure" UVP requires choice freedom
- Auto-correction opt-in as safety net
- QA risk: free color propagates to 6+ tokens (onSurface, onSurfaceVariant, appBar, etc.)

### Topic 4: PaletteRegistry 10 vs flex_color_scheme 52
**Consensus:** flex_color_scheme full adoption REJECTED (unanimous). PaletteRegistry maintained + expanded.
- Expand to 20-25 palettes (warm/cool tone balance, Southeast Asian market coverage)
- K-pop emotional naming ownership is brand asset ("concert_encore" > "Material Blue")
- flex seed colors can be referenced for new palettes, but names/stories stay ours
- Scarcity (curated list) = perceived value. 52 dump = "why buy?" psychology
- Season-limited drip release > bulk dump for retention

### Supplementary: flex_seed_scheme vs Self-implementation
**Consensus:** flex_seed_scheme adopted.
- Effective new dependencies = ZERO (material_color_utilities + collection already in Flutter SDK)
- FlexTones manages cascading slot contrast ratios (surface -> onSurface -> outline chain) via tone tables
- 20-line self-implementation looks simple NOW but tone mapping complexity grows with color pack SKUs
- highContrast FlexTones immediately usable for accessibility mode

### Final Decisions

| Layer | Decision | Rationale |
|-------|----------|-----------|
| Color Engine | `flex_seed_scheme` (HCT) | Perceptually uniform, cascading slot management, zero effective deps |
| Theme Structure | `FangeulTheme` + `PaletteRegistry` keep | Full control, brand ownership |
| Palettes | Expand to 20-25 (K-pop emotional) | Scarcity + warm/cool balance |
| Picker UX (MVP) | Hue-only, engine auto-determines sat/light | Eliminate useless extremes |
| Picker UX (Post-MVP) | Color wheel consideration | Pending accessibility solution |
| Text Color | Free picker + auto-recommend 3-5 | Fan identity + readability |
| Full Package | `flex_color_scheme` REJECTED | Flexibility/branding loss |

### Action Items (Priority Order)

| # | Task | Priority |
|---|------|----------|
| 1 | `flex_seed_scheme` + `CustomSchemeBuilder` HCT replacement | P0 |
| 2 | Remove Sat/Lightness sliders -> Hue-only + engine auto | P0 |
| 3 | Free text color picker + auto-recommend 3-5 colors | P1 |
| 4 | PaletteRegistry expand to 20-25 (warm/cool balance) | P1 |
| 5 | WCAG auto-correction opt-in | P1 |
| 6 | Color wheel picker (Post-MVP) | P2 |

### Required Test Cases
1. 6 major hue x dark/light WCAG 4.5:1 golden tests (re-verify after HCT)
2. Hue-only picker: all hues produce visibly tinted dark surfaces (improvement over HSL)
3. Free text color + contrast < 4.5:1 -> warning shown + auto-recommend colors displayed
4. All 25 palettes dark/light rendering + screenshot comparison
