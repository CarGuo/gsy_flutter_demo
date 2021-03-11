# GSY Flutter Demo

### 不同于 [GSYGithubAppFlutter](https://github.com/CarGuo/GSYGithubAppFlutter) 项目，本项目将逐步完善各种 Flutter 独立例子，方便新手学习上手。


### [Web 版在线测试](https://guoshuyu.cn/home/web/#/)

> 目前开始逐步补全完善，主要提供一些有用或者有趣的例子，如果你也有好例子，环境提交 PR 。
>
> **运行须知：配置好Flutter开发环境(目前Flutter SDK 版本 *2.0* 以上版本)。**
>
> **[如果克隆太慢或者图片看不到，可尝试从码云地址下载](https://gitee.com/CarGuo/GSYFlutterDemo)**

| 公众号   | 掘金     |  知乎    |  CSDN   |   简书   
|---------|---------|--------- |---------|---------|
| GSYTech  |  [点我](https://juejin.im/user/582aca2ba22b9d006b59ae68/posts)    |   [点我](https://www.zhihu.com/people/carguo)       |   [点我](https://blog.csdn.net/ZuoYueLiang)  |   [点我](https://www.jianshu.com/u/6e613846e1ea)  

### GSY新书：[《Flutter开发实战详解》](https://item.jd.com/12883054.html)上架啦：[京东](https://item.jd.com/12883054.html) / [当当](http://product.dangdang.com/28558519.html) / 电子版[京东读书](https://e.jd.com/30624414.html)和[Kindle](https://www.amazon.cn/dp/B08BHQ4TKK/ref=sr_1_5?__mk_zh_CN=亚马逊网站&keywords=flutter&qid=1593498531&s=digital-text&sr=1-5)

[![](http://img.cdn.guoshuyu.cn/WechatIMG65.jpeg)](https://item.jd.com/12883054.html)

![公众号](http://img.cdn.guoshuyu.cn/wechat_qq.png)

### 已有例子

```

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
  "圆弧形的 SeekBar（仅APP）": (context) {
    return new ArcSeekBarDemoPage();
  },
  "一个国外友人很惊艳的动画效果": (context) {
    return new AnimBubbleGumDemoPage();
  },
  "纯 Canvas 绘制闹钟": (context) {
    return new CanvasClickDemoPage();
  },
  "类似 boss 直聘我的页面联动效果": (context) {
    return new LinkSliverDemoPage();
  },
  "结合 Matrix 的拖拽": (context) {
    return new DragImgDemoPage();
  },
  "彩色进度条": (context) {
    return new ColorProgressDemoPage();
  },
};

```


![](demo.jpg)


### 指定web地址而不是 localhost 的运行命令

```
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8989

flutter build web --web-renderer canvaskit 指定渲染模式

```

### 相关文章


- ### [Flutter 完整实战实战系列文章专栏](http://mp.weixin.qq.com/mp/homepage?__biz=Mzg3NTA3MDIxOA==&hid=2&sn=679ad0212470f5155c4412e678411374&scene=18#wechat_redirect)
- ### [Flutter 番外的世界系列文章专栏](http://mp.weixin.qq.com/mp/homepage?__biz=Mzg3NTA3MDIxOA==&hid=3&sn=bf37119ae2b741a1c71125538bf0cd8d&scene=18#wechat_redirect)
* ### [目前各种主流状态管理演示Demo](https://github.com/CarGuo/state_manager_demo)

----

- ## [Flutter Github客户端](https://github.com/CarGuo/gsy_github_app_flutter) 

- ## [Flutter 完整开发实战详解 Gitbook 预览下载](https://github.com/CarGuo/GSYFlutterBook)


![](http://img.cdn.guoshuyu.cn/thanks.jpg)


