import 'package:gsy_flutter_demo/widget/drop_select_menu/drop_select_object.dart';

final selectNormal = getSelectList();
final selectExpand = getSelectChildExpandList();
final selectChildGrid = getSelectChildList();

getSelectList() {
  return [
    DropSelectObject(title: "全部", selectedCleanOther: true, selected: true),
    DropSelectObject(title: "选择2"),
    DropSelectObject(title: "选择3"),
    DropSelectObject(title: "选择4"),
    DropSelectObject(title: "选择5"),
    DropSelectObject(title: "选择6"),
    DropSelectObject(title: "选择7"),
    DropSelectObject(title: "选择7"),
  ];
}

getSelectChildList() {
  List<DropSelectObject> children1 = [
    DropSelectObject(title: "全部", selectedCleanOther: true, selected: true),
    DropSelectObject(title: "问题1"),
    DropSelectObject(title: "问题2"),
    DropSelectObject(title: "问题3"),
    DropSelectObject(title: "问题4"),
    DropSelectObject(title: "问题5"),
    DropSelectObject(title: "问题6"),
    DropSelectObject(title: "问题7"),
    DropSelectObject(title: "问题8"),
  ];

  List<DropSelectObject> children2 = [
    DropSelectObject(title: "全部", selectedCleanOther: true, selected: true),
    DropSelectObject(title: "测试1"),
    DropSelectObject(title: "测试2"),
    DropSelectObject(title: "测试3"),
    DropSelectObject(title: "测试4"),
    DropSelectObject(title: "测试5"),
    DropSelectObject(title: "测试6"),
  ];

  return [
    DropSelectObject(title: "选择1", children: children1),
    DropSelectObject(title: "选择2", children: children2),
  ];
}

getSelectChildExpandList() {
  List<DropSelectObject> children1 = [
    DropSelectObject(title: "全部", selectedCleanOther: true, selected: true),
    DropSelectObject(title: "距离1"),
    DropSelectObject(title: "距离2"),
    DropSelectObject(title: "距离3"),
    DropSelectObject(title: "距离4"),
    DropSelectObject(title: "距离5"),
    DropSelectObject(title: "距离6"),
    DropSelectObject(title: "距离7"),
  ];

  List<DropSelectObject> children2 = [
    DropSelectObject(title: "全部", selectedCleanOther: true, selected: true),
    DropSelectObject(title: "范围1"),
    DropSelectObject(title: "范围2"),
    DropSelectObject(title: "范围3"),
    DropSelectObject(title: "范围4"),
    DropSelectObject(title: "范围5"),
    DropSelectObject(title: "范围6"),
    DropSelectObject(title: "范围7"),
    DropSelectObject(title: "范围8"),
  ];

  List<DropSelectObject> children3 = [
    DropSelectObject(title: "全部", selectedCleanOther: true, selected: true),
    DropSelectObject(title: "路径1"),
    DropSelectObject(title: "路径2"),
    DropSelectObject(title: "路径3"),
    DropSelectObject(title: "路径4"),
    DropSelectObject(title: "路径5"),
  ];

  List<DropSelectObject> children4 = [
    DropSelectObject(title: "全部", selectedCleanOther: true, selected: true),
    DropSelectObject(title: "回家1"),
    DropSelectObject(title: "回家2"),
    DropSelectObject(title: "回家3"),
  ];

  return [
    DropSelectObject(title: "距离", children: children1),
    DropSelectObject(title: "范围", children: children2),
    DropSelectObject(title: "路径", children: children3),
    DropSelectObject(title: "回家", children: children4),
  ];
}
