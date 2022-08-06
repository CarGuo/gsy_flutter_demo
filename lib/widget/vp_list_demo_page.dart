import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


///对应文章解析 https://juejin.cn/post/7116267156655833102
///简单处理处理 pageview 嵌套 listview 的斜滑问题
class VPListView extends StatefulWidget {
  const VPListView({Key? key}) : super(key: key);

  @override
  State<VPListView> createState() => _VPListViewState();
}

class _VPListViewState extends State<VPListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("VPListView"),
      ),
      extendBody: true,
      body: MediaQuery(
        ///调高 touchSlop 到 50 ，这样 pageview 滑动可能有点点影响，
        ///但是大概率处理了斜着滑动触发的问题
        data: MediaQuery.of(context).copyWith(
            gestureSettings: DeviceGestureSettings(
          touchSlop: 50,
        )),
        child: PageView(
          scrollDirection: Axis.horizontal,
          pageSnapping: true,
          children: [
            HandlerListView(),
            HandlerListView(),
          ],
        ),
      ),
    );
  }
}

class HandlerListView extends StatefulWidget {
  @override
  _MyListViewState createState() => _MyListViewState();
}

class _MyListViewState extends State<HandlerListView> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      ///这里 touchSlop  需要调回默认
      data: MediaQuery.of(context).copyWith(
          gestureSettings: DeviceGestureSettings(
        touchSlop: kTouchSlop,
      )),
      child: ListView.separated(
        itemCount: 15,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item $index'),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(
            thickness: 3,
          );
        },
      ),
    );
  }
}

///对应文章解析 https://juejin.cn/post/7116267156655833102
///垂直滑动的 ViewPage 里嵌套垂直滑动的 ListView
class VPNestListView extends StatefulWidget {
  @override
  _VPNestListViewState createState() => _VPNestListViewState();
}

class _VPNestListViewState extends State<VPNestListView> {
  PageController? _pageController;
  ScrollController? _listScrollController;
  ScrollController? _activeScrollController;
  Drag? _drag;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _listScrollController = ScrollController();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _listScrollController?.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    ///先判断 Listview 是否可见或者可以调用
    ///一般不可见时 hasClients false ，因为 PageView 也没有 keepAlive
    if (_listScrollController?.hasClients == true &&
        _listScrollController?.position.context.storageContext != null) {
      ///获取 ListView 的  renderBox
      final RenderBox? renderBox = _listScrollController
          ?.position.context.storageContext
          .findRenderObject() as RenderBox;

      ///判断触摸的位置是否在 ListView 内
      ///不在范围内一般是因为 ListView 已经滑动上去了，坐标位置和触摸位置不一致
      if (renderBox?.paintBounds
              .shift(renderBox.localToGlobal(Offset.zero))
              .contains(details.globalPosition) ==
          true) {
        _activeScrollController = _listScrollController;
        _drag = _activeScrollController?.position.drag(details, _disposeDrag);
        return;
      }
    }

    ///这时候就可以认为是 PageView 需要滑动
    _activeScrollController = _pageController;
    _drag = _pageController?.position.drag(details, _disposeDrag);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_activeScrollController == _listScrollController &&

        ///手指向上移动，也就是快要显示出底部 PageView
        details.primaryDelta! < 0 &&

