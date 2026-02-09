import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio _dio;
  final Logger _logger = Logger();

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    BaseOptions options = BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );

    _dio = Dio(options);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          _logger.i('Request: ${options.method} ${options.path}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          _logger
              .i('Response: ${response.statusCode} ${response.statusMessage}');
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (kDebugMode) {
          _logger.e('Error: ${e.message}');
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
}
