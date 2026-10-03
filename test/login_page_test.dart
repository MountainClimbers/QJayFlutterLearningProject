import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qjay_flutter_learning/features/auth/login_page.dart';

void main() {
  testWidgets('登录页面展示用户名、密码和提交按钮', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('登录'), findsWidgets);
    expect(find.byKey(const ValueKey('login-username-field')), findsOneWidget);
    expect(find.byKey(const ValueKey('login-password-field')), findsOneWidget);
    expect(find.byKey(const ValueKey('login-submit-button')), findsOneWidget);
  });

  testWidgets('空表单提交时显示用户名和密码错误', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.tap(find.byKey(const ValueKey('login-submit-button')));
    await tester.pump();

    expect(find.text('请输入用户名'), findsOneWidget);
    expect(find.text('请输入密码'), findsOneWidget);
  });

  testWidgets('密码少于六位时阻止提交', (tester) async {
    LoginCredentials? submittedCredentials;
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          onSubmit: (credentials) => submittedCredentials = credentials,
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('login-username-field')),
      'MountainClimbers',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password-field')),
      '12345',
    );
    await tester.tap(find.byKey(const ValueKey('login-submit-button')));
    await tester.pump();

    expect(find.text('密码至少需要 6 位'), findsOneWidget);
    expect(submittedCredentials, isNull);
  });

  testWidgets('有效表单提交去除首尾空格后的用户名和原密码', (tester) async {
    LoginCredentials? submittedCredentials;
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          onSubmit: (credentials) => submittedCredentials = credentials,
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('login-username-field')),
      '  MountainClimbers  ',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password-field')),
      '123456',
    );
    await tester.tap(find.byKey(const ValueKey('login-submit-button')));
    await tester.pump();

    expect(submittedCredentials?.username, 'MountainClimbers');
    expect(submittedCredentials?.password, '123456');
    expect(find.text('请输入用户名'), findsNothing);
    expect(find.text('请输入密码'), findsNothing);
  });

  testWidgets('密码默认隐藏并可以切换显示状态', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    EditableText passwordField() => tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const ValueKey('login-password-field')),
        matching: find.byType(EditableText),
      ),
    );

    expect(passwordField().obscureText, isTrue);
    expect(find.byTooltip('显示密码'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('login-password-visibility')));
    await tester.pump();

    expect(passwordField().obscureText, isFalse);
    expect(find.byTooltip('隐藏密码'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('login-password-visibility')));
    await tester.pump();

    expect(passwordField().obscureText, isTrue);
  });

  testWidgets('键盘下一项移动焦点并通过完成操作提交表单', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    final usernameFinder = find.byKey(
      const ValueKey('login-username-field'),
    );
    final passwordFinder = find.byKey(
      const ValueKey('login-password-field'),
    );

    await tester.enterText(usernameFinder, 'MountainClimbers');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();

    final passwordEditor = tester.widget<EditableText>(
      find.descendant(of: passwordFinder, matching: find.byType(EditableText)),
    );
    expect(passwordEditor.focusNode.hasFocus, isTrue);

    await tester.enterText(passwordFinder, '123456');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('表单校验通过，第 4 天接入登录接口'), findsOneWidget);
  });
}
