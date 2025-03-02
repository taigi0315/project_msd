// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:family_choi_app/main.dart';
import 'package:family_choi_app/screens/splash_screen.dart';
import 'package:family_choi_app/theme/app_theme.dart';

void main() {
  testWidgets('앱 시작 화면이 성공적으로 로드되는지 확인', (WidgetTester tester) async {
    // 앱을 빌드하고 프레임 트리거
    await tester.pumpWidget(const FamilyChoiApp());

    // 스플래시 화면이 로드되었는지 확인
    expect(find.byType(SplashScreen), findsOneWidget);
    
    // 앱 이름이 표시되는지 확인 (애니메이션에 따라 실패할 수 있음)
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Family Choi Chronicles'), findsOneWidget);
    
    // 로딩 인디케이터가 표시되는지 확인
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
  
  testWidgets('앱 테마가 올바르게 적용되는지 확인', (WidgetTester tester) async {
    // 앱을 빌드하고 프레임 트리거
    await tester.pumpWidget(const FamilyChoiApp());
    
    // 테마 색상이 올바르게 적용되었는지 확인
    final scaffoldWidget = find.byType(Scaffold).evaluate().first.widget as Scaffold;
    expect(scaffoldWidget.backgroundColor, equals(AppTheme.backgroundColor));
  });
}
