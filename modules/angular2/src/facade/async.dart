library angular.core.facade.async;

import 'dart:async';
export 'dart:async' show Future, Stream, StreamController, StreamSubscription;

class PromiseWrapper {
  static Future resolve(obj) => new Future.value(obj);

  static Future reject(obj) => new Future.error(
      obj,
      obj is Error ? obj.stackTrace : null);

  static Future<List> all(List<Future> promises) => Future.wait(promises);

  static Future then(Future promise, success(value), Function onError) {
    if (success == null) return promise.catchError(onError);
    return promise.then(success, onError: onError);
  }

  // Note: We can't rename this method to `catch`, as this is not a valid
  // method name in Dart.
  static Future catchError(Future promise, Function onError) {
    return promise.catchError(onError);
  }

  static _Completer completer() => new _Completer(new Completer());

  // TODO(vic): create a TimerWrapper
  static Timer setTimeout(fn(), int millis)
      => new Timer(new Duration(milliseconds: millis), fn);
  static void clearTimeout(Timer timer) {
    timer.cancel();
  }

  static Timer setInterval(fn(), int millis) {
    var interval = new Duration(milliseconds: millis);
    return new Timer.periodic(interval, (Timer timer) { fn(); });
  }
  static void clearInterval(Timer timer) {
    timer.cancel();
  }

  static bool isPromise(maybePromise) {
    return maybePromise is Future;
  }
}

class ObservableWrapper {
  static StreamSubscription subscribe(Stream s, Function onNext,
      [onError, onComplete]) {
    return s.listen(onNext,
        onError: onError, onDone: onComplete, cancelOnError: true);
  }

  static bool isObservable(obs) {
    return obs is Stream;
  }

  static void dispose(StreamSubscription s) {
    s.cancel();
  }

  static void callNext(EventEmitter emitter, value) {
    emitter.add(value);
  }

  static void callThrow(EventEmitter emitter, error) {
    emitter.addError(error);
  }

  static void callReturn(EventEmitter emitter) {
    emitter.close();
  }
}

class EventEmitter extends Stream {
  StreamController<String> _controller;

  EventEmitter() {
    _controller = new StreamController.broadcast();
  }

  StreamSubscription listen(void onData(String line),
      {void onError(Error error), void onDone(), bool cancelOnError}) {
    return _controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  void add(value) {
    _controller.add(value);
  }

  void addError(error) {
    _controller.addError(error);
  }

  void close() {
    _controller.close();
  }
}

class _Completer {
  final Completer c;

  _Completer(this.c);

  Future get promise => c.future;

  void resolve(v) {
    c.complete(v);
  }

  void reject(v) {
    var stack = null;
    if (v is Error) {
      stack = v.stackTrace;
    }
    c.completeError(v, stack);
  }
}