        ///到了底部，切换到 PageView
        _activeScrollController?.position.pixels ==
            _activeScrollController?.position.maxScrollExtent) {
      ///切换相应的控制器
      _activeScrollController = _pageController;
      _drag?.cancel();

      ///参考  Scrollable 里的，
      ///因为是切换控制器，也就是要更新 Drag
      ///拖拽流程要切换到 PageView 里，所以需要  DragStartDetails
      ///所以需要把 DragUpdateDetails 变成 DragStartDetails
      ///提取出 PageView 里的 Drag 相应 details
      _drag = _pageController?.position.drag(
          DragStartDetails(
              globalPosition: details.globalPosition,
              localPosition: details.localPosition),
          _disposeDrag);
    }
    _drag?.update(details);
  }

  void _handleDragEnd(DragEndDetails details) {
    _drag?.end(details);
  }

  void _handleDragCancel() {
    _drag?.cancel();
  }

  ///拖拽结束了，释放  _drag
  void _disposeDrag() {
    _drag = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("VPNestListView"),
      ),
      extendBody: true,
      body: RawGestureDetector(
        gestures: <Type, GestureRecognizerFactory>{
          VerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                  VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer(),
              (VerticalDragGestureRecognizer instance) {
            instance
              ..onStart = _handleDragStart
              ..onUpdate = _handleDragUpdate
              ..onEnd = _handleDragEnd
              ..onCancel = _handleDragCancel;
          })
        },
        behavior: HitTestBehavior.opaque,
        child: PageView(
          controller: _pageController,
          scrollDirection: Axis.vertical,

          ///去掉 Android 上默认的边缘拖拽效果
          scrollBehavior:
              ScrollConfiguration.of(context).copyWith(overscroll: false),

          ///屏蔽默认的滑动响应
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ScrollConfiguration(

                ///去掉 Android 上默认的边缘拖拽效果
                behavior:
                    ScrollConfiguration.of(context).copyWith(overscroll: false),
                child: KeepAliveListView(
                  listScrollController: _listScrollController,
                  itemCount: 30,
                )),
            Container(
              color: Colors.green,
              child: Center(
                child: Text(
                  'Page View',
                  style: TextStyle(fontSize: 50),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

///对 PageView 里的 ListView 做 KeepAlive 记住位置
class KeepAliveListView extends StatefulWidget {
  final ScrollController? listScrollController;
  final int itemCount;

  KeepAliveListView({
    required this.listScrollController,
    required this.itemCount,
  });

  @override
  KeepAliveListViewState createState() => KeepAliveListViewState();
}

class KeepAliveListViewState extends State<KeepAliveListView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      controller: widget.listScrollController,

      ///屏蔽默认的滑动响应
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return ListTile(title: Text('List Item $index'));
      },
      itemCount: widget.itemCount,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

////////////////////////////////////////////////////////////////////////////////

///对应文章解析 https://juejin.cn/post/7116267156655833102
///listView 里嵌套 PageView
class ListViewNestVP extends StatefulWidget {
  @override
  _ListViewNestVPState createState() => _ListViewNestVPState();
}

class _ListViewNestVPState extends State<ListViewNestVP> {
  PageController _pageController = PageController();
  ScrollController _listScrollController = ScrollController();
  late ScrollController _activeScrollController;
  Drag? _drag;
  int itemCount = 4;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _listScrollController = ScrollController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    ///只要不是顶部，就不响应 PageView 的滑动
    ///所以这个判断只支持垂直 PageView 在  ListView 的顶部
    if (_listScrollController.offset > 0) {
      _activeScrollController = _listScrollController;
      _drag = _listScrollController.position.drag(details, _disposeDrag);
      return;
    }

    ///此时处于  ListView 的顶部
    if (_pageController.hasClients) {
      ///获取 PageView
      final RenderBox renderBox =
          _pageController.position.context.storageContext.findRenderObject()
              as RenderBox;

      ///判断触摸范围是不是在 PageView
      final isDragPageView = renderBox.paintBounds
          .shift(renderBox.localToGlobal(Offset.zero))
          .contains(details.globalPosition);

      ///如果在 PageView 里就切换到 PageView
      if (isDragPageView) {
        _activeScrollController = _pageController;
        _drag = _activeScrollController.position.drag(details, _disposeDrag);
        return;
      }
    }

    ///不在 PageView 里就继续响应 ListView
    _activeScrollController = _listScrollController;
    _drag = _listScrollController.position.drag(details, _disposeDrag);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    var scrollDirection = _activeScrollController.position.userScrollDirection;

    ///判断此时响应的如果还是 _pageController，是不是到了最后一页
    if (_activeScrollController == _pageController &&
        scrollDirection == ScrollDirection.reverse &&

        ///是不是到最后一页了，到最后一页就切换回 pageController
        (_pageController.page != null &&
            _pageController.page! >= (itemCount - 1))) {
      ///切换回 ListView
      _activeScrollController = _listScrollController;
      _drag?.cancel();
      _drag = _listScrollController.position.drag(
          DragStartDetails(
              globalPosition: details.globalPosition,
              localPosition: details.localPosition),
          _disposeDrag);
    }
    _drag?.update(details);
  }

  void _handleDragEnd(DragEndDetails details) {
    _drag?.end(details);
  }

  void _handleDragCancel() {
    _drag?.cancel();
  }

  void _disposeDrag() {
    _drag = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("ListViewNestVP"),
        ),
        body: RawGestureDetector(
          gestures: <Type, GestureRecognizerFactory>{
            VerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                    VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer(),
                (VerticalDragGestureRecognizer instance) {
              instance
                ..onStart = _handleDragStart
                ..onUpdate = _handleDragUpdate
                ..onEnd = _handleDragEnd
                ..onCancel = _handleDragCancel;
            })
          },
          behavior: HitTestBehavior.opaque,
          child: ScrollConfiguration(
            ///去掉 Android 上默认的边缘拖拽效果
            behavior:
                ScrollConfiguration.of(context).copyWith(overscroll: false),
            child: ListView.builder(

                ///屏蔽默认的滑动响应
                physics: NeverScrollableScrollPhysics(),
                controller: _listScrollController,
                itemCount: 5,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Container(
                      height: 300,
                      child: KeepAlivePageView(
                        pageController: _pageController,
                        itemCount: itemCount,
                      ),
                    );
                  }
                  return Container(
                      height: 300,
                      color: Colors.greenAccent,
                      child: Center(
                        child: Text(
                          "Item $index",
                          style: TextStyle(fontSize: 40, color: Colors.blue),
                        ),
                      ));
                }),
          ),
        ));
  }
}

