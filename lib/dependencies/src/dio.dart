import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:universally/universally.dart';

/// 扩展所有的 header
typedef ValueCallbackHeader = Map<String, String>? Function(String url);

/// 扩展所有的 params
typedef ValueCallbackParams = Map<String, dynamic>? Function(
    String url, Map<String, dynamic>? params);

/// 扩展所有的 data
typedef ValueCallbackData<T> = T Function(String url, T params);

typedef ValueCallbackError = bool Function();

class InterceptorError {
  InterceptorError(this.errorCode, this.callback);

  late String errorCode;

  /// 返回 false 不继续后面的解析操作
  /// 返回 true 继续执行后面的解析操作
  late ValueCallbackError callback;
}

typedef BasicDioErrorIntercept = List<InterceptorError> Function(
    String url, dynamic tag);

class BasicDioOptions extends ExtendedDioOptions {
  BasicDioOptions({
    /// 接收超时时间
    int receiveTimeout = 5000,

    /// 连接超时时间
    int connectTimeout = 5000,

    /// 发送超时时间
    int sendTimeout = 5000,
    bool logTs = false,
    this.downloadResponseType = ResponseType.bytes,
    this.downloadContentType,
    this.uploadContentType,
    this.extraHeader,
    this.extraData,
    this.extraParams,
    this.errorIntercept,
    this.forbidPrintUrl = const [],
    String? method,
    String baseUrl = '',
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? extra,
    Map<String, dynamic>? headers,
    ResponseType responseType = ResponseType.json,
    String? contentType,
    ValidateStatus? validateStatus,
    bool? receiveDataWhenStatusError,
    bool? followRedirects,
    int? maxRedirects,
    RequestEncoder? requestEncoder,
    ResponseDecoder? responseDecoder,
    ListFormat? listFormat,
    bool setRequestContentTypeWhenNoPayload = false,
    this.codeKeys = const ['code', 'status', 'statusCode', 'errcode'],
    this.msgKeys = const ['msg', 'errorMessage', 'statusMessage', 'errmsg'],
    this.dataKeys = const ['data', 'result'],
    this.expandKeys = const ['expand'],
    this.hideMsg = const ['success', 'OK'],
    this.successCode = const ['200'],
  }) : super(
            logTs: logTs,
            receiveTimeout: receiveTimeout,
            connectTimeout: connectTimeout,
            sendTimeout: sendTimeout,
            method: method,
            extra: extra,
            baseUrl: baseUrl,
            setRequestContentTypeWhenNoPayload:
                setRequestContentTypeWhenNoPayload,
            queryParameters: queryParameters,
            headers: headers,
            responseType: responseType,
            contentType: contentType,
            validateStatus: validateStatus,
            receiveDataWhenStatusError: receiveDataWhenStatusError,
            followRedirects: followRedirects,
            maxRedirects: maxRedirects,
            requestEncoder: requestEncoder,
            responseDecoder: responseDecoder,
            listFormat: listFormat) {
    downloadContentType ??= httpContentType[1];
    uploadContentType ??= httpContentType[1];
  }

  /// header设置
  ValueCallbackHeader? extraHeader;

  /// 扩展所有的 data 参数
  ValueCallbackData? extraData;

  /// 扩展所有的 params
  ValueCallbackParams? extraParams;

  /// 错误拦截;
  BasicDioErrorIntercept? errorIntercept;

  /// 不打印 返回 data 的url
  List<String> forbidPrintUrl;

  /// 下载的ContentType;
  String? downloadContentType;

  /// 下载文件时的请求类型
  ResponseType downloadResponseType;

  /// 上传的Type
  String? uploadContentType;

  /// BasicModel 后台返回状态码
  List<String> codeKeys;

  /// BasicModel 后台返回message
  List<String> msgKeys;

  /// BasicModel 后台返回具体数据
  List<String> dataKeys;

  /// BasicModel 后台返回扩展数据
  List<String> expandKeys;

  /// 后台返回成功的状态码
  /// 主要用于 网络请求返回 判断方法[resultSuccessFail]
  List<String> successCode;

  /// 后台返回 message 隐藏 toast
  /// 主要用于 网络请求返回 判断方法[resultSuccessFail]
  List<String> hideMsg;
}

class BasicDio {
  factory BasicDio() => _singleton ??= BasicDio._();

  BasicDio._();

  static BasicDio? _singleton;

  late ExtendedDio dio;

  bool hasLoading = false;

  BasicDioOptions basicDioOptions = BasicDioOptions();

