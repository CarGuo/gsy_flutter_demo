import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AsyncToSyncCallPage extends StatefulWidget {
  const AsyncToSyncCallPage({super.key});

  @override
  State<AsyncToSyncCallPage> createState() => _AsyncToSyncCallPageState();
}

class _AsyncToSyncCallPageState extends State<AsyncToSyncCallPage> {
  Completer<void>? _syncCompleter;

  Future<void> _syncWait(Future Function() fn) async {
    var currentAsync = _syncCompleter;
    final completer = Completer<void>();
    _syncCompleter = completer;

    ///第一次是 null
    await currentAsync?.future;
    await fn.call();
    completer.complete();
  }

  ///因为 setState 不是同步的，只是内部把标记位标志为脏数据
  ///所以如果需要等待 setState 执行结束，需要做一个等待
  waitSetStateComplete(Future Function() fn) async {
    await fn();
    if (mounted) {
      setState(() {});
    }
    final completer = Completer<void>();

    ///下一帧结束
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      completer.complete();
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AsyncToSyncCallPage"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (kDebugMode) {
            print("Start······Waiting");
          }
          _syncWait(() async {
            await Future.delayed(const Duration(seconds: 4));
            if (kDebugMode) {
              print("Finish First");
            }
          });

          _syncWait(() async {
            await Future.delayed(const Duration(seconds: 2));
            if (kDebugMode) {
              print("Finish Tow");
            }
          });

          _syncWait(() async {
            await Future.delayed(const Duration(seconds: 1));
            if (kDebugMode) {
              print("Finish Three");
            }
          });
        },
      ),
    );
  }
}
