import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RouteDemoPage extends StatefulWidget {
  const RouteDemoPage({Key? key}) : super(key: key);

  @override
  State<RouteDemoPage> createState() => _RouteDemoPageState();
}

class _RouteDemoPageState extends State<RouteDemoPage> {
  final GlobalKey<NavigatorState> _navigator = GlobalKey();

  getRouter(index) {
    return new CupertinoPageRoute(
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
        title: Text("RouteDemoPage"),
      ),
      body: Container(
        child: Row(
          children: [
            Expanded(
              child: Container(
                color: Colors.blue,
                child: new Column(
                  children: List.generate(10, (index) {
                    return InkWell(
                        onTap: () {
                          _navigator.currentState!.push(getRouter(index));
                        },
                        child: Container(
                            height: 30,
                            margin: EdgeInsets.symmetric(vertical: 10),
                            color: Colors.amberAccent,
                            alignment: Alignment.center,
                            child: Text("click  $index")));
                  }),
                ),
              ),
              flex: 1,
            ),
            new Divider(
              color: Colors.grey,
            ),
            new SizedBox(
              width: 30,
            ),
            Expanded(
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
              flex: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class RoutePage extends StatefulWidget {
  final int index;

  const RoutePage(this.index);

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
          child: new Text(
            "${widget.index}",
            style: TextStyle(fontSize: 100, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
