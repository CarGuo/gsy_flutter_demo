import 'dart:async';

import 'package:flutter/material.dart';

class AsyncToSyncCallPage extends StatefulWidget {
  const AsyncToSyncCallPage({Key? key}) : super(key: key);

  @override
  State<AsyncToSyncCallPage> createState() => _AsyncToSyncCallPageState();
}

class _AsyncToSyncCallPageState extends State<AsyncToSyncCallPage> {
  Completer<void>? _syncCompleter;

  Future<void> _syncWait(Future Function() fn) async {
    var currentAsync = _syncCompleter;
    var completer = Completer<void>();
    _syncCompleter = completer;

    ///第一次是 null
    await currentAsync?.future;
    await fn.call();
    completer.complete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AsyncToSyncCallPage"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Start······Waiting");
          _syncWait(() async {
            await Future.delayed(Duration(seconds: 4));
            print("Finish First");
          });

          _syncWait(() async {
            await Future.delayed(Duration(seconds: 2));
            print("Finish Tow");
          });

          _syncWait(() async {
            await Future.delayed(Duration(seconds: 1));
            print("Finish Three");
          });
        },
      ),
    );
  }
}
