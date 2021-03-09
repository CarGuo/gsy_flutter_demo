import 'package:flutter/material.dart';

class IndexStackDragCardDemoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexStackDragCardDemoPageState();
}

class IndexStackDragCardDemoPageState
    extends State<IndexStackDragCardDemoPage> {
  var dataList = [];

  @override
  void initState() {
    super.initState();
    dataList = getDataList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IndexStackDragCardDemoPage"),
      ),
      body: Stack(alignment: Alignment.center, children: getCardList()),
    );
  }

  void removeThis(index) {
    setState(() {
      dataList.removeAt(index);
    });
    if (dataList.length == 0) {
      Future.delayed(Duration(seconds: 0), () {
        setState(() {
          dataList = getDataList();
        });
      });
    }
  }

  getCardItem(index, data) {
    return GestureDetector(
      onTap: () {
        print("###### ${data.name}");
      },
      child: Card(
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0)),
                  image: DecorationImage(
                      image: NetworkImage(data.image), fit: BoxFit.cover),
                ),
                height: 300.0,
                width: 300.0,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  data.name,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.blue,
                  ),
                ),
              )
            ],
          )),
    );
  }

  List<Widget> getCardList() {
    List<Widget> cardList = [];
    var length = dataList.length;
    if (length > 5) {
      length = 5;
    }
    for (int i = length - 1; i >= 0; i--) {
      cardList.add(Positioned.fill(
        child: UnconstrainedBox(
            child: Container(
          child: Draggable(
              onDragEnd: (drag) {
                print("#### ${drag.velocity.pixelsPerSecond} ${drag.offset}");

                ///往下斜着拖
                if (drag.offset.dx.abs() >
                        MediaQuery.of(context).size.width / 2 ||
                    drag.offset.dx < -MediaQuery.of(context).size.width / 4 ||
                    drag.offset.dy.abs() >
                        MediaQuery.of(context).size.height / 2) {
                  removeThis(i);
                }
              },
              childWhenDragging: Container(),
              feedback: getCardItem(i, dataList[i]),
              child: getCardItem(i, dataList[i])),
          margin: EdgeInsets.only(
              top: (i < 5) ? 10 * i.toDouble() : 40,
              left: (i < 5) ? 8 * i.toDouble() : 32),
        )),
      ));
    }
    return cardList;
  }
}

class CardContent {
  String name;
  String image;

  CardContent(this.name, this.image);
}

getDataList() {
  List<CardContent> dataList = [];
  dataList.add(
    CardContent(
      "GSY11111",
      "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1585650373134&di=31e7eb90847ee8d48ad127bde9d22eaf&imgtype=0&src=http%3A%2F%2Fimage.biaobaiju.com%2Fuploads%2F20180211%2F00%2F1518279668-eOiWwMpucR.jpg",
    ),
  );
  dataList.add(
    CardContent(
      "GSY22222",
      "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1585647091624&di=96dd78451ff3adc2fdb11f3356dbe3bf&imgtype=0&src=http%3A%2F%2Fpic1.win4000.com%2Fpic%2F5%2Fb8%2F01ab1170599.jpg",
    ),
  );
  dataList.add(CardContent(
    "GSY33333",
    "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1585647077558&di=e42e59012f863de1b99dbb4a830a4186&imgtype=0&src=http%3A%2F%2Fwww.pig66.com%2Fuploadfile%2F2017%2F1204%2F20171204053020537.png",
  ));
  dataList.add(CardContent(
    "GSY44444",
    "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1585647077558&di=a07ef32f8f3bfdeec82d0d6bf5395f78&imgtype=0&src=http%3A%2F%2Fimg.taopic.com%2Fuploads%2Fallimg%2F120204%2F6447-12020401504047.jpg",
  ));
  dataList.add(
    CardContent(
      "GSY555555",
      "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1585647077558&di=bbcd86551bc585e86a24d98c22d30977&imgtype=0&src=http%3A%2F%2Fimage.biaobaiju.com%2Fuploads%2F20180211%2F01%2F1518283540-LgTZQMHKhb.jpg",
    ),
  );
  dataList.add(
    CardContent(
      "GSY66666",
      "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1585647077558&di=4d9767b11af12151410845d1aefabed1&imgtype=0&src=http%3A%2F%2Fimage.biaobaiju.com%2Fuploads%2F20180803%2F22%2F1533306030-xbmaHzIVwL.jpg",
    ),
  );
  dataList.add(
    CardContent(
      "GSY77777",
      "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1585648363323&di=7b55c0070bb23d35f7bbfc39c3a83ffb&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201710%2F30%2F20171030161534_3482Q.jpeg",
    ),
  );
  dataList.add(
    CardContent(
      "GSY88888",
      "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1160048655,1002586849&fm=26&gp=0.jpg",
    ),
  );
  dataList.add(
    CardContent(
      "GSY99999",
      "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1585648363323&di=6310deecc8099b8b9a2a3e32ffaf7682&imgtype=0&src=http%3A%2F%2Fwww.chabeichong.com%2Fimages%2F2016%2F10%2F21-06155760.jpg",
    ),
  );
  dataList.add(
    CardContent(
      "GSY1010101010",
      "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1585648363323&di=81e91a2863231ccc0f020ad85fc046b9&imgtype=0&src=http%3A%2F%2Fandroid-wallpapers.25pp.com%2Ffs04%2F2015%2F09%2F18%2F3%2F2000_1eb877cabf4cb4a22d4eca7f6fa0d04b_900x675.jpg",
    ),
  );

  return dataList;
}