  BasicDio initialize([BasicDioOptions? options]) {
    if (options != null) basicDioOptions = options;
    if (basicDioOptions.logTs == false) basicDioOptions.logTs = hasLogTs;
    basicDioOptions.interceptors = isRelease
        ? basicDioOptions.interceptors
        : [
            ...basicDioOptions.interceptors,
            LoggerInterceptor<dynamic>(
                forbidPrintUrl: basicDioOptions.forbidPrintUrl)
          ];
    dio = ExtendedDio().initialize(options: basicDioOptions);
    return this;
  }

  Future<BasicModel> get(
    String url, {
    dynamic tag,
    Map<String, dynamic>? params,
    bool loading = true,
    Options? options,
  }) async {
    assert(_singleton != null, '请先调用 initialize');
    if (hasNetWork) return notNetWorkModel;
    _addLoading(loading);
    final ResponseModel res = await dio.get(url,
        options: _initBasicOptions(options, url),
        params: basicDioOptions.extraParams?.call(url, params) ?? params);
    return _response(res, tag);
  }

  Future<BasicModel> post(String url,
      {Map<String, dynamic>? params,
      dynamic data,
      bool dataToJson = true,
      dynamic tag,
      bool loading = true,
      Options? options,
      ProgressCallback? onSendProgress}) async {
    assert(_singleton != null, '请先调用 initialize');
    if (hasNetWork) return notNetWorkModel;
    _addLoading(loading);
    final ResponseModel res = await dio.post(url,
        options: _initBasicOptions(options, url),
        params: basicDioOptions.extraParams?.call(url, params) ?? params,
        data: dataToJson
            ? jsonEncode(basicDioOptions.extraData?.call(url, data) ?? data)
            : data);
    return _response(res, tag);
  }

  Future<BasicModel> put(
    String url, {
    Map<String, dynamic>? params,
    dynamic data,
    dynamic tag,
    bool loading = true,
    bool dataToJson = true,
    Options? options,
  }) async {
    assert(_singleton != null, '请先调用 initialize');
    if (hasNetWork) return notNetWorkModel;
    _addLoading(loading);
    final ResponseModel res = await dio.put(url,
        options: _initBasicOptions(options, url),
        params: basicDioOptions.extraParams?.call(url, params) ?? params,
        data: dataToJson
            ? jsonEncode(basicDioOptions.extraData?.call(url, data) ?? data)
            : data);
    return _response(res, tag);
  }

  Future<BasicModel> delete(
    String url, {
    Map<String, dynamic>? params,
    dynamic data,
    dynamic tag,
    bool loading = true,
    bool dataToJson = true,
    Options? options,
  }) async {
    assert(_singleton != null, '请先调用 initialize');
    if (hasNetWork) return notNetWorkModel;
    _addLoading(loading);
    var extraData = basicDioOptions.extraData?.call(url, data) ?? data;
    final ResponseModel res = await dio.delete(url,
        options: _initBasicOptions(options, url),
        params: basicDioOptions.extraParams?.call(url, params) ?? params,
        data: dataToJson ? jsonEncode(extraData) : extraData);
    return _response(res, tag);
  }

  /// 文件上传
  /// File upload
  Future<BasicModel> upload(
    String url,
    dynamic data, {
    ProgressCallback? onSendProgress,
    bool loading = true,
    Options? options,
    dynamic tag,
    CancelToken? cancelToken,
  }) async {
    assert(_singleton != null, '请先调用 initialize');
    if (hasNetWork) return notNetWorkModel;
    _addLoading(loading);
    final ResponseModel res = await dio.post(url,
        data: basicDioOptions.extraData?.call(url, data) ?? data,
        options:
            _initBasicOptions(options, url).copyWith(receiveTimeout: 30000),
        onSendProgress: onSendProgress);
    return _response(res, tag);
  }

  /// 文件下载
  /// File download
  Future<BasicModel> download(
    String url,
    String savePath, {
    bool loading = true,
    dynamic tag,
    Options? options,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    dynamic data,
    bool dataToJson = true,
    Map<String, dynamic>? params,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
  }) async {
    assert(_singleton != null, '请先调用 initialize');
    if (hasNetWork) return notNetWorkModel;
    _addLoading(loading);
    final ResponseModel res = await dio.download(url, savePath,
        onReceiveProgress: onReceiveProgress,
        options: _initBasicOptions(options, url),
        data: dataToJson
            ? jsonEncode(basicDioOptions.extraData?.call(url, data) ?? data)
            : data,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        cancelToken: cancelToken);
    return _response(res, tag);
  }

  void _addLoading(bool? loading) {
    hasLoading = loading ?? false;
    if (hasLoading) showLoading();
  }

