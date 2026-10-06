import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/login_user.dart';
import '../../services/auth_service.dart';

@immutable
class LoginCredentials {
  const LoginCredentials({required this.username, required this.password});

  final String username;
  final String password;
}

@immutable
class RegistrationCredentials {
  const RegistrationCredentials({
    required this.username,
    required this.password,
    required this.repeatedPassword,
  });

  final String username;
  final String password;
  final String repeatedPassword;
}

typedef LoginSubmitCallback = FutureOr<LoginUser?> Function(
  LoginCredentials credentials,
);
typedef RegisterSubmitCallback = FutureOr<LoginUser?> Function(
  RegistrationCredentials credentials,
);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.onSubmit, this.onRegister});

  /// 注入登录动作后，页面负责展示加载、成功和错误反馈。
  final LoginSubmitCallback? onSubmit;
  final RegisterSubmitCallback? onRegister;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _repeatPasswordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  bool _isRegisterMode = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _passwordFocusNode.dispose();
    _repeatPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isRegisterMode ? '注册' : '登录')),
      body: SafeArea(
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 32),
                Icon(
                  Icons.account_circle_outlined,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  _isRegisterMode ? '注册 WanAndroid' : '登录 WanAndroid',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _isRegisterMode ? '创建玩安卓账号，注册成功后会自动登录' : '输入玩安卓账号，登录状态会自动保存',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  key: const ValueKey('login-username-field'),
                  controller: _usernameController,
                  enabled: !_isSubmitting,
                  autofillHints: const [AutofillHints.username],
                  autocorrect: false,
                  enableSuggestions: false,
                  enableIMEPersonalizedLearning: false,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: '用户名',
                    hintText: '例如 MountainClimbers',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateUsername,
                  onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('login-password-field'),
                  controller: _passwordController,
                  enabled: !_isSubmitting,
                  focusNode: _passwordFocusNode,
                  autofillHints: const [AutofillHints.password],
                  autocorrect: false,
                  enableSuggestions: false,
                  enableIMEPersonalizedLearning: false,
                  obscureText: _obscurePassword,
                  textInputAction: _isRegisterMode
                      ? TextInputAction.next
                      : TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: '密码',
                    hintText: '至少 6 位',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      key: const ValueKey('login-password-visibility'),
                      tooltip: _obscurePassword ? '显示密码' : '隐藏密码',
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: _validatePassword,
                  onFieldSubmitted: (_) => _isRegisterMode
                      ? _repeatPasswordFocusNode.requestFocus()
                      : _submitIfAvailable(),
                ),
                if (_isRegisterMode) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const ValueKey('register-repeat-password-field'),
                    controller: _repeatPasswordController,
                    enabled: !_isSubmitting,
                    focusNode: _repeatPasswordFocusNode,
                    autofillHints: const [AutofillHints.newPassword],
                    autocorrect: false,
                    enableSuggestions: false,
                    enableIMEPersonalizedLearning: false,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: '确认密码',
                      hintText: '再次输入密码',
                      prefixIcon: Icon(Icons.lock_reset_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateRepeatedPassword,
                    onFieldSubmitted: (_) => _submitIfAvailable(),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  key: const ValueKey('login-submit-button'),
                  onPressed: _isSubmitting ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _isSubmitting
                        ? const SizedBox.square(
                            key: ValueKey('login-submit-progress'),
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isRegisterMode ? '注册并登录' : '登录'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  key: const ValueKey('auth-mode-switch'),
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _isRegisterMode = !_isRegisterMode;
                            _repeatPasswordController.clear();
                          });
                        },
                  child: Text(_isRegisterMode ? '已有账号，去登录' : '没有账号，去注册'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return '请输入用户名';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return '请输入密码';
    if (value.length < 6) return '密码至少需要 6 位';
    return null;
  }

  String? _validateRepeatedPassword(String? value) {
    if (value == null || value.isEmpty) return '请再次输入密码';
    if (value != _passwordController.text) return '两次输入的密码不一致';
    return null;
  }

  void _submitIfAvailable() {
    if (!_isSubmitting) _submit();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final action = _isRegisterMode
        ? widget.onRegister == null
              ? null
              : () => widget.onRegister!(
                  RegistrationCredentials(
                    username: username,
                    password: password,
                    repeatedPassword: _repeatPasswordController.text,
                  ),
                )
        : widget.onSubmit == null
        ? null
        : () => widget.onSubmit!(
            LoginCredentials(username: username, password: password),
          );
    if (action == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('表单校验通过')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final user = await action();
      if (!mounted || user == null) return;
      TextInput.finishAutofillContext();
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop(user);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('登录成功：${user.displayName}')));
      }
    } on AuthException catch (error) {
      if (mounted) _showError(error.message);
    } catch (_) {
      if (mounted) {
        _showError(_isRegisterMode ? '注册失败，请稍后重试' : '登录失败，请稍后重试');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
