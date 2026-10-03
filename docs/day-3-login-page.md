# 第 3 天：登录页面

今天完成本地登录表单，重点学习 `Form`、输入校验、密码框、焦点管理和路由入口。登录接口、Cookie 与全局登录状态留到第 4 天。

## 完成的功能

- 从文章列表右上角进入独立登录页。
- 用户名和密码为空时显示对应错误。
- 密码少于 6 位时阻止提交。
- 密码默认隐藏，可以切换显示和隐藏。
- 凭证输入关闭键盘纠错、建议和个性化学习。
- 用户名按键盘“下一项”后自动聚焦密码框。
- 密码按键盘“完成”后执行表单校验。
- 表单有效时生成只读的 `LoginCredentials`。

## 推荐阅读顺序

1. `lib/features/auth/login_page.dart`：查看页面状态、控制器、焦点和表单校验。
2. `test/login_page_test.dart`：查看空值、密码长度、显隐和键盘提交测试。
3. `lib/features/articles/article_list_page.dart`：查看登录按钮和 `Navigator.push`。
4. `test/article_list_page_test.dart`：查看如何注入测试登录页并验证导航。

## 表单提交流程

```text
点击登录或键盘完成
  → FormState.validate()
  → 每个 TextFormField.validator
  → 校验失败：显示字段错误
  → 校验成功：创建 LoginCredentials
  → 调用 onSubmit
```

## 为什么使用 StatefulWidget

登录页需要持有 `TextEditingController`、`FocusNode` 和密码显隐状态。这些对象与页面生命周期绑定，因此页面销毁时必须在 `dispose` 中释放。网络登录状态会在第 4 天交给 Riverpod 管理。

## 为什么不在第 3 天请求接口

把表单和网络请求分开，可以先确定输入、校验和交互是否正确。第 4 天只需把 `onSubmit` 接到登录控制器，不需要重写表单页面。

## 自己动手复习

1. 给用户名增加最大长度限制，并补充对应测试。
2. 在登录按钮旁增加“清空”按钮，练习控制器操作。
3. 尝试说明 `TextEditingController` 和 Riverpod 分别适合管理什么状态。

## 验证命令

```bash
flutter test
flutter analyze
flutter build ios --simulator --no-codesign
```
