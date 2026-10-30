# Unit Test Instructions

## Planned coverage

The proposed Flutter widget coverage is `test/waves_background_test.dart`:

- Renders child content over a background after shader initialization.
- Keeps a static light-blue background visible while loading and after a shader load failure.
- Uses the animated background only for a viewport under 600 logical pixels with `windowsBlue` selected.
- Leaves the current red theme and larger viewport presentation unchanged.
- Verifies disposal does not leave a running ticker or shader resource.

These cases are planned; no test file was added and no test command was run during plan preparation.

## Runner and commands

- Runner: Flutter's existing `flutter_test` package.
- Test configuration: use the existing `pubspec.yaml` and `test/` setup; no configuration change is currently planned.
- Candidate focused command after implementation is authorized: `flutter test test/waves_background_test.dart`.
- Broader existing Flutter tests can be run in the later verification stage if authorized.

## Authorization and status

The user requested implementation but did not request adding or running tests. This file records the planned cases and command only. Test files and test execution remain pending explicit authorization; report them as not run in `code-summary.md`.
