import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RouteDemoPage extends StatefulWidget {
  const RouteDemoPage({super.key});

  @override
  State<RouteDemoPage> createState() => _RouteDemoPageState();
}

class _RouteDemoPageState extends State<RouteDemoPage> {
  final GlobalKey<NavigatorState> _navigator = GlobalKey();

  getRouter(index) {
    return CupertinoPageRoute(
        builder: (context) {
          return RoutePage(index);
        },
        maintainState: false,
        fullscreenDialog: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RouteDemoPage"),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blue,
              child: Column(
                children: List.generate(10, (index) {
                  return InkWell(
                      onTap: () {
                        _navigator.currentState!.push(getRouter(index));
                      },
                      child: Container(
                          height: 30,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          color: Colors.amberAccent,
                          alignment: Alignment.center,
                          child: Text("click  $index")));
                }),
              ),
            ),
          ),
          const Divider(
            color: Colors.grey,
          ),
          const SizedBox(
            width: 30,
          ),
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey,
              child: Navigator(
                restorationScopeId: 'nav2',
                key: _navigator,
                onGenerateInitialRoutes:
                    (NavigatorState navigator, String initialRoute) {
                  return [
                    getRouter(0),
                  ];
                },
                reportsRouteUpdateToEngine: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoutePage extends StatefulWidget {
  final int index;

  const RoutePage(this.index, {super.key});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      child: InkWell(
        onTap: () {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        },
        child: Container(
          width: 200,
          height: 200,
          alignment: Alignment.center,
          color: Colors.amber,
          child: Text(
            "${widget.index}",
            style: const TextStyle(fontSize: 100, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
