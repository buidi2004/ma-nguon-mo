# OpenFlix UX/UI standards — Netflix-inspired

This document establishes reusable rules, not a claim that OpenFlix is identical to Netflix. Use it as the acceptance criteria for each screen.

## 1. Visual foundation

- App background: `#141414`.
- Base card/surface: `#1E1E1E`; elevated controls: `#2A2A2A`; hover/pressed surface: `#333333`.
- Brand accent: `#E50914`. Reserve red for brand actions, selected progress, alerts, and small emphasis. Do not make every button red.
- Primary text: `#FFFFFF`; secondary text: `#B3B3B3`; low emphasis: `#808080`.
- Page horizontal padding: 16 px on phones; increase cautiously on tablets/desktop.
- Typical control height: 48 px; touch target should generally be at least 44 x 44 px.
- Card corner radius: 8 px; form controls 8 px; buttons about 4–6 px. Keep poster corner treatment consistent.
- Use a consistent spacing scale: 4, 8, 12, 16, 24, 32 px.

## 2. Buttons

- **Primary (white):** the most important screen action such as Play/Continue; white background, dark text.
- **Brand (red):** sign-in/sign-up or a carefully chosen brand CTA. Use only one strong red CTA in a local action group.
- **Secondary (dark gray):** Download, My List, Details, Cancel, or other secondary actions.
- **Ghost:** low-emphasis navigation or inline actions. Keep a visible focus state and sufficient touch target.
- **Destructive:** remove account/content or destructive settings; pair with a clear label and confirmation when the action is irreversible.
- Every async button must prevent repeat submission and show a loading state. Disabled state must look disabled and actually stop input.
- Prefer concise action labels: “Phát”, “Tiếp tục xem”, “Thêm vào danh sách”, “Thử lại”. Avoid vague labels such as “OK” when the actual action can be named.

## 3. Text, hierarchy, and content

- Screen title: generally 24–32 sp depending on layout; section title: 18–20 sp; item title: 13–16 sp; supporting text: 12–14 sp.
- Use `maxLines` and ellipsis for titles in cards; never allow a long title to stretch a horizontal rail.
- Metadata should be compact: year, maturity rating, quality, genre, and duration only where useful.
- Keep contrast strong enough to read. Do not use muted gray for essential instructions or button labels.

## 4. Movie cards and rails

- Portrait posters use a consistent 2:3 aspect ratio; landscape/video previews use 16:9.
- Always define loading and error placeholders. Do not show broken-image icons or make the layout jump while images load.
- Horizontal rails should have one clear section title and 8–16 px spacing between cards.
- Show progress only for continue-watching content. Do not add progress bars to every poster.
- Badges should be sparse and short. Avoid stacking multiple badges over faces or key artwork.
- For tap, open a detail screen; show Play/Continue as the primary action there when that is the expected journey.

## 5. Motion and interaction feedback

- Use brief transitions around 150–220 ms for hover/press/selection; motion should clarify the action, not delay it.
- Provide visible pressed/focused/selected/disabled states for buttons, navigation, and text fields.
- Do not rely on color alone for selected or error state; include icon, label, border, or helper text as appropriate.
- Confirm destructive operations. Preserve entered data when validation fails.
- During loading, retain layout size where possible to avoid content jumps. On errors, explain the issue in plain language and offer a useful retry or recovery action.

## 6. UX states required on data-driven screens

Every data-driven screen should have deliberate designs for:

1. Loading/skeleton state.
2. Success/content state.
3. Empty state with a helpful next step.
4. Error state with retry or return path.
5. Offline state when network dependency matters.
6. Disabled/permission state where actions are not available.

Never show a blank screen when a request fails. Do not show a success toast before the backend confirms success.

## 7. Navigation and accessibility

- Keep navigation labels, selected icon/color, app-bar behavior, and back behavior consistent.
- Back navigation must preserve context where expected (scroll position, selected tab, or previous search query).
- Provide tooltips/semantic labels for icon-only buttons. Do not use icon-only controls for destructive or unclear actions.
- Support text scaling without clipping essential buttons or form controls.
- Use at least 44 x 44 px for interactive targets where practical, and ensure keyboard/focus behavior on desktop/web.

## 8. Screen-level acceptance checklist

A screen passes only when all relevant items are verified in the running app:

- [ ] Uses shared tokens rather than arbitrary one-off colors.
- [ ] Uses shared components for buttons, inputs, posters, section headers, and status feedback where applicable.
- [ ] Has hierarchy, spacing, truncation, and scrolling checked at the target viewport.
- [ ] Has loading, empty, error, and disabled states where applicable.
- [ ] Primary action is visually obvious; secondary actions are visibly secondary.
- [ ] Tap targets, back behavior, and navigation journeys work.
- [ ] Images have proper aspect ratio and a fallback.
- [ ] Screenshot was captured and reviewed after changes.
- [ ] Relevant functional tests passed.

Do not mark a screen PASS from source inspection alone. If it was not run or screenshotted, report NOT RUN or BLOCKED.
