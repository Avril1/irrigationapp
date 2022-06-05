import 'package:fluro/fluro.dart';
import 'package:fluro/src/fluro_router.dart';
import 'package:irrigation_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_client/thingsboard_client.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class TbContext{
  bool _initialized = false;
  late final ThingsboardClient tbClient;
  final _log = TbLogger();

  final FluroRouter router;
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  final ValueNotifier<bool> _isAuthenticated = ValueNotifier(false);
  TbContext(this.router);

  TbLogger get log => _log;

  Future<void> init() async {
    assert(() {
      if (_initialized) {
        throw StateError('TbContext already initialized!');
      }
      return true;
    }());
    tbClient = ThingsboardClient(ThingsboardAppConstants.thingsBoardApiEndpoint);
    _initialized = true;
    try{
      await tbClient.init();
    } catch (e, s) {
      log.error('Failed to init tbContext: $e', e, s);
     }
  }

  bool get isAuthenticated => _isAuthenticated.value;
}


class TbLogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      debugPrint(line);
    }
  }
}

class TbLogsFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (kReleaseMode) {
      return event.level.index >= Level.warning.index;
    } else {
      return true;
    }
  }
}

class TbLogger {
  final _logger = Logger(
      filter: TbLogsFilter(),
      printer: PrefixPrinter(
          PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 8,
              lineLength: 200,
              colors: false,
              printEmojis: true,
              printTime: false
          )
      ),
      output: TbLogOutput()
  );

  void verbose(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.v(message, error, stackTrace);
  }

  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error, stackTrace);
  }

  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error, stackTrace);
  }

  void warn(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error, stackTrace);
  }

  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
  }

  void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.wtf(message, error, stackTrace);
  }
}

mixin HasTbContext {
  late final TbContext _tbContext;

  void setTbContext(TbContext tbContext) {
    _tbContext = tbContext;
  }

  void setupTbContext(TbContextState currentState) {
    _tbContext = currentState.widget.tbContext;
  }

  TbContext get tbContext => _tbContext;

  TbLogger get log => _tbContext.log;

  ThingsboardClient get tbClient => _tbContext.tbClient;

  Future<void> initTbContext() async {
    await _tbContext.init();
  }

  void subscribeRouteObserver(TbPageState pageState) {
    _tbContext.routeObserver.subscribe(pageState, ModalRoute.of(pageState.context) as PageRoute);
  }

  void unsubscribeRouteObserver(TbPageState pageState) {
    _tbContext.routeObserver.unsubscribe(pageState);
  }

}

