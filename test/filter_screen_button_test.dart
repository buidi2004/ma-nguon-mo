import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:openflix/features/discover/filter_screen.dart';
import 'package:openflix/services/theme_service.dart';
import 'package:openflix/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets('FilterScreen tap Áp dụng bộ lọc default route', (tester) async {
    final router = GoRouter(
      initialLocation: '/filter',
      routes: [
        GoRoute(
          path: '/filter',
          builder: (context, state) => const FilterScreen(),
        ),
        GoRoute(
          path: '/genre/:name',
          builder: (context, state) => Scaffold(
            body: Text('Genre: ${state.pathParameters['name']}'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      theme: buildAppTheme(),
    ));
    await tester.pumpAndSettle();

    final applyBtn = find.text('Áp dụng bộ lọc');
    expect(applyBtn, findsOneWidget);

    await tester.tap(applyBtn);
    await tester.pumpAndSettle();

    expect(find.text('Genre: Tất cả'), findsOneWidget);
  });

  testWidgets('FilterScreen selects category, year, sort and applies query params', (
    tester,
  ) async {
    String? capturedPath;
    String? capturedYear;
    String? capturedSort;

    final router = GoRouter(
      initialLocation: '/filter',
      routes: [
        GoRoute(
          path: '/filter',
          builder: (context, state) => const FilterScreen(),
        ),
        GoRoute(
          path: '/genre/:name',
          builder: (context, state) {
            capturedPath = state.pathParameters['name'];
            capturedYear = state.uri.queryParameters['year'];
            capturedSort = state.uri.queryParameters['sort'];
            return Scaffold(
              body: Text('Loaded: $capturedPath, year=$capturedYear, sort=$capturedSort'),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      theme: buildAppTheme(),
    ));
    await tester.pumpAndSettle();

    // Select category 'Hành động'
    await tester.tap(find.text('Hành động'));
    await tester.pumpAndSettle();

    // Select year '2024'
    await tester.tap(find.text('2024'));
    await tester.pumpAndSettle();

    // Select sort 'Xem nhiều nhất'
    await tester.tap(find.text('Xem nhiều nhất'));
    await tester.pumpAndSettle();

    // Tap 'Áp dụng bộ lọc'
    final applyBtn = find.text('Áp dụng bộ lọc');
    expect(applyBtn, findsOneWidget);
    await tester.tap(applyBtn);
    await tester.pumpAndSettle();

    expect(capturedPath, 'Hành động');
    expect(capturedYear, '2024');
    expect(capturedSort, 'Xem nhiều nhất');
    expect(find.text('Loaded: Hành động, year=2024, sort=Xem nhiều nhất'), findsOneWidget);
  });

  testWidgets('FilterScreen reset button restores default selections', (
    tester,
  ) async {
    String? capturedPath;

    final router = GoRouter(
      initialLocation: '/filter',
      routes: [
        GoRoute(
          path: '/filter',
          builder: (context, state) => const FilterScreen(),
        ),
        GoRoute(
          path: '/genre/:name',
          builder: (context, state) {
            capturedPath = state.pathParameters['name'];
            return Scaffold(
              body: Text('Loaded: $capturedPath'),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      theme: buildAppTheme(),
    ));
    await tester.pumpAndSettle();

    // Select 'Hoạt hình'
    await tester.tap(find.text('Hoạt hình'));
    await tester.pumpAndSettle();

    // Tap reset 'Đặt lại'
    await tester.tap(find.text('Đặt lại'));
    await tester.pumpAndSettle();

    // Tap 'Áp dụng bộ lọc'
    await tester.tap(find.text('Áp dụng bộ lọc'));
    await tester.pumpAndSettle();

    expect(capturedPath, 'Tất cả');
  });

  testWidgets('FilterScreen supports Windows Blue mode transparent background', (
    tester,
  ) async {
    await ThemeService.instance.setThemeMode(AppThemeMode.windowsBlue);

    final router = GoRouter(
      initialLocation: '/filter',
      routes: [
        GoRoute(
          path: '/filter',
          builder: (context, state) => const FilterScreen(),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      theme: buildAppTheme(),
    ));
    await tester.pumpAndSettle();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, Colors.transparent);

    await ThemeService.instance.setThemeMode(AppThemeMode.netflixRed);
  });
}
