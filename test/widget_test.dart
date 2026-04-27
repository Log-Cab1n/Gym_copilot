import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:gym_copilot/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const GymCopilotApp());
    await tester.pump();

    // 验证应用能正常启动，MaterialApp 存在
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