///对 ListView 里的 PageView 做 KeepAlive 记住位置
class KeepAlivePageView extends StatefulWidget {
  final PageController pageController;
  final int itemCount;

  KeepAlivePageView({
    required this.pageController,
    required this.itemCount,
  });

  @override
  KeepAlivePageViewState createState() => KeepAlivePageViewState();
}

class KeepAlivePageViewState extends State<KeepAlivePageView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PageView.builder(
      controller: widget.pageController,
      scrollDirection: Axis.vertical,

      ///去掉 Android 上默认的边缘拖拽效果
      scrollBehavior:
          ScrollConfiguration.of(context).copyWith(overscroll: false),

      ///屏蔽默认的滑动响应
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return Container(
          height: 300,
          child: Center(
            child: Text(
              "$index",
              style: TextStyle(fontSize: 40, color: Colors.yellowAccent),
            ),
          ),
          color: Colors.redAccent,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

///listView 联动 listView
class ListViewLinkListView extends StatefulWidget {
  @override
  _ListViewLinkListViewState createState() => _ListViewLinkListViewState();
}

class _ListViewLinkListViewState extends State<ListViewLinkListView> {
  ScrollController _primaryScrollController = ScrollController();
  ScrollController _subScrollController = ScrollController();

  Drag? _primaryDrag;
  Drag? _subDrag;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _primaryScrollController.dispose();
    _subScrollController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _primaryDrag =
        _primaryScrollController.position.drag(details, _disposePrimaryDrag);
    _subDrag = _subScrollController.position.drag(details, _disposeSubDrag);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _primaryDrag?.update(details);

    ///除以10实现差量效果
    _subDrag?.update(DragUpdateDetails(
        sourceTimeStamp: details.sourceTimeStamp,
        delta: details.delta / 30,
        primaryDelta: (details.primaryDelta ?? 0) / 30,
        globalPosition: details.globalPosition,
        localPosition: details.localPosition));
  }

  void _handleDragEnd(DragEndDetails details) {
    _primaryDrag?.end(details);
    _subDrag?.end(details);
  }

  void _handleDragCancel() {
    _primaryDrag?.cancel();
    _subDrag?.cancel();
  }

  void _disposePrimaryDrag() {
    _primaryDrag = null;
  }

  void _disposeSubDrag() {
    _subDrag = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("ListViewLinkListView"),
        ),
        body: RawGestureDetector(
          gestures: <Type, GestureRecognizerFactory>{
            VerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                    VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer(),
                (VerticalDragGestureRecognizer instance) {
              instance
                ..onStart = _handleDragStart
                ..onUpdate = _handleDragUpdate
                ..onEnd = _handleDragEnd
                ..onCancel = _handleDragCancel;
            })
          },
          behavior: HitTestBehavior.opaque,
          child: ScrollConfiguration(
            ///去掉 Android 上默认的边缘拖拽效果
            behavior:
                ScrollConfiguration.of(context).copyWith(overscroll: false),
            child: Row(
              children: [
                new Expanded(
                    child: ListView.builder(

                        ///屏蔽默认的滑动响应
                        physics: NeverScrollableScrollPhysics(),
                        controller: _primaryScrollController,
                        itemCount: 55,
                        itemBuilder: (context, index) {
                          return Container(
                              height: 300,
                              color: Colors.greenAccent,
                              child: Center(
                                child: Text(
                                  "Item $index",
                                  style: TextStyle(
                                      fontSize: 40, color: Colors.blue),
                                ),
                              ));
                        })),
                new SizedBox(
                  width: 5,
                ),
                new Expanded(
                  child: ListView.builder(

                      ///屏蔽默认的滑动响应
                      physics: NeverScrollableScrollPhysics(),
                      controller: _subScrollController,
                      itemCount: 55,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 300,
                          color: Colors.deepOrange,
                          child: Center(
                            child: Text(
                              "Item $index",
                              style:
                                  TextStyle(fontSize: 40, color: Colors.white),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ));
  }
}
