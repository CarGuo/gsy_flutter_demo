import 'package:flutter/cupertino.dart';
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
    return new DropSelectHeader(
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
    return new DropSelectMenu(
        maxMenuHeight: MediaQuery.of(context).size.height,
        menus: [
          new DropSelectMenuBuilder(
              builder: (BuildContext context) {
                return new DropSelectExpandedListMenu(
                  data: selectExpand,
                  itemBuilder: renderSelectItemGrid,
                );
              },
              height: MediaQuery.of(context).size.height),
          new DropSelectMenuBuilder(
              builder: (BuildContext context) {
                return new DropSelectGridListMenu(
                  data: selectChildGrid,
                  itemBuilder: renderSelectItemGrid,
                );
              },
              height: MediaQuery.of(context).size.height),
          new DropSelectMenuBuilder(
              builder: (BuildContext context) {
                return new DropSelectListMenu(
                  data: selectNormal,
                  singleSelected: true,
                  itemBuilder: renderSelectItem,
                );
              },
              height: kDropSelectMenuItemHeight * selectNormal.length),
        ]);
  }

  Widget renderSelectItem(BuildContext context, DropSelectObject data) {
    return new Padding(
        padding: new EdgeInsets.all(10.0),
        child: new Row(
          children: <Widget>[
            new Text(
              data.title,
              style: data.selected
                  ? new TextStyle(
                      fontSize: 14.0,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w400)
                  : new TextStyle(fontSize: 14.0),
            ),
            new Expanded(
                child: new Align(
              alignment: Alignment.centerRight,
              child: data.selected
                  ? new Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
            )),
          ],
        ));
  }

  Widget renderSelectItemGrid(BuildContext context, DropSelectObject data) {
    return new Container(
      padding: new EdgeInsets.all(10.0),
      child: new Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
              color:
                  data.selected ? Theme.of(context).primaryColor : Colors.grey,
              width: 1.0),
        ),
        child: new Text(
          data.title,
          style: data.selected
              ? new TextStyle(
                  fontSize: 14.0,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w400)
              : new TextStyle(fontSize: 14.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("DropSelectDemoPage"),
      ),
      body: Container(
        child: new DropSelectMenuContainer(
          child: new Column(
            children: <Widget>[
              renderDropSelectHeader(),
              new Expanded(
                child: new Stack(
                  children: <Widget>[
                    new ListView(
                      children: List.generate(100, (index) {
                        return Container(
                          height: 40,
                          margin: EdgeInsets.only(left: 10),
                          child: new Text("Text $index"),
                        );
                      }),
                    ),
                    new Column(
                      children: <Widget>[
                        new Expanded(child: renderDropSelectMenu()),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
