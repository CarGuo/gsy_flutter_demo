import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/drop_select_menu/drop_select_object.dart';

import 'drop_select_controller.dart';

abstract class DropSelectWidget extends StatefulWidget {
  final DropSelectController controller;

  DropSelectWidget({Key key, this.controller}) : super(key: key);

  @override
  DropSelectState<DropSelectWidget> createState();
}

abstract class DropSelectState<T extends DropSelectWidget> extends State<T> {
  DropSelectController controller;

  @override
  void dispose() {
    controller?.removeListener(_onEvent);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    controller ??= widget.controller ?? DropSelectMenuContainer.of(context);
    controller?.addListener(_onEvent);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    if (widget.controller != null) {
      controller?.removeListener(_onEvent);
      controller = widget.controller;
      controller?.addListener(_onEvent);
    }
    super.didUpdateWidget(oldWidget);
  }

  cloneDataList(List<DropSelectObject> form, List<DropSelectObject> to) {
    to.clear();
    form.forEach((item) {
      to.add(item.clone());
    });
  }

  resetList(List<DropSelectObject> list) {
    list.forEach((item) {
      item.selected = false;
      item.children?.forEach((child) {
        child.selected = false;
      });
    });
    selectChildFirst(list);
  }

  selectChildFirst(List<DropSelectObject> list) {
    list.forEach((item) {
      if (item.children != null) {
        item.children[0].selected = true;
      }
    });
  }

  void _onEvent() {
    onEvent(controller.event);
  }

  void onEvent(DropSelectEvent event);
}

class DropSelectMenuContainer extends StatefulWidget {
  DropSelectMenuContainer({
    Key key,
    @required this.child,
    this.onSelected,
  }) : super(key: key);

  final Widget child;

  final DropOnSelected onSelected;

  @override
  _DropSelectMenuContainerState createState() =>
      new _DropSelectMenuContainerState();

  static DropSelectController of(BuildContext context) {
    final _DropSelectMenuInherited scope =
        context.inheritFromWidgetOfExactType(_DropSelectMenuInherited);
    return scope?.controller;
  }
}

class _DropSelectMenuContainerState extends State<DropSelectMenuContainer>
    with SingleTickerProviderStateMixin {
  DropSelectController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new DropSelectController();
    _controller.addListener(_onController);
  }

  void _onController() {
    switch (_controller.event) {
      case DropSelectEvent.SELECT:
        if (widget.onSelected == null) return;
        widget.onSelected(
          data: _controller.data,
          menuIndex: _controller.menuIndex,
          index: _controller.index,
        );

        break;
      case DropSelectEvent.ACTIVE:
        break;
      case DropSelectEvent.HIDE:
        break;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onController);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new _DropSelectMenuInherited(
      controller: _controller,
      enable: TickerMode.of(context),
      child: widget.child,
    );
  }
}

class _DropSelectMenuInherited extends InheritedWidget {
  const _DropSelectMenuInherited(
      {Key key, this.controller, this.enable, Widget child})
      : super(key: key, child: child);

  final bool enable;
  final DropSelectController controller;

  @override
  bool updateShouldNotify(_DropSelectMenuInherited old) {
    return enable != old.enable || controller != old.controller;
  }
}

class DropSelectMenuBuilder {
  final WidgetBuilder builder;
  final double height;

  DropSelectMenuBuilder({@required this.builder, this.height})
      : assert(builder != null);
}

typedef DropOnSelected({int menuIndex, int index, dynamic data});
