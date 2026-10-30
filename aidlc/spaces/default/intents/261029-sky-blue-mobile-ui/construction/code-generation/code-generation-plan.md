# Code Generation Plan

## Scope

Implement the supplied animated blue wave as the background for the Flutter mobile home screen only while the existing `windowsBlue` theme is selected. Preserve current content, navigation, scrolling, desktop/tablet layouts, and the Netflix red theme. `HomeScreen` already uses the `< 600` logical-pixel breakpoint and the blue theme palette, so reuse that condition rather than introducing a second theme switch.

## Plan

- [ ] **S1 — Register the shader asset.** Add `shaders/waves.frag` to the existing `flutter.shaders` list in `pubspec.yaml`, preserving `ribbon_gradient.frag` and `silk.frag`. Add the user-supplied wave shader as `shaders/waves.frag`. Implements FR1.1, NFR1.
- [ ] **S2 — Add the reusable background widget.** Create `lib/waves_background.dart` based on the supplied `WavesBackground`, keeping shader uniform order aligned with the shader. Keep the static blue fallback when the shader is loading or fails; dispose the ticker, notifier, and shader; isolate paints with `RepaintBoundary`. Implements FR1.3, FR3, NFR2, NFR3.
- [ ] **S3 — Integrate on the mobile blue home screen.** Update `lib/screens/home_screen.dart` to place the background behind the existing home content only when its current `_isLightBlueHome` condition is true. Retain existing `HomeScreenPalette` text and surfaces; preserve all other branches unchanged. Implements FR1, FR1.2, FR1.4, FR2.
- [ ] **S4 — Add requirement-driven widget coverage.** Plan `test/waves_background_test.dart` cases for shader asset loading, static fallback, background layering/content retention, and the blue-mobile versus red/large-viewport gate. Test source is planned but is not being created or run in this planning pass.
- [ ] **S5 — Check test setup and document verification.** Confirm existing Flutter test configuration is sufficient; do not alter it unless the planned test cannot run with the existing setup. Record any tests not run and why in `code-summary.md`.
- [ ] **S6 — Generate traceability and summary.** Map FR1–FR3 and NFR1–NFR3 to the changed source and planned test coverage; summarize changed files and verification status.

## Impact and safeguards

- `home_screen.dart` has callers in `app_router.dart` and `main.dart`, plus existing tests for routing, authentication navigation, home search alignment, avatar behavior, UX audit, and visual captures. Preserve its public constructor and existing flows.
- Existing user changes are present throughout the working tree. Edit only the planned target files; do not restore, reset, or reformat unrelated files.
- Keep the shader asset registration additive. Do not replace the existing shader list.
- The shader is local; rendering must not depend on network availability. Shader load failure leaves the existing static blue background and content usable.

## Testing Contract

```json
{
  "version": 1,
  "methodology": "test-after",
  "source": "fallback",
  "ordering": "Implement each testable layer, then write and run that layer's tests.",
  "scope": "feature",
  "test_strategy": "standard",
  "project_type": "greenfield",
  "applicable_notes": [],
  "obligations": {
    "strategy": "standard",
    "strategy_volume": [
      "Five to eight tests per component.",
      "Unit tests plus integration tests for key boundaries.",
      "Add E2E, performance, or security tests when requirements demand them."
    ],
    "scope_floor": [
      "Meet an 80% line-coverage floor.",
      "Run the selected tests in CI before merge."
    ],
    "combination_rule": "Apply every selected-strategy obligation and every scope-floor obligation; neither replaces the other, and a targeted scope regression may add the narrowest necessary test type beyond the strategy default."
  },
  "plan_profile": {
    "methodology": "test-after",
    "runner_step": "Bootstrap the minimal test runner/configuration and record the exact unit-scoped command.",
    "runner_ready_before_first_test": true,
    "testable_layers": [
      "Data model / database behavior",
      "Repository / data access",
      "Business logic",
      "API / endpoint",
      "Frontend behavior"
    ],
    "steps": [
      "Project structure and production configuration skeleton.",
      "Bootstrap the minimal test runner/configuration and record the exact unit-scoped command.",
      "Data model / database behavior - implement.",
      "Data model / database behavior - write and run its tests after implementation.",
      "Repository / data access - implement.",
      "Repository / data access - write and run its tests after implementation.",
      "Business logic - implement.",
      "Business logic - write and run its tests after implementation.",
      "API / endpoint - implement.",
      "API / endpoint - write and run its tests after implementation.",
      "Frontend behavior - implement.",
      "Frontend behavior - write and run its tests after implementation.",
      "Environment/build configuration.",
      "Documentation and traceability."
    ]
  },
  "input_sha256": "sha256:c0a0cdf57a506bd1b08717ed973eab4fa8f69b237cec5b1a2afd148f79ac46dc",
  "contract_sha256": "sha256:515978fc2d58450f1d4c9f907a146c04d6cc6b475d20c75550972bdae21f7cdf"
}
```
