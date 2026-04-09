![](docs/images/logo.png)

# GSY Flutter Demo

### [English Document](README_EN.md)

### 不同于 [GSYGithubAppFlutter](https://github.com/CarGuo/GSYGithubAppFlutter) 项目，本项目将逐步完善各种 Flutter 独立例子，方便新手学习上手。

[![Github Actions](https://github.com/CarGuo/gsy_flutter_demo/workflows/CI/badge.svg)](https://github.com/CarGuo/gsy_flutter_demo/actions)



## 相关文章

- ## [Flutter系列文章专栏](https://juejin.cn/column/6960546078202527774)

----

- ### 同款 Flutter 完整项目版本 （ https://github.com/CarGuo/gsy_github_app_flutter ）
* ### 同款 Android Compose 版本（ https://github.com/CarGuo/GSYGithubAppCompose ）
* ### 同款 React Native 版 （ https://github.com/CarGuo/GSYGithubApp ）
* ### 同款 Android Kotlin View 版本（ https://github.com/CarGuo/GSYGithubAppKotlin ）
* ### 同款 Weex 版 （ https://github.com/CarGuo/GSYGithubAppWeex ）

- ## [Flutter 完整开发实战详解 Gitbook 预览下载](https://github.com/CarGuo/gsy_flutter_book)



### [Web 版在线测试](https://guoshuyu.cn/home/web/#/)
### [APK 下载](https://github.com/CarGuo/gsy_flutter_demo/releases)

> 目前开始逐步补全完善，主要提供一些有用或者有趣的例子，如果你也有好例子，欢迎提交 PR 。
>
> **运行须知：配置好Flutter开发环境(目前Flutter SDK 版本 *3.35* 以上版本)。**
>
> **[如果克隆太慢或者图片看不到，可尝试从码云地址下载](https://gitee.com/CarGuo/GSYFlutterDemo)**

| 公众号   | 掘金     |  知乎    |  CSDN   |   简书   
|---------|---------|--------- |---------|---------|
| GSYTech  |  [点我](https://juejin.im/user/582aca2ba22b9d006b59ae68/posts)    |   [点我](https://www.zhihu.com/people/carguo)       |   [点我](https://blog.csdn.net/ZuoYueLiang)  |   [点我](https://www.jianshu.com/u/6e613846e1ea)  


|                              |                  |                  |                  |                  |
|------------------------------|------------------|------------------|------------------|------------------|
| ![](docs/images/demo1.gif)   | ![](docs/images/demo2.webp)  | ![](docs/images/demo3.webp)  | ![](docs/images/demo4.webp)  | ![](docs/images/demo5.webp)  |
| ![](docs/images/demo6.webp)  | ![](docs/images/demo7.webp)  | ![](docs/images/demo8.webp)  | ![](docs/images/demo9.webp)  | ![](docs/images/demo10.webp) |
| ![](docs/images/demo11.webp) | ![](docs/images/demo12.webp) | ![](docs/images/demo13.webp) | ![](docs/images/demo14.webp) | ![](docs/images/demo15.webp) |
| ![](docs/images/demo16.webp) | ![](docs/images/demo17.webp) | ![](docs/images/demo18.webp) | ![](docs/images/demo19.webp) | ![](docs/images/demo20.gif)  |
| ![](docs/images/demo21.webp) |  | |  |  |


![](docs/images/demo.jpg)

### demoRoutes（按分类表格）

#### 基础控件（39）

| # | 名称 | 页面文件 |
|---|---|---|
| 1 | 文本输入框简单的 Controller | `widget/basic/controller_demo_page.dart` |
| 2 | 实现控件圆角不同组合 | `widget/basic/clip_demo_page.dart` |
| 6 | 展示渐变带边框的文本 | `widget/basic/gradient_text_demo_page.dart` |
| 7 | Transform 效果展示 | `widget/basic/transform_demo_page.dart` |
| 8 | 计算另类文本行间距展示 | `widget/basic/text_line_height_demo_page.dart` |
| 9 | 简单上下刷新 | `widget/basic/refresh_demo_page.dart` |
| 10 | 简单上下刷新2 | `widget/basic/refresh_demo_page2.dart` |
| 11 | 简单上下刷新3 | `widget/scroll/custom_pull/refresh_demo_page3.dart` |
| 12 | 通过绝对定位布局 | `widget/basic/positioned_demo_page.dart` |
| 13 | 气泡提示框 | `widget/basic/bubble/bubble_demo_page.dart` |
| 14 | Tag效果展示 | `widget/basic/tag_demo_page.dart` |
| 15 | 共享元素跳转效果 | `widget/basic/honor_demo_page.dart` |
| 17 | warpContent实现 | `widget/basic/wrap_content_page.dart` |
| 18 | 状态栏颜色修改（仅 App） | `widget/basic/statusbar_demo_page.dart` |
| 19 | 键盘弹出与监听（仅 App） | `widget/basic/keyboard_demo_page.dart` |
| 22 | 全局悬浮按键效果 | `widget/basic/floating_touch_demo_page.dart` |
| 23 | 全局设置字体大小 | `widget/basic/text_size_demo_page.dart` |
| 24 | 旧版实现富文本 | `widget/basic/rich_text_demo_page.dart` |
| 25 | 官方实现富文本 | `widget/basic/rich_text_demo_page2.dart` |
| 28 | 验证码输入框 | `widget/basic/verification_code_input_demo_page.dart` |
| 29 | 验证码输入框2 | `widget/basic/verification_code_input_demo_page2.dart` |
| 30 | 自定义布局展示效果 | `widget/basic/custom_multi_render_demo_page.dart` |
| 31 | 自定义布局实现云词图展示 | `widget/basic/cloud/cloud_demo_page.dart` |
| 35 | 键盘顶起展示（仅 App） | `widget/basic/input_bottom_demo_page.dart` |
| 42 | 下弹筛选展示效果 | `widget/basic/drop_select_menu/drop_select_demo_page.dart` |
| 48 | 使用 overflow 处理图片 | `widget/basic/overflow_image_page.dart` |
| 49 | 展示 Align 排布控件 | `widget/basic/align_demo_page.dart` |
| 50 | 通过不同尺寸计算方式展示比例 | `widget/basic/card_item_page.dart` |
| 59 | 一个有趣的圆形选择器 | `widget/basic/bottom_anim_nav_page.dart` |
| 60 | 一个类似探探堆叠卡片例子 | `widget/basic/index_stack_drag_card_demo_page.dart` |
| 61 | 一个类似探探堆叠卡片例子2 | `widget/basic/index_stack_drag_card_demo_page2.dart` |
| 70 | 彩色进度条 | `widget/basic/color_progress_demo_page.dart` |
| 72 | 首尾添加数据不会抖动 | `widget/basic/chat_list_scroll_demo_page.dart` |
| 73 | 首尾添加数据不会抖动2 | `widget/basic/chat_list_scroll_demo_page_2.dart` |
| 74 | 测试路由嵌套 | `widget/basic/route_demo_page.dart` |
| 89 | png shadow | `widget/basic/png_shadow_demo_page.dart` |
| 93 | 异步调用的顺序执行 | `widget/basic/async_to_sync_call_page.dart` |
| 110 | Black hole | `widget/visual/black_hole_simulation_page.dart` |
| 114 | 破坏杀·罗针 | `widget/basic/akaza_page.dart` |

#### 列表滚动（31）

| # | 名称 | 页面文件 |
|---|---|---|
| 3 | 列表滑动监听 | `widget/scroll/scroll_listener_demo_page.dart` |
| 4 | 滑动到指定位置 | `widget/scroll/scroll_to_index_demo_page.dart` |
| 5 | 滑动到指定位置2 | `widget/scroll/scroll_to_index_demo_page2.dart` |
| 16 | 滑动验证 | `widget/scroll/slider_verify_page.dart` |
| 26 | 第三方 viewpager 封装实现 | `widget/scroll/viewpager_demo_page.dart` |
| 27 | 列表滑动过程控件停靠效果 | `widget/scroll/sliver_list_demo_page.dart` |
| 32 | 列表滑动停靠 （Stick） | `widget/scroll/stick/stick_demo_page.dart` |
| 33 | 列表滑动停靠 （Stick）+ 展开收回 | `widget/scroll/stick/stick_demo_page2.dart` |
| 34 | 列表滑动停靠效果2 （Stick | `widget/scroll/sliver_stick_demo_page.dart` |
| 40 | 列表滑动过程 item 停靠动画效果 | `widget/scroll/list_anim/list_anim_demo_page.dart` |
| 41 | 列表滑动过程 item 停靠动画效果2 | `widget/scroll/list_anim_2/list_anim_demo_page.dart` |
| 44 | 强大的自定义滑动与停靠结合展示 | `widget/scroll/custom_sliver/scroll_header_demo_page.dart` |
| 45 | 自定义列表内sliver渲染顺序 | `widget/scroll/custom_viewport/custom_viewport_page.dart` |
| 47 | 列表停靠展开+回到当前头部 | `widget/scroll/stick_sliver_list_demo_page.dart` |
| 51 | 多列表+顶部Tab效果展示 | `widget/scroll/sliver_tab_demo_page.dart` |
| 52 | 多列表+顶部Tab效果展示2 | `widget/scroll/sliver_tab_demo_page2.dart` |
| 53 | 多列表+顶部Tab效果展示3 | `widget/scroll/sliver_tab/sliver_tab_demo_page3.dart` |
| 58 | 一个有趣的底部跟随和停靠例子 | `widget/scroll/scroll_inner_content_demo_page.dart` |
| 68 | 类似 boss 直聘我的页面联动效果 | `widget/scroll/link_sliver/link_sliver_demo_page.dart` |
| 77 | ListView 嵌套 ViewPager 解决斜着滑动问题 | `widget/scroll/vp_list_demo_page.dart` |
| 78 | 垂直  ViewPager 嵌套垂直 ListView  | `widget/scroll/vp_list_demo_page.dart` |
| 79 | 垂直  ListView 嵌套垂直  ViewPager | `widget/scroll/vp_list_demo_page.dart` |
| 80 | 垂直  ListView 联动  ListView | `widget/scroll/vp_list_demo_page.dart` |
| 91 | 列表联动 BottomSheet 效果 | `widget/scroll/list_link_bottomsheet_demo_page.dart` |
| 92 | DraggableSheet 的 stick 效果 | `widget/scroll/demo_draggable_sheet_stick_page.dart` |
| 94 | 点击爆炸的五角星（ChatGPT 生成代码） | `widget/scroll/star_bomb_button_page.dart` |
| 97 | 自适应横竖列表 | `widget/scroll/unbounded_listview.dart` |
| 98 | PageView嵌套PageView | `widget/scroll/pageview_in_pageview_demo_page.dart` |
| 100 | link scroll | `widget/scroll/link_scroll_page.dart` |
| 115 | 骚气滑动列表 | `widget/scroll/tornado_scroll_demo.dart` |
| 121 | Shock Wave Chat | `widget/scroll/shock_wave_chat_page.dart` |

#### 动画交互（24）

| # | 名称 | 页面文件 |
|---|---|---|
| 20 | 控件动画组合展示（旋转加放大圆） | `widget/animation/anima_demo_page.dart` |
| 21 | 控件展开动画效果 | `widget/animation/anima_demo_page2.dart` |
| 37 | 控件动画变形效果 | `widget/animation/animation_container_demo_page.dart` |
| 39 | 按键切换动画效果 | `widget/animation/anima_demo_page4.dart` |
| 43 | 文本弹出动画效果 | `widget/animation/anima_demo_page5.dart` |
| 46 | 点击弹出动画提示 | `widget/animation/anim_tip_demo_page.dart` |
| 54 | 仿真书本翻页动画（仅APP） | `widget/animation/book_page/book_page.dart` |
| 55 | 粒子动画效果 | `widget/animation/particle/particle_page.dart` |
| 56 | 动画背景效果 | `widget/animation/anim_bg_demo_page.dart` |
| 62 | 动画按键例子 | `widget/animation/anim_button/anim_button_demo_page.dart` |
| 63 | 类似QQ发送图片的动画 | `widget/animation/anim_progress_img_demo_page.dart` |
| 64 | 类似探探扫描的动画效果 | `widget/animation/anim_scan_demo_page.dart` |
| 65 | 圆弧形的 SeekBar（仅APP） | `widget/animation/arc_seek_bar_demo_page.dart` |
| 66 | 一个国外友人很惊艳的动画效果 | `widget/animation/anim_bubble_gum.dart` |
| 71 | 第三方的动画字体 | `widget/animation/anim_text_demo_page.dart` |
| 76 | 控件动画切换效果 | `widget/animation/anim_switch_layout_demo_page.dart` |
| 96 | 有趣的文本撕裂动画 | `widget/animation/tear_text_demo_page.dart` |
| 104 | 粒子动画 | `widget/animation/attractor_page.dart` |
| 105 | 斐波那契球体动画 | `widget/animation/fibonacci_sphere_page.dart` |
| 107 | 霓虹滑块，100%高亮 | `widget/animation/neon_slider_page.dart` |
| 109 | 炫酷爆炸粒子 | `widget/animation/boom_particle_page.dart` |
| 116 | 骚气粒子效果 | `widget/animation/particle_morphing_page.dart` |
| 117 | 炫酷圣诞树 | `widget/animation/combined_scene_page.dart` |
| 122 | Particle Effect | `widget/animation/particle_effect_screen.dart` |

#### 绘制与Shader（15）

| # | 名称 | 页面文件 |
|---|---|---|
| 36 | Blur 高斯模糊效果 | `widget/canvas/blur_demo_page.dart` |
| 38 | 时钟动画绘制展示 | `widget/canvas/tick_click_demo_page.dart` |
| 57 | 手势效果 | `widget/canvas/matrix_custom_painter_page.dart` |
| 67 | 纯 Canvas 绘制闹钟 | `widget/canvas/canvas_click_demo_page.dart` |
| 69 | 结合 Matrix 的拖拽 | `widget/canvas/drag_img_demo_page.dart` |
| 75 | 测试 canvas 阴影 | `widget/canvas/shader_canvas_demo_page.dart` |
| 85 | 展示 canvas transform | `widget/canvas/transform_canvas_demo_page.dart` |
| 90 | path 路径 png 效果 | `widget/canvas/custom_shader_path_demo_page.dart` |
| 99 | 手势密码 | `widget/basic/gesture_password/gesture_password_demo_page.dart` |
| 101 | glass | `widget/canvas/glass_demo_page.dart` |
| 102 | liquid glass | `widget/canvas/liquid_glass_demo.dart` |
| 103 | liquid glass 2 | `widget/canvas/liquid_glass_demo2.dart` |
| 108 | Radial lines | `widget/canvas/radial_lines_page.dart` |
| 125 | Jaw Control | `widget/canvas/dynamic_jaw_control_page.dart` |
| 126 | Fire Shader | `widget/canvas/fire_shader_demo_page.dart` |

#### 3D与视觉（17）

| # | 名称 | 页面文件 |
|---|---|---|
| 81 | 3D 透视卡片 | `widget/visual/card_perspective_demo_page.dart` |
| 82 | 3D 卡片旋转 | `widget/visual/card_3d_demo_page.dart` |
| 83 | 硬核 3D 卡片旋转 | `widget/visual/card_real_3d_demo_page.dart` |
| 84 | 3D Dash | `widget/visual/dash_3d_demo_page.dart` |
| 86 | rive 掘金 logo | `widget/visual/anim_juejin_logo_demo_page.dart` |
| 87 | 掘金 3d logo | `widget/visual/juejin_3d_logo_demo_page.dart` |
| 88 | 掘金更 3d logo | `widget/visual/juejin_3d_box_logo_demo_page.dart` |
| 95 | 有趣画廊 | `widget/visual/photo_gallery_demo_page.dart` |
| 106 | 星云动画 | `widget/visual/galaxy_scene_page.dart` |
| 111 | 流体太极 | `widget/visual/stream_taichi_page.dart` |
| 112 | 黑洞流体 | `widget/visual/black_hole_page.dart` |
| 113 | 太极粒子 | `widget/visual/taichi_page.dart` |
| 118 | 炫酷二维码 | `widget/visual/notion_qrcode_page.dart` |
| 119 | Cool Disco Sphere | `widget/visual/disco_sphere_page.dart` |
| 120 | Cool Spatial Grid | `widget/visual/spatial_grid_page.dart` |
| 123 | Mosaic Scanner  | `widget/visual/mosaic_scanner_page.dart` |
| 124 | Koi Fish | `widget/visual/koi_fish_animation.dart` |

### 首页分类后的代码目录

- 路由注册文件：`lib/routes/demo_routes.dart`
- 首页与分类逻辑：`lib/home/demo_home_page.dart`
- 分类规则配置（关键词/优先级/手动覆盖）：`lib/home/demo_category_config.dart`
- 多语言资源：`lib/l10n/`
- 示例代码按首页分类整理：
  - `lib/widget/basic/`
  - `lib/widget/scroll/`
  - `lib/widget/animation/`
  - `lib/widget/canvas/`
  - `lib/widget/visual/`

### Deferred 兼容说明

- `deferred-components` 依赖 `package:` 路径，请保持 `pubspec.yaml` 与 `lib/routes/demo_routes.dart` 的路径一致。
- 新增/移动示例时，必须同时更新：
  - `lib/routes/demo_routes.dart` 的 deferred import
  - `pubspec.yaml` 的 `deferred-components.libraries`



### 指定web地址而不是 localhost 的运行命令

```
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8989

flutter build web --web-renderer canvaskit 指定渲染模式
flutter build web --release --web-renderer html 

cp -r ./build/app/intermediates/flutter/release/flutter_assets/ ./build/web/assets

```

### 相关文章

- ### [各种最新 Flutter 文章](https://juejin.im/user/582aca2ba22b9d006b59ae68/posts)
- ### [Flutter 完整实战实战系列文章专栏](http://mp.weixin.qq.com/mp/homepage?__biz=Mzg3NTA3MDIxOA==&hid=2&sn=679ad0212470f5155c4412e678411374&scene=18#wechat_redirect)
- ### [Flutter 番外的世界系列文章专栏](http://mp.weixin.qq.com/mp/homepage?__biz=Mzg3NTA3MDIxOA==&hid=3&sn=bf37119ae2b741a1c71125538bf0cd8d&scene=18#wechat_redirect)


----

- ## [Flutter Github客户端](https://github.com/CarGuo/gsy_github_app_flutter) 

- ## [Flutter 完整开发实战详解 Gitbook 预览下载](https://github.com/CarGuo/GSYFlutterBook)

![公众号](http://img.cdn.guoshuyu.cn/wechat_qq.png)
![](docs/images/thanks.jpg)
