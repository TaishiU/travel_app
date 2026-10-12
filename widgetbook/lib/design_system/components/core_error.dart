import 'package:travel_app/data/services/web_api/api_exception.dart';
import 'package:travel_app/design_system/components/core_error.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/utils/base_scaffold.dart';

@widgetbook.UseCase(name: 'Default', type: CoreError)
Widget buildCoreErrorUseCase(BuildContext context) {
  final error = context.knobs.object.dropdown<Object>(
    label: 'Error Type',
    options: [
      NoInternetConnectionException(message: 'No Internet'),
      BadRequestException(message: 'Bad Request (400)'),
      UnauthorizedException(message: 'Unauthorized (401)'),
      ForbiddenException(message: 'Forbidden (403)'),
      NotFoundException(message: 'Not Found (404)'),
      MethodNotAllowedException(message: 'Method Not Allowed (405)'),
      InternalServerErrorException(message: 'Internal Server Error (500)'),
      UnknownErrorException(message: 'Unknown Error'),
      ApiClientException(message: 'Custom API Exception', statusCode: 418),
      FormatException('Unexpected Format Error'),
    ],
    labelBuilder: (error) {
      if (error is ApiClientException) {
        return '${error.runtimeType}(${error.statusCode ?? "no status"})';
      }
      return error.runtimeType.toString();
    },
  );

  return BaseScaffold(
    title: 'CoreError',
    body: CoreError(
      error: error,
      onPressed: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('再読み込みボタンが押されました')));
      },
    ),
  );
}
