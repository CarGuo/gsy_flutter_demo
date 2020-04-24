import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/anim_button/anim_button_demo_page.dart';
import 'package:gsy_flutter_demo/widget/anim_progress_img_demo_page.dart';
import 'package:gsy_flutter_demo/widget/anim_scan_demo_page.dart';
import 'package:gsy_flutter_demo/widget/bottom_anim_nav_page.dart';
import 'package:gsy_flutter_demo/widget/index_stack_drag_card_demo_page.dart';
import 'package:gsy_flutter_demo/widget/index_stack_drag_card_demo_page2.dart';
import 'package:gsy_flutter_demo/widget/rich_text_demo_page2.dart';
import 'package:gsy_flutter_demo/widget/scroll_inner_content_demo_page.dart';
import 'package:gsy_flutter_demo/widget/align_demo_page.dart';
import 'package:gsy_flutter_demo/widget/anim_bg_demo_page.dart';
import 'package:gsy_flutter_demo/widget/anim_tip_demo_page.dart';
import 'package:gsy_flutter_demo/widget/anima_demo_page.dart';
import 'package:gsy_flutter_demo/widget/anima_demo_page2.dart';
import 'package:gsy_flutter_demo/widget/anima_demo_page4.dart';
import 'package:gsy_flutter_demo/widget/anima_demo_page5.dart';
import 'package:gsy_flutter_demo/widget/animation_container_demo_page.dart';
import 'package:gsy_flutter_demo/widget/blur_demo_page.dart';
import 'package:gsy_flutter_demo/widget/book_page/book_page.dart';
import 'package:gsy_flutter_demo/widget/bubble/bubble_demo_page.dart';
import 'package:gsy_flutter_demo/widget/card_item_page.dart';
import 'package:gsy_flutter_demo/widget/clip_demo_page.dart';
import 'package:gsy_flutter_demo/widget/cloud/cloud_demo_page.dart';
import 'package:gsy_flutter_demo/widget/controller_demo_page.dart';
import 'package:gsy_flutter_demo/widget/custom_multi_render_demo_page.dart';
import 'package:gsy_flutter_demo/widget/custom_pull/refrsh_demo_page3.dart';
import 'package:gsy_flutter_demo/widget/custom_sliver/scroll_header_demo_page.dart';
import 'package:gsy_flutter_demo/widget/drop_select_menu/drop_select_demo_page.dart';
import 'package:gsy_flutter_demo/widget/floating_touch_demo_page.dart';
import 'package:gsy_flutter_demo/widget/honor_demo_page.dart';
import 'package:gsy_flutter_demo/widget/input_bottom_demo_page.dart';
import 'package:gsy_flutter_demo/widget/keyboard_demo_page.dart';
import 'package:gsy_flutter_demo/widget/list_anim/list_anim_demo_page.dart';
import 'package:gsy_flutter_demo/widget/list_anim_2/list_anim_demo_page.dart';
import 'package:gsy_flutter_demo/widget/overflow_image_page.dart';
import 'package:gsy_flutter_demo/widget/particle/particle_page.dart';
import 'package:gsy_flutter_demo/widget/positioned_demo_page.dart';
import 'package:gsy_flutter_demo/widget/refrsh_demo_page.dart';
import 'package:gsy_flutter_demo/widget/refrsh_demo_page2.dart';
import 'package:gsy_flutter_demo/widget/rich_text_demo_page.dart';
import 'package:gsy_flutter_demo/widget/scroll_listener_demo_page.dart';
import 'package:gsy_flutter_demo/widget/scroll_to_index_demo_page.dart';
import 'package:gsy_flutter_demo/widget/scroll_to_index_demo_page2.dart';
import 'package:gsy_flutter_demo/widget/sliver_list_demo_page.dart';
import 'package:gsy_flutter_demo/widget/sliver_stick_demo_page.dart';
import 'package:gsy_flutter_demo/widget/sliver_tab_demo_page.dart';
import 'package:gsy_flutter_demo/widget/sliver_tab_demo_page2.dart';
import 'package:gsy_flutter_demo/widget/sliver_tab/sliver_tab_demo_page3.dart';
import 'package:gsy_flutter_demo/widget/statusbar_demo_page.dart';
import 'package:gsy_flutter_demo/widget/stick/stick_demo_page.dart';
import 'package:gsy_flutter_demo/widget/stick/stick_demo_page2.dart';
import 'package:gsy_flutter_demo/widget/stick_sliver_list_demo_page.dart';
import 'package:gsy_flutter_demo/widget/tag_demo_page.dart';
import 'package:gsy_flutter_demo/widget/matrix_custom_painter_page.dart';
import 'package:gsy_flutter_demo/widget/text_line_height_demo_page.dart';
import 'package:gsy_flutter_demo/widget/text_size_demo_page.dart';
import 'package:gsy_flutter_demo/widget/tick_click_demo_page.dart';
import 'package:gsy_flutter_demo/widget/transform_demo_page.dart';
import 'package:gsy_flutter_demo/widget/verification_code_input_demo_page.dart';
import 'package:gsy_flutter_demo/widget/viewpager_demo_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GSY Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'GSY Flutter Demo'),
      routes: routers,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var routeLists = routers.keys.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: new Container(
        child: new ListView.builder(
          itemBuilder: (context, index) {
            return new InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(routeLists[index]);
              },
              child: new Card(
                child: new Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  height: 50,
                  child: new Text(routers.keys.toList()[index]),
                ),
              ),
            );
          },
          itemCount: routers.length,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Map<String, WidgetBuilder> routers = {
  "文本输入框简单的 Controller": (context) {
    return new ControllerDemoPage();
  },
  "实现控件圆角不同组合": (context) {
    return new ClipDemoPage();
  },
  "列表滑动监听": (context) {
    return new ScrollListenerDemoPage();
  },
  "滑动到指定位置": (context) {
    return new ScrollToIndexDemoPage();
  },
  "滑动到指定位置2": (context) {
    return new ScrollToIndexDemoPage2();
  },
  "Transform 效果展示": (context) {
    return new TransformDemoPage();
  },
  "计算另类文本行间距展示": (context) {
    return new TextLineHeightDemoPage();
  },
  "简单上下刷新": (context) {
    return new RefreshDemoPage();
  },
  "简单上下刷新2": (context) {
    return new RefreshDemoPage2();
  },
  "简单上下刷新3": (context) {
    return new RefreshDemoPage3();
  },
  "通过绝对定位布局": (context) {
    return new PositionedDemoPage();
  },
  "气泡提示框": (context) {
    return new BubbleDemoPage();
  },
  "Tag效果展示": (context) {
    return new TagDemoPage();
  },
  "共享元素跳转效果": (context) {
    return new HonorDemoPage();
  },
  "状态栏颜色修改（仅 App）": (context) {
    return new StatusBarDemoPage();
  },
  "键盘弹出与监听（仅 App）": (context) {
    return new KeyBoardDemoPage();
  },
  "控件动画组合展示（旋转加放大圆）": (context) {
    return new AnimaDemoPage();
  },
  "控件展开动画效果": (context) {
    return new AnimaDemoPage2();
  },
  "全局悬浮按键效果": (context) {
    return new FloatingTouchDemoPage();
  },
  "全局设置字体大小": (context) {
    return new TextSizeDemoPage();
  },
  "旧版实现富文本": (context) {
    return new RichTextDemoPage();
  },
  "官方实现富文本": (context) {
    return new RichTextDemoPage2();
  },
  "第三方 viewpager 封装实现": (context) {
    return new ViewPagerDemoPage();
  },
  "列表滑动过程控件停靠效果": (context) {
    return new SliverListDemoPage();
  },
  "验证码输入框": (context) {
    return new VerificationCodeInputDemoPage();
  },
  "自定义布局展示效果": (context) {
    return new CustomMultiRenderDemoPage();
  },
  "自定义布局实现云词图展示": (context) {
    return new CloudDemoPage();
  },
  "列表滑动停靠 （Stick）": (context) {
    return new StickDemoPage();
  },
  "列表滑动停靠 （Stick）+ 展开收回": (context) {
    return new StickExpendDemoPage();
  },
  "列表滑动停靠效果2 （Stick": (context) {
    return new SliverStickListDemoPage();
  },
  "键盘顶起展示（仅 App）": (context) {
    return new InputBottomDemoPage();
  },
  "Blur 高斯模糊效果": (context) {
    return new BlurDemoPage();
  },
  "控件动画变形效果": (context) {
    return new AnimationContainerDemoPage();
  },
  "时钟动画绘制展示": (context) {
    return new TickClickDemoPage();
  },
  "按键切换动画效果": (context) {
    return new AnimaDemoPage4();
  },
  "列表滑动过程 item 停靠动画效果": (context) {
    return new ListAnimDemoPage();
  },
  "列表滑动过程 item 停靠动画效果2": (context) {
    return new ListAnimDemoPage2();
  },
  "下弹筛选展示效果": (context) {
    return new DropSelectDemoPage();
  },
  "文本弹出动画效果": (context) {
    return new AnimaDemoPage5();
  },
  "强大的自定义滑动与停靠结合展示": (context) {
    return new ScrollHeaderDemoPage();
  },
  "点击弹出动画提示": (context) {
    return new AnimTipDemoPage();
  },
  "列表停靠展开+回到当前头部": (context) {
    return new StickSliverListDemoPage();
  },
  "使用 overflow 处理图片": (context) {
    return new OverflowImagePage();
  },
  "展示 Align 排布控件": (context) {
    return new AlignDemoPage();
  },
  "通过不同尺寸计算方式展示比例": (context) {
    return new CardItemPage();
  },
  "多列表+顶部Tab效果展示": (context) {
    return new SliverTabDemoPage();
  },
  "多列表+顶部Tab效果展示2": (context) {
    return new SliverTabDemoPage2();
  },
  "多列表+顶部Tab效果展示3": (context) {
    return new SliverTabDemoPage3();
  },
  "仿真书本翻页动画（仅APP）": (context) {
    return new BookPage();
  },
  "粒子动画效果": (context) {
    return new ParticlePage();
  },
  "动画背景效果": (context) {
    return new AnimBgDemoPage();
  },
  "手势效果": (context) {
    return new MatrixCustomPainterDemo();
  },
  "一个有趣的底部跟随和停靠例子": (context) {
    return new ScrollInnerContentDemoPage();
  },
  "一个有趣的圆形选择器": (context) {
    return new BottomAnimNavPage();
  },
  "一个类似探探堆叠卡片例子": (context) {
    return new IndexStackDragCardDemoPage();
  },
  "一个类似探探堆叠卡片例子2": (context) {
    return new IndexStackDragCardDemoPage2();
  },
  "动画按键例子": (context) {
    return new AnimButtonDemoPage();
  },
  "类似QQ发送图片的动画": (context) {
    return new AnimProgressImgDemoPage();
  },
  "类似探探扫描的动画效果": (context) {
    return new AnimScanDemoPage();
  },

};
