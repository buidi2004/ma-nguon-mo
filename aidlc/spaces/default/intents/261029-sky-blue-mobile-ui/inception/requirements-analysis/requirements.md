# Requirements Analysis

## Intent analysis

Add the supplied animated blue wave shader as the background for OpenFlix's mobile home screen while the existing light blue (`windowsBlue`) theme is selected. Preserve the current home screen content and place the waves behind it. The approved intent limits the change to the mobile home screen; other screens remain unchanged.

Sources: the project request in `project-description.json`; the approved scope in `aidlc/spaces/default/intents/261029-sky-blue-mobile-ui/ideation/intent-capture/intent-statement.md`; and the user-supplied `Văn bản đã dán.txt` Flutter shader/widget example.

## Functional requirements

### Mobile home background

- **FR1** When the home screen is open, the viewport is under 600 logical pixels wide, and `windowsBlue` is selected, the app shall render the supplied animated blue wave background behind the existing content.
  - **FR1.1** The app shall register `shaders/waves.frag` as a Flutter runtime shader asset.
  - **FR1.2** The app shall preserve existing home screen navigation, movie content, controls, and scrolling behavior above the background.
  - **FR1.3** While the shader loads or if it fails to load, the app shall keep the existing static light blue background and shall not show a blank screen or broken-asset indicator.
  - **FR1.4** The Netflix red theme and non-mobile layouts shall retain their current backgrounds.

### Readability and rendering

- **FR2** The blue-theme text colors, card surfaces, and visible control states shall remain legible above the animation; state shall not be conveyed by color alone.
- **FR3** Animation updates shall repaint the background layer without rebuilding the home screen's movie content.

## Non-functional requirements

- **NFR1** The shader shall load from a bundled local asset and shall add no network dependency.
- **NFR2** Shader load or compilation failure shall leave home screen content and interactions available on the static fallback background.
- **NFR3** The shader shall adapt to the available viewport size and remain clipped to the screen bounds.

## Constraints

- Flutter is the target framework. The supplied example uses a Flutter runtime effect and `shaders/waves.frag`.
- The change is limited to the existing mobile home screen in the existing light blue theme.
- The approved intent excludes changes to other screens.

## Assumptions

- The supplied palette, wave motion, and constants are the visual starting point; small compatibility or readability adjustments may be made while retaining its blue-wave appearance.
- The existing mobile breakpoint is under 600 logical pixels; current `HomeScreen` logic applies its light-blue styling at that breakpoint when `ThemeService` selects `windowsBlue`.
- Shader errors use the existing static `HomeScreenPalette.background` color as fallback.
- At the user's direction, no further preferences are requested; unspecified implementation details use these defaults.

## Out of scope

- Applying the animation to desktop/tablet layouts, screens other than home, or the Netflix red theme.
- Changing movie data, navigation, backend behavior, or the existing blue palette beyond readability needs for the new background.
- Adding settings for animation or shader parameters.

## Open questions

- None blocking. No older-device performance target was provided; keep shader work isolated and preserve the static fallback.

## Upstream context

- The approved intent statement defines the mobile-home-only scope and blue palette goal.
- `aidlc/spaces/default/codekb/aidlc-workflows/business-overview.md`, `architecture.md`, and `code-structure.md` describe workflow tooling, not the Flutter app.
- `aidlc/spaces/default/codekb/codegraph/business-overview.md`, `architecture.md`, and `code-structure.md` describe CodeGraph, not the Flutter app.
- `aidlc/spaces/default/codekb/fe-web/business-overview.md`, `architecture.md`, and `code-structure.md` describe a separate Next.js frontend, not the Flutter app.
- Flutter-specific context is in `lib/screens/home_screen.dart`, `lib/services/theme_service.dart`, and `lib/theme/app_theme.dart`; CodeGraph confirms the current `windowsBlue` and under-600-pixel condition.
