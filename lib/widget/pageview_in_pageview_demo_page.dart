import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
//https://stackoverflow.com/questions/60642631/how-to-merge-scrolls-on-a-tabbarview-inside-a-pageview/60712386#60712386

//https://dartpad.dev/?id=abe26388e1f3a2ea0660fbd6089c6da5
class PageViewInPageViewDemoPage extends StatefulWidget {
  const PageViewInPageViewDemoPage({super.key});

  @override
  State<PageViewInPageViewDemoPage> createState() =>
      _PageViewInPageViewDemoPageState();
}

class _PageViewInPageViewDemoPageState
    extends State<PageViewInPageViewDemoPage> {
  final _pageController1 = PageController(); // Controlled
  final _pageController2 = PageController(); // Controller
  final _pageController3 = PageController(); // Controller

  var leftOverScroll = 0.0; // total over-scroll offset on left side
  var rightOverScroll = 0.0;

  //first item is PageView
  bool isEnd = true;

  nestResult(notification, PageController pageOuter, PageController pageInner) {
    if (isEnd) {
      return;
    }

    // over scroll to the left side
    if (notification is OverscrollNotification && notification.overscroll < 0) {
      leftOverScroll += notification.overscroll;
      pageOuter.position
          .correctPixels(pageOuter.position.pixels + notification.overscroll);
      pageOuter.position.notifyListeners();
    }

    // scroll back after left over scrolling
    if (leftOverScroll < 0) {
      if (notification is ScrollUpdateNotification) {
        final newOverScroll =
            math.min(notification.metrics.pixels + leftOverScroll, 0.0);
        final diff = newOverScroll - leftOverScroll;
        pageOuter.position.correctPixels(pageOuter.position.pixels + diff);
        pageOuter.position.notifyListeners();
        leftOverScroll = newOverScroll;
        pageInner.position.correctPixels(0);
        pageInner.position.notifyListeners();
      }
    }

    // release left
    if (notification is UserScrollNotification &&
        notification.direction == ScrollDirection.idle &&
        leftOverScroll != 0) {
      pageOuter.previousPage(
          curve: Curves.ease, duration: const Duration(milliseconds: 400));
      leftOverScroll = 0;
    }

    // over scroll to the right side
    if (notification is OverscrollNotification && notification.overscroll > 0) {
      rightOverScroll += notification.overscroll;
      pageOuter.position
          .correctPixels(pageOuter.position.pixels + notification.overscroll);
      pageOuter.position.notifyListeners();
    }

    // scroll back after right over scrolling
    if (rightOverScroll > 0) {
      if (notification is ScrollUpdateNotification) {
        final maxScrollExtent = notification.metrics.maxScrollExtent;
        final newOverScroll = math.max(
            notification.metrics.pixels + rightOverScroll - maxScrollExtent,
            0.0);
        final diff = newOverScroll - rightOverScroll;
        pageOuter.position.correctPixels(pageOuter.position.pixels + diff);
        pageOuter.position.notifyListeners();
        rightOverScroll = newOverScroll;
        pageInner.position.correctPixels(maxScrollExtent);
        pageInner.position.notifyListeners();
      }
    }

    // release right
    if (notification is UserScrollNotification &&
        notification.direction == ScrollDirection.idle &&
        rightOverScroll != 0) {
      pageOuter.nextPage(
          curve: Curves.ease, duration: const Duration(milliseconds: 400));
      rightOverScroll = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PageViewInPageViewDemoPage"),
      ),
      extendBody: true,
      body: PageView(
        physics: const ClampingScrollPhysics(),
        controller: _pageController1,
        children: [
          Column(
            children: [
              const Text("Inner PageView 1"),
              Expanded(
                child: NotificationListener(
                  onNotification: (notification) {
                    nestResult(
                        notification, _pageController1, _pageController3);
                    return false;
                  },
                  child: PageView(
                    onPageChanged: (index) {
                      if (index == 0) {
                        isEnd = true;
                      } else {
                        isEnd = false;
                      }
                    },
                    physics: const ClampingScrollPhysics(),
                    controller: _pageController3,
                    children: [
                      KeepAliveWrapper(
                        child: Container(
                          color: Colors.purpleAccent,
                          child: const Center(
                            child: Text("Inner PageView Item"),
                          ),
                        ),
                      ),
                      KeepAliveWrapper(
                        child: Container(
                          color: Colors.teal,
                          child: const Center(
                            child: Text("Inner PageView Item"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Text("Inner PageView 2"),
              Expanded(
                child: NotificationListener(
                  onNotification: (notification) {
                    nestResult(
                        notification, _pageController1, _pageController2);
                    return false;
                  },
                  child: PageView(
                    physics: const ClampingScrollPhysics(),
                    controller: _pageController2,
                    children: [
                      KeepAliveWrapper(
                        child: Container(
                          color: Colors.greenAccent,
                          child: const Center(
                            child: Text("Inner PageView Item"),
                          ),
                        ),
                      ),
                      KeepAliveWrapper(
                        child: Container(
                          color: Colors.yellowAccent,
                          child: const Center(
                            child: Text("Inner PageView Item"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            color: Colors.blue,
            child: const Center(
              child: Text("Outer PageView Item"),
            ),
          ),
        ],
      ),
    );
  }
}

class KeepAliveWrapper extends StatefulWidget {
  const KeepAliveWrapper({
    super.key,
    this.keepAlive = true,
    required this.child,
  });
  final bool keepAlive;
  final Widget child;

  @override
  _KeepAliveWrapperState createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  void didUpdateWidget(covariant KeepAliveWrapper oldWidget) {
    if (oldWidget.keepAlive != widget.keepAlive) {
      // keepAlive 状态需要更新，实现在 AutomaticKeepAliveClientMixin 中
      updateKeepAlive();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
