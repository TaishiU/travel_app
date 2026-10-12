# Result Type

`lib/utils/result.dart` の `Result<T>` を使用。

```dart
// 成功
return const SuccessResult(value);
// 失敗
return FailureResult(error);

// 利用側
switch (result) {
  case SuccessResult<T>(): // result.value
  case FailureResult<T>(): // result.error
}
```