  Future<void> _removeLoading() async {
    await 200.milliseconds.delayed(() {});
    if (hasLoading) {
      closeLoading();
    }
  }

  bool get hasNetWork {
    var network = GlobalConfig().hasNetwork ?? true;
    if (!network) {
      _removeLoading();
      1.seconds.delayed(_sendRefreshStatus);
    }
    return !network;
  }

  BasicModel get notNetWorkModel =>
      BasicModel(data: null, code: '500', msg: '无法连接服务器');

  void _sendRefreshStatus() {
    if (pullDown) {
      pullDown = false;
      sendRefreshType(EasyRefreshType.refreshSuccess);
    }
    if (pullUp) {
      pullUp = false;
      sendRefreshType(EasyRefreshType.loadingSuccess);
    }
  }

  Options _initBasicOptions(Options? options, String url) {
    options ??= Options();
    final Map<String, dynamic> headers = <String, dynamic>{};
    if (basicDioOptions.extraHeader != null) {
      final extraHeader = basicDioOptions.extraHeader!(url);
      if (extraHeader != null) headers.addAll(extraHeader);
    }
    options.headers = headers;
    return options;
  }

  BasicModel _response(ResponseModel res, dynamic tag) {
    _removeLoading();
    _sendRefreshStatus();
    BasicModel baseModel = BasicModel(
        code: '${res.statusCode}',
        msg: notNetWorkModel.msg,
        statusCode: res.statusCode,
        statusMessage: res.statusMessage,
        data: res.data,
        original: res);
    dynamic data = baseModel.data;
    if (data is ResponseBody) {
      return baseModel = BasicModel(
          code: '${data.statusCode}',
          msg: data.statusMessage ?? notNetWorkModel.msg,
          statusCode: data.statusCode,
          statusMessage: data.statusMessage,
          data: 'This is response stream',
          original: res);
    } else if (data != null && data is String && data.contains('"')) {
      try {
        data = jsonDecode(data);
      } catch (e) {
        debugPrint('$e');
      }
      baseModel = BasicModel.fromJson(data, res);
    } else if (data is Map) {
      baseModel = BasicModel.fromJson(data as Map<String, dynamic>?, res);
    }
    var errorIntercepts =
        basicDioOptions.errorIntercept?.call(res.realUri.toString(), tag);
    if (errorIntercepts?.isNotEmpty ?? false) {
      bool pass = true;
      for (var element in errorIntercepts!) {
        if (baseModel.code == element.errorCode) {
          pass = element.callback();
          if (!pass) break;
        }
      }
      if (!pass) return baseModel;
    }
    return baseModel;
  }
}

/// 基础解析数据model
class BasicModel {
  BasicModel({
    this.data,
    this.expand,
    this.original,
    required this.code,
    this.statusCode,
    required this.msg,
    this.statusMessage,
  });

  BasicModel.fromJson(Map<String, dynamic>? json, ResponseModel response) {
    statusCode = response.statusCode;
    statusMessage = response.statusMessage;
    code = statusCode.toString();
    msg = '服务器异常';
    original = response;
    if (json != null) {
      final dioOptions = BasicDio().basicDioOptions;
      final codeKeys = dioOptions.codeKeys;
      if (codeKeys.isNotEmpty) {
        for (var key in codeKeys) {
          final value = json[key];
          if (value != null) {
            code = value.toString();
            break;
          }
        }
      }
      final msgKeys = dioOptions.msgKeys;
      if (msgKeys.isNotEmpty) {
        for (var key in msgKeys) {
          final value = json[key];
          if (value != null) {
            msg = value.toString();
            break;
          }
        }
      }
      final dataKeys = dioOptions.dataKeys;
      if (dataKeys.isNotEmpty) {
        for (var key in dataKeys) {
          final value = json[key];
          if (value != null) {
            data = value;
            break;
          }
        }
      }
      final expandKeys = dioOptions.dataKeys;
      if (expandKeys.isNotEmpty) {
        for (var key in expandKeys) {
          final value = json[key];
          if (value != null) {
            data = value;
            break;
          }
        }
      }
    }
  }

  /// 网络请求返回的 statusCode
  int? statusCode;

  /// 网络请求返回的 statusMessage
  String? statusMessage;

  /// 网络请求返回的原始数据
  ResponseModel? original;

  /// 后台定义的 code
  late String code;

  /// 后台定义的 msg
  late String msg;

  /// 后台返回数据
  dynamic data;

  /// 后台返回的扩展数据
  dynamic expand;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'data': data,
        'statusCode': statusCode,
        'statusMessage': statusMessage,
        'msg': msg,
        'code': code,
        'expand': expand
      };
}
