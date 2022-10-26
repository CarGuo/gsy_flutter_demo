// ignore_for_file: unused_field, unused_element

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';

///列表简单联动 BottomSheet
class ListLinkBottomSheetDemoPage extends StatefulWidget {
  const ListLinkBottomSheetDemoPage({Key? key}) : super(key: key);

  @override
  State<ListLinkBottomSheetDemoPage> createState() =>
      _ListLinkBottomSheetDemoPageState();
}

class _ListLinkBottomSheetDemoPageState
    extends State<ListLinkBottomSheetDemoPage> {
  PageController? _pageController;
  ScrollController? _listScrollController;
  ScrollController? _activeScrollController;
  Drag? _drag;
  Drag? _bottomSheetDrag;
  GlobalKey<_LinkBottomSheetState> btKey = new GlobalKey();
  _BTController _btController = _BTController();

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

  void _handleDragStart(DragStartDetails details, bool fromInner) {
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

  void _handleDragUpdate(DragUpdateDetails details, bool fromInner) {
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

    ///只有是 PageView 活跃，也就是 list 到底了，并且手势不来自于 bt 内部才需要让内部相应
    if (_activeScrollController == _pageController && fromInner == false) {
      btKey.currentState?.onVerticalDragUpdate(details, true);
    }
    _drag?.update(details);
  }

  void _handleDragEnd(DragEndDetails details, bool fromInner) {
    _drag?.end(details);

    ///只有是 PageView 活跃，也就是 list 到底了，并且手势不来自于 bt 内部才需要让内部相应
    if (_activeScrollController == _pageController && fromInner == false) {
      btKey.currentState?.onVerticalDragEnd(details, true);
    }
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
        title: new Text("ListLinkBottomSheetDemoPage"),
      ),
      extendBody: true,
      body: RawGestureDetector(
        gestures: <Type, GestureRecognizerFactory>{
          VerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                  VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer(),
              (VerticalDragGestureRecognizer instance) {
            instance
              ..onStart = (details) {
                _handleDragStart(details, false);
              }
              ..onUpdate = (details) {
                _handleDragUpdate(details, false);
              }
              ..onEnd = (details) {
                _handleDragEnd(details, false);
              }
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
                child: _KeepAliveListView(
                  listScrollController: _listScrollController,
                  itemCount: 30,
                )),
            Container(
              color: Colors.white,
              child: Center(
                child: Text(
                  '纯粹背后占位',
                  style: TextStyle(fontSize: 50),
                ),
              ),
            )
          ],
        ),
      ),
      bottomSheet: _LinkBottomSheet(
          key: btKey,
          controller: _btController,
          maxHeight: MediaQuery.of(context).size.height -
              MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                  .padding
                  .top -
              kToolbarHeight -
              50,
          draggableBody: true,
          onVerticalDragEnd: (details) {
            if (_activeScrollController == _pageController) {}
          },
          onVerticalDragUpdate: (details) {
            if (_activeScrollController == _pageController) {
              if (_bottomSheetDrag == null) {
                _bottomSheetDrag = _pageController?.position.drag(
                    DragStartDetails(
                        globalPosition: details.globalPosition,
                        localPosition: details.localPosition),
                    _disposeDrag);
              }
              _bottomSheetDrag?.update(details);
            }
          },
          onHide: () {
            ///关闭之后，就调整状态
            _bottomSheetDrag = null;
            _activeScrollController = _listScrollController;
            _pageController?.jumpToPage(0);
          },
          headerBar: Container(
            color: Theme.of(context).primaryColor,
            height: 50,
            child: Center(
              child: Text(
                "Header",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          body: Container(
            color: Colors.white,
            height: 30,
            child: Center(
              child: Text(
                "BottomSheet /n Content",
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
          )),
    );
  }
}

///对 PageView 里的 ListView 做 KeepAlive 记住位置
class _KeepAliveListView extends StatefulWidget {
  final ScrollController? listScrollController;
  final int itemCount;

  _KeepAliveListView({
    required this.listScrollController,
    required this.itemCount,
  });

  @override
  _KeepAliveListViewState createState() => _KeepAliveListViewState();
}

class _KeepAliveListViewState extends State<_KeepAliveListView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      controller: widget.listScrollController,

      ///屏蔽默认的滑动响应
      physics:
          const NeverScrollableScrollPhysics(parent: ClampingScrollPhysics()),
      itemBuilder: (context, index) {
        return ListTile(title: Text('List Item $index'));
      },
      itemCount: widget.itemCount,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

///copy from https://github.com/dbenitez-bcn/solid_bottom_sheet/blob/master/example/lib/main.dart
class _LinkBottomSheet extends StatefulWidget {
  final double minHeight;
  final double maxHeight;
  final Widget body;
  final Widget headerBar;

  ///是否自动
  final bool autoSwiped;
  final bool toggleVisibilityOnTap;
  final bool draggableBody;
  final bool canUserSwipe;
  final _BTConfig smoothness;
  final double elevation;
  final bool showOnAppear;
  final _BTController? controller;
  final void Function()? onShow;
  final void Function()? onHide;

  final void Function(DragUpdateDetails details)? onVerticalDragUpdate;
  final void Function(DragEndDetails details)? onVerticalDragEnd;

  _LinkBottomSheet({
    Key? key,
    required this.headerBar,
    required this.body,
    required this.controller,
    this.minHeight = 0,
    this.maxHeight = 500,
    this.autoSwiped = true,
    this.toggleVisibilityOnTap = false,
    this.canUserSwipe = true,
    this.draggableBody = false,
    this.smoothness = _BTConfig.medium,
    this.elevation = 0.0,
    this.showOnAppear = false,
    this.onShow,
    this.onHide,
    this.onVerticalDragEnd,
    this.onVerticalDragUpdate,
  })  : assert(elevation >= 0.0),
        assert(minHeight >= 0.0),
        super(key: key) {
    this.controller!.height =
        this.showOnAppear ? this.maxHeight : this.minHeight;
    this.controller!.config = smoothness;
  }

  @override
  _LinkBottomSheetState createState() => _LinkBottomSheetState();
}

class _LinkBottomSheetState extends State<_LinkBottomSheet> {
  bool? isDragDirectionUp;

  void onVerticalDragUpdate(data, fromOuter) {
    _setNativeConfig();
    if (((widget.controller!.height - data.delta.dy) > widget.minHeight) &&
        ((widget.controller!.height - data.delta.dy) < widget.maxHeight)) {
      isDragDirectionUp = data.delta.dy <= 0;
      widget.controller!.height -= data.delta.dy;
    }
    if (!fromOuter) widget.onVerticalDragUpdate?.call(data);
  }

  void onVerticalDragEnd(data, fromOuter) {
    _setUsersConfig();
    if (isDragDirectionUp! && widget.controller!.value)
      _show();
    else if (!isDragDirectionUp! && !widget.controller!.value)
      _hide();
    else
      widget.controller!.value = isDragDirectionUp!;
    if (!fromOuter) widget.onVerticalDragEnd?.call(data);
  }

  void _onTap() {
    final bool isOpened = widget.controller!.height == widget.maxHeight;
    widget.controller!.value = !isOpened;
  }

  void Function()? _controllerListener;

  @override
  void initState() {
    super.initState();
    widget.controller!.value = widget.showOnAppear;
    _controllerListener = () {
      widget.controller!.value ? _show() : _hide();
    };
    widget.controller!.addListener(_controllerListener!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestureDetector(
          onVerticalDragUpdate: widget.canUserSwipe
              ? (d) {
                  onVerticalDragUpdate(d, false);
                }
              : null,
          onVerticalDragEnd: widget.autoSwiped
              ? (d) {
                  onVerticalDragEnd(d, false);
                }
              : null,
          onTap: widget.toggleVisibilityOnTap ? _onTap : null,
          child: Container(
            decoration: widget.elevation > 0
                ? BoxDecoration(boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: widget.elevation,
                    ),
                  ])
                : null,
            width: MediaQuery.of(context).size.width,
            child: widget.headerBar,
          ),
        ),
        StreamBuilder<double>(
          stream: widget.controller!.heightStream,
          initialData: widget.controller!.height,
          builder: (_, snapshot) {
            return AnimatedContainer(
              curve: Curves.easeOut,
              duration:
                  Duration(milliseconds: widget.controller!.config!.value),
              height: snapshot.data,
              child: GestureDetector(
                onVerticalDragUpdate: widget.draggableBody
                    ? (d) {
                        onVerticalDragUpdate(d, false);
                      }
                    : null,
                onVerticalDragEnd: widget.autoSwiped
                    ? (d) {
                        onVerticalDragEnd(d, false);
                      }
                    : null,
                onTap: widget.toggleVisibilityOnTap ? _onTap : null,
                child: widget.body,
              ),
            );
          },
        ),
      ],
    );
  }

  void _hide() {
    if (widget.onHide != null) widget.onHide!();
    widget.controller!.height = widget.minHeight;
  }

  void _show() {
    if (widget.onShow != null) widget.onShow!();
    widget.controller!.height = widget.maxHeight;
  }

  @override
  void dispose() {
    widget.controller!.removeListener(_controllerListener!);
    super.dispose();
  }

  void _setUsersConfig() {
    widget.controller!.config = widget.smoothness;
  }

  void _setNativeConfig() {
    widget.controller!.config = _BTConfig.withValue(5);
  }
}

