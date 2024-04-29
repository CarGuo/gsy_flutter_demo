import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/drop_select_menu/drop_select_object.dart';

import 'drop_select_demo_data.dart';
import 'drop_select_widget.dart';
import 'drop_select_expanded_menu.dart';
import 'drop_select_grid_menu.dart';
import 'drop_select_header.dart';
import 'drop_select_list_menu.dart';
import 'drop_select_menu.dart';

class DropSelectDemoPage extends StatefulWidget {
  const DropSelectDemoPage({super.key});

  @override
  _DropSelectDemoPageState createState() => _DropSelectDemoPageState();
}

class _DropSelectDemoPageState extends State<DropSelectDemoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  DropSelectHeader renderDropSelectHeader() {
    return DropSelectHeader(
      titles: [selectChildGrid[0], selectExpand[0], selectNormal[0]],
      showTitle: (_, index) {
        switch (index) {
          case 0:
            return "title1";
          case 1:
            return "title2";
          case 2:
            return "title3";
        }
        return "title";
      },
    );
  }

  DropSelectMenu renderDropSelectMenu() {
    return DropSelectMenu(
        maxMenuHeight: MediaQuery.sizeOf(context).height,
        menus: [
          DropSelectMenuBuilder(
              builder: (BuildContext context) {
                return DropSelectExpandedListMenu(
                  data: selectExpand,
                  itemBuilder: renderSelectItemGrid,
                );
              },
              height: MediaQuery.sizeOf(context).height),
          DropSelectMenuBuilder(
              builder: (BuildContext context) {
                return DropSelectGridListMenu(
                  data: selectChildGrid,
                  itemBuilder: renderSelectItemGrid,
                );
              },
              height: MediaQuery.sizeOf(context).height),
          DropSelectMenuBuilder(
              builder: (BuildContext context) {
                return DropSelectListMenu(
                  data: selectNormal,
                  singleSelected: true,
                  itemBuilder: renderSelectItem,
                );
              },
              height: kDropSelectMenuItemHeight * selectNormal.length),
        ]);
  }

  Widget renderSelectItem(BuildContext context, DropSelectObject data) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            Text(
              data.title!,
              style: data.selected
                  ? TextStyle(
                      fontSize: 14.0,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w400)
                  : const TextStyle(fontSize: 14.0),
            ),
            Expanded(
                child: Align(
              alignment: Alignment.centerRight,
              child: data.selected
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
            )),
          ],
        ));
  }

  Widget renderSelectItemGrid(BuildContext context, DropSelectObject data) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
              color:
                  data.selected ? Theme.of(context).primaryColor : Colors.grey,
              width: 1.0),
        ),
        child: Text(
          data.title!,
          style: data.selected
              ? TextStyle(
                  fontSize: 14.0,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w400)
              : const TextStyle(fontSize: 14.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DropSelectDemoPage"),
      ),
      body: DropSelectMenuContainer(
        child: Column(
          children: <Widget>[
            renderDropSelectHeader(),
            Expanded(
              child: Stack(
                children: <Widget>[
                  ListView(
                    children: List.generate(100, (index) {
                      return Container(
                        height: 40,
                        margin: const EdgeInsets.only(left: 10),
                        child: Text("Text $index"),
                      );
                    }),
                  ),
                  Column(
                    children: <Widget>[
                      Expanded(child: renderDropSelectMenu()),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