class _BTConfig {
  final int _value;

  _BTConfig._() : _value = 0;

  const _BTConfig._low() : _value = 100;

  const _BTConfig._medium() : _value = 250;

  const _BTConfig._high() : _value = 500;

  const _BTConfig._withValue(int value) : _value = value;

  static const _BTConfig low = _BTConfig._low();
  static const _BTConfig medium = _BTConfig._medium();
  static const _BTConfig high = _BTConfig._high();

  static _BTConfig withValue(int value) => _BTConfig._withValue(value);

  int get value => _value;
}

class _BTController extends ValueNotifier<bool> {
  BTStreamStatus _bloc = BTStreamStatus();

  double? _height;

  _BTConfig? config;

  _BTController() : super(false);

  Stream<double> get heightStream => _bloc.height;

  Stream<bool> get isOpenStream => _bloc.isOpen;

  set height(double value) {
    _height = value;
    _bloc.dispatch(value);
  }

  double get height => _height!;

  bool get isOpened => value;

  void hide() => value = false;

  void show() => value = true;

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}

class BTStreamStatus {
  StreamController<double> _heightController =
      StreamController<double>.broadcast();

  Stream<double> get height => _heightController.stream;

  Sink<double> get _heightSink => _heightController.sink;

  StreamController<bool> _visibilityController =
      StreamController<bool>.broadcast();

  Stream<bool> get isOpen => _visibilityController.stream;

  Sink<bool> get _visibilitySink => _visibilityController.sink;

  void dispatch(double value) {
    _heightSink.add(value);
    _visibilitySink.add(value > 0);
  }

  void dispose() {
    _heightController.close();
    _visibilityController.close();
  }
}
