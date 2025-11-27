![](./logo.png)

# GSY Flutter Demo

### [中文文档](README.md)

### Unlike the [GSYGithubAppFlutter](https://github.com/CarGuo/GSYGithubAppFlutter) project, this project will gradually improve various Flutter independent examples, making it easier for beginners to learn and get started.

[![Github Actions](https://github.com/CarGuo/gsy_flutter_demo/workflows/CI/badge.svg)](https://github.com/CarGuo/gsy_flutter_demo/actions)

## Related Articles

- ## [Flutter Article Series Column](https://juejin.cn/column/6960546078202527774)

----

- ### Flutter Complete Project Version ( https://github.com/CarGuo/gsy_github_app_flutter )
* ### Android Compose Version ( https://github.com/CarGuo/GSYGithubAppCompose )
* ### React Native Version ( https://github.com/CarGuo/GSYGithubApp )
* ### Android Kotlin View Version ( https://github.com/CarGuo/GSYGithubAppKotlin )
* ### Weex Version ( https://github.com/CarGuo/GSYGithubAppWeex )

- ## [Flutter Complete Development Guide Gitbook Preview & Download](https://github.com/CarGuo/gsy_flutter_book)

### [Web Version Online Testing](https://guoshuyu.cn/home/web/#/)
### [APK Download](https://github.com/CarGuo/gsy_flutter_demo/releases)

> Currently gradually completing and improving, mainly providing some useful or interesting examples. If you have good examples, please submit a PR.
>
> **Running Instructions: Configure Flutter development environment (currently requires Flutter SDK version *3.35* or above).**
>
> **[If cloning is too slow or images cannot be displayed, try downloading from Gitee](https://gitee.com/CarGuo/GSYFlutterDemo)**

| WeChat Official Account | Juejin | Zhihu | CSDN | Jianshu |
|---------|---------|---------|---------|---------|
| GSYTech | [Link](https://juejin.im/user/582aca2ba22b9d006b59ae68/posts) | [Link](https://www.zhihu.com/people/carguo) | [Link](https://blog.csdn.net/ZuoYueLiang) | [Link](https://www.jianshu.com/u/6e613846e1ea) |

### GSY Book: [《Flutter Development Guide》](https://item.jd.com/12883054.html) Available at: [JD.com](https://item.jd.com/12883054.html) / [Dangdang](http://product.dangdang.com/28558519.html) / E-book [JD Reading](https://e.jd.com/30624414.html) and [Kindle](https://www.amazon.cn/dp/B08BHQ4TKK/ref=sr_1_5?__mk_zh_CN=亚马逊网站&keywords=flutter&qid=1593498531&s=digital-text&sr=1-5)

[![](http://img.cdn.guoshuyu.cn/WechatIMG65.jpeg)](https://item.jd.com/12883054.html)


|    |                 |                 | 
|---------|-----------------|-----------------|
| ![](demo1.gif)  | ![](demo2.webp) | ![](demo3.webp) | 

![](demo.jpg)

### Available Examples

```dart
Map<String, WidgetBuilder> routers = {
  "Text Input with Simple Controller": (context) {
    return ContainerAsyncRouterPage(controller_demo_page.loadLibrary(),
            (context) {
          return controller_demo_page.ControllerDemoPage();
        });
  },
  "Implementing Different Corner Radius Combinations": (context) {
    return ContainerAsyncRouterPage(clip_demo_page.loadLibrary(), (context) {
      return clip_demo_page.ClipDemoPage();
    });
  },
  "List Scroll Listener": (context) {
    return ContainerAsyncRouterPage(scroll_listener_demo_page.loadLibrary(),
            (context) {
          return scroll_listener_demo_page.ScrollListenerDemoPage();
        });
  },
  "Scroll to Specified Position": (context) {
    return ContainerAsyncRouterPage(scroll_to_index_demo_page.loadLibrary(),
            (context) {
          return scroll_to_index_demo_page.ScrollToIndexDemoPage();
        });
  },
  "Scroll to Specified Position 2": (context) {
    return ContainerAsyncRouterPage(scroll_to_index_demo_page2.loadLibrary(),
            (context) {
          return scroll_to_index_demo_page2.ScrollToIndexDemoPage2();
        });
  },
  "Display Gradient Text with Border": (context) {
    return ContainerAsyncRouterPage(gradient_text_demo_page.loadLibrary(),
            (context) {
          return gradient_text_demo_page.GradientTextDemoPage();
        });
  },
  "Transform Effect Display": (context) {
    return ContainerAsyncRouterPage(transform_demo_page.loadLibrary(),
            (context) {
          return transform_demo_page.TransformDemoPage();
        });
  },
  "Calculate Alternative Text Line Height Display": (context) {
    return ContainerAsyncRouterPage(text_line_height_demo_page.loadLibrary(),
            (context) {
          return text_line_height_demo_page.TextLineHeightDemoPage();
        });
  },
  "Simple Pull-to-Refresh": (context) {
    return ContainerAsyncRouterPage(refrsh_demo_page.loadLibrary(), (context) {
      return refrsh_demo_page.RefreshDemoPage();
    });
  },
  "Simple Pull-to-Refresh 2": (context) {
    return ContainerAsyncRouterPage(refrsh_demo_page2.loadLibrary(), (context) {
      return refrsh_demo_page2.RefreshDemoPage2();
    });
  },
  "Simple Pull-to-Refresh 3": (context) {
    return ContainerAsyncRouterPage(refrsh_demo_page3.loadLibrary(), (context) {
      return refrsh_demo_page3.RefreshDemoPage3();
    });
  },
  "Absolute Positioning Layout": (context) {
    return ContainerAsyncRouterPage(positioned_demo_page.loadLibrary(),
            (context) {
          return positioned_demo_page.PositionedDemoPage();
        });
  },
  "Bubble Tooltip": (context) {
    return ContainerAsyncRouterPage(bubble_demo_page.loadLibrary(), (context) {
      return bubble_demo_page.BubbleDemoPage();
    });
  },
  "Tag Effect Display": (context) {
    return ContainerAsyncRouterPage(tag_demo_page.loadLibrary(), (context) {
      return tag_demo_page.TagDemoPage();
    });
  },
  "Shared Element Transition Effect": (context) {
    return ContainerAsyncRouterPage(honor_demo_page.loadLibrary(), (context) {
      return honor_demo_page.HonorDemoPage();
    });
  },
  "Slide Verification": (context) {
    return ContainerAsyncRouterPage(silder_verify_page.loadLibrary(),
            (context) {
          return silder_verify_page.SlideVerifyPage();
        });
  },
  "Wrap Content Implementation": (context) {
    return ContainerAsyncRouterPage(wrap_content_page.loadLibrary(), (context) {
      return wrap_content_page.WrapContentPage();
    });
  },
  "Status Bar Color Modification (App Only)": (context) {
    return ContainerAsyncRouterPage(statusbar_demo_page.loadLibrary(),
            (context) {
          return statusbar_demo_page.StatusBarDemoPage();
        });
  },
  "Key Sample Application": (context) {
    return ContainerAsyncRouterPage(key_demo_page.loadLibrary(), (context) {
      return key_demo_page.KeyDemoPage();
    });
  },
  "Download Button Animation": (context) {
    return ContainerAsyncRouterPage(circle_download_button_widget.loadLibrary(),
            (context) {
          return circle_download_button_widget.DownloadDemoPage();
        });
  },
  "Sticky Header": (context) {
    return ContainerAsyncRouterPage(stick_demo_page.loadLibrary(), (context) {
      return stick_demo_page.StickDemoPage();
    });
  },
  "Sticky Header 2": (context) {
    return ContainerAsyncRouterPage(stick_demo_page2.loadLibrary(), (context) {
      return stick_demo_page2.StickDemoPage2();
    });
  },
  "Animated Text": (context) {
    return ContainerAsyncRouterPage(animated_text_demo_page.loadLibrary(),
            (context) {
          return animated_text_demo_page.AnimatedTextDemoPage();
        });
  },
  "Verification Input Box": (context) {
    return ContainerAsyncRouterPage(verification_input_demo_page.loadLibrary(),
            (context) {
          return verification_input_demo_page.VerificationInputDemoPage();
        });
  },
  "Rich Text Demo 1": (context) {
    return ContainerAsyncRouterPage(rich_text_demo_page.loadLibrary(),
            (context) {
          return rich_text_demo_page.RichTextDemoPage();
        });
  },
  "Rich Text Demo 2": (context) {
    return ContainerAsyncRouterPage(rich_text_demo_page2.loadLibrary(),
            (context) {
          return rich_text_demo_page2.RichTextDemoPage2();
        });
  },
  "Canvas Drawing Demo": (context) {
    return ContainerAsyncRouterPage(canvas_demo_page.loadLibrary(), (context) {
      return canvas_demo_page.CanvasDemoPage();
    });
  },
  "Horizontal ListView": (context) {
    return ContainerAsyncRouterPage(horizontal_line_demo_page.loadLibrary(),
            (context) {
          return horizontal_line_demo_page.HorizontalLineDemoPage();
        });
  },
  "ListView Item Size": (context) {
    return ContainerAsyncRouterPage(listview_item_size_page.loadLibrary(),
            (context) {
          return listview_item_size_page.ListViewItemSizePage();
        });
  },
  "Card Inner Scrolling List": (context) {
    return ContainerAsyncRouterPage(card_list_demo_page.loadLibrary(),
            (context) {
          return card_list_demo_page.CardListDemoPage();
        });
  },
  "Keyboard Open/Close Listener": (context) {
    return ContainerAsyncRouterPage(keyboard_open_close_demo_page.loadLibrary(),
            (context) {
          return keyboard_open_close_demo_page.KeyboardOpenCloseDemoPage();
        });
  },
  "Gesture Overlay Problem": (context) {
    return ContainerAsyncRouterPage(gesture_page.loadLibrary(), (context) {
      return gesture_page.GesturePage();
    });
  },
  "Neumorphism Widget": (context) {
    return ContainerAsyncRouterPage(neuro_widget_demo.loadLibrary(), (context) {
      return neuro_widget_demo.NeuroWidgetDemo();
    });
  },
  "Text Adaptive Size": (context) {
    return ContainerAsyncRouterPage(text_size_demo_page.loadLibrary(),
            (context) {
          return text_size_demo_page.TextSizeDemoPage();
        });
  },
  "Text Fit Size Based on Size": (context) {
    return ContainerAsyncRouterPage(
        text_fit_size_demo_page.loadLibrary(), (context) {
      return text_fit_size_demo_page.TextFitSizeDemoPage();
    });
  },
  "Align Text Baseline": (context) {
    return ContainerAsyncRouterPage(text_baseline_demo_page.loadLibrary(),
            (context) {
          return text_baseline_demo_page.TextBaselineDemoPage();
        });
  },
  "Scrollable Positioned": (context) {
    return ContainerAsyncRouterPage(scrollable_positioned_page.loadLibrary(),
            (context) {
          return scrollable_positioned_page.ScrollablePositionedPage();
        });
  },
  "Underline Tab Indicator": (context) {
    return ContainerAsyncRouterPage(underline_tab_indicator_page.loadLibrary(),
            (context) {
          return underline_tab_indicator_page.UnderlineTabIndicatorPage();
        });
  },
  "Linkable Scrolling List Views": (context) {
    return ContainerAsyncRouterPage(link_scroll_page.loadLibrary(), (context) {
      return link_scroll_page.LinkListViewPage();
    });
  },
  "Two-Level NestedScrollView": (context) {
    return ContainerAsyncRouterPage(nested_refresh_list_page.loadLibrary(),
            (context) {
          return nested_refresh_list_page.NestedRefreshListPage();
        });
  },
  "Three-Level NestedScrollView": (context) {
    return ContainerAsyncRouterPage(nested_refresh_list_page2.loadLibrary(),
            (context) {
          return nested_refresh_list_page2.NestedRefreshListPage2();
        });
  },
  "Float Tab Nested Widget": (context) {
    return ContainerAsyncRouterPage(float_tab_nested_page.loadLibrary(),
            (context) {
          return float_tab_nested_page.FloatTabNestedPage();
        });
  },
  "Sliver Custom Widget": (context) {
    return ContainerAsyncRouterPage(
        sliver_custom_widget_demo_page.loadLibrary(), (context) {
      return sliver_custom_widget_demo_page.SliverCustomWidgetDemoPage();
    });
  },
  "Inner Widget Drag": (context) {
    return ContainerAsyncRouterPage(inner_drag_page.loadLibrary(), (context) {
      return inner_drag_page.InnerDragPage();
    });
  },
  "Rive Animation": (context) {
    return ContainerAsyncRouterPage(rive_demo_page.loadLibrary(), (context) {
      return rive_demo_page.RiveDemoPage();
    });
  },
  "Rive Animation 2": (context) {
    return ContainerAsyncRouterPage(rive_demo_page2.loadLibrary(), (context) {
      return rive_demo_page2.RiveDemoPage2();
    });
  },
  "Lottie Animation": (context) {
    return ContainerAsyncRouterPage(lottie_demo_page.loadLibrary(), (context) {
      return lottie_demo_page.LottieDemoPage();
    });
  },
  "Liquid Animation": (context) {
    return ContainerAsyncRouterPage(animation_demo_page.loadLibrary(),
            (context) {
          return animation_demo_page.AnimationDemoPage();
        });
  },
  "Text Gradient Animation": (context) {
    return ContainerAsyncRouterPage(text_gradient_demo_page.loadLibrary(),
            (context) {
          return text_gradient_demo_page.TextGradientDemoPage();
        });
  },
  "Animated Switch": (context) {
    return ContainerAsyncRouterPage(animated_switch_demo_page.loadLibrary(),
            (context) {
          return animated_switch_demo_page.AnimatedSwitchDemoPage();
        });
  },
  "3D Card Flip Effect": (context) {
    return ContainerAsyncRouterPage(
        animated_flip_card_demo_page.loadLibrary(), (context) {
      return animated_flip_card_demo_page.AnimatedFlipCardDemoPage();
    });
  },
  "Blur Effect": (context) {
    return ContainerAsyncRouterPage(blur_demo_page.loadLibrary(), (context) {
      return blur_demo_page.BlurDemoPage();
    });
  },
  "Swipe Button": (context) {
    return ContainerAsyncRouterPage(swipe_button_demo_page.loadLibrary(),
            (context) {
          return swipe_button_demo_page.SwipeButtonDemoPage();
        });
  },
  "Wave Animation": (context) {
    return ContainerAsyncRouterPage(wave_demo_page.loadLibrary(), (context) {
      return wave_demo_page.WaveDemoPage();
    });
  },
  "Progress Widget with Gradient": (context) {
    return ContainerAsyncRouterPage(progress_demo_page.loadLibrary(),
            (context) {
          return progress_demo_page.ProgressDemoPage();
        });
  },
  "AnimatedList Dynamic Add/Remove": (context) {
    return ContainerAsyncRouterPage(animated_list_demo_page.loadLibrary(),
            (context) {
          return animated_list_demo_page.AnimatedListDemoPage();
        });
  },
  "Web In-App Browser": (context) {
    return ContainerAsyncRouterPage(web_view_demo_page.loadLibrary(),
            (context) {
          return web_view_demo_page.WebViewDemoPage();
        });
  },
  "Window Size Change Listener": (context) {
    return ContainerAsyncRouterPage(window_demo_page.loadLibrary(), (context) {
      return window_demo_page.WindowDemoPage();
    });
  },
  "Chart Display": (context) {
    return ContainerAsyncRouterPage(chart_demo_page.loadLibrary(), (context) {
      return chart_demo_page.ChartDemoPage();
    });
  },
  "Shader Effect Demo": (context) {
    return ContainerAsyncRouterPage(shader_demo_page.loadLibrary(), (context) {
      return shader_demo_page.ShaderDemoPage();
    });
  },
  "Shader Effect Demo 2": (context) {
    return ContainerAsyncRouterPage(shader_demo_page2.loadLibrary(), (context) {
      return shader_demo_page2.ShaderDemoPage2();
    });
  },
  "State Management (InheritedWidget)": (context) {
    return ContainerAsyncRouterPage(state_demo_page.loadLibrary(), (context) {
      return state_demo_page.StateDemoPage();
    });
  },
  "State Management (ChangeNotifier)": (context) {
    return ContainerAsyncRouterPage(state_demo_page2.loadLibrary(), (context) {
      return state_demo_page2.StateDemoPage2();
    });
  },
  "State Management (ValueNotifier)": (context) {
    return ContainerAsyncRouterPage(state_demo_page3.loadLibrary(), (context) {
      return state_demo_page3.StateDemoPage3();
    });
  },
  "Background Process Demo": (context) {
    return ContainerAsyncRouterPage(isolate_demo_page.loadLibrary(), (context) {
      return isolate_demo_page.IsolateDemoPage();
    });
  },
  "FFI Plugin Demo (Desktop)": (context) {
    return ContainerAsyncRouterPage(ffi_demo_page.loadLibrary(), (context) {
      return ffi_demo_page.FFIDemoPage();
    });
  },
  "MethodChannel Demo": (context) {
    return ContainerAsyncRouterPage(method_demo_page.loadLibrary(), (context) {
      return method_demo_page.MethodDemoPage();
    });
  },
  "Image Picker Demo": (context) {
    return ContainerAsyncRouterPage(image_picker_demo_page.loadLibrary(),
            (context) {
          return image_picker_demo_page.ImagePickerDemoPage();
        });
  },
  "Video Player Demo": (context) {
    return ContainerAsyncRouterPage(video_demo_page.loadLibrary(), (context) {
      return video_demo_page.VideoDemoPage();
    });
  },
  "PlatformView Demo (Native View Integration)": (context) {
    return ContainerAsyncRouterPage(platform_view_demo_page.loadLibrary(),
            (context) {
          return platform_view_demo_page.PlatformViewDemoPage();
        });
  },
  "Local Notification": (context) {
    return ContainerAsyncRouterPage(notification_demo_page.loadLibrary(),
            (context) {
          return notification_demo_page.NotificationDemoPage();
        });
  },
  "System Lifecycle Events": (context) {
    return ContainerAsyncRouterPage(lifecycle_demo_page.loadLibrary(),
            (context) {
          return lifecycle_demo_page.LifecycleDemoPage();
        });
  },
  "InkWell Ripple Effect": (context) {
    return ContainerAsyncRouterPage(inkwell_demo_page.loadLibrary(), (context) {
      return inkwell_demo_page.InkWellDemoPage();
    });
  },
  "Custom Painter Example": (context) {
    return ContainerAsyncRouterPage(painter_demo_page.loadLibrary(), (context) {
      return painter_demo_page.PainterDemoPage();
    });
  },
  "QR Code Generator": (context) {
    return ContainerAsyncRouterPage(qr_demo_page.loadLibrary(), (context) {
      return qr_demo_page.QrDemoPage();
    });
  },
  "Calendar Widget": (context) {
    return ContainerAsyncRouterPage(calendar_demo_page.loadLibrary(),
            (context) {
          return calendar_demo_page.CalendarDemoPage();
        });
  },
  "File Operation Demo": (context) {
    return ContainerAsyncRouterPage(file_demo_page.loadLibrary(), (context) {
      return file_demo_page.FileDemoPage();
    });
  },
  "Database Demo (SQLite)": (context) {
    return ContainerAsyncRouterPage(db_demo_page.loadLibrary(), (context) {
      return db_demo_page.DbDemoPage();
    });
  },
  "SharedPreferences Demo": (context) {
    return ContainerAsyncRouterPage(sp_demo_page.loadLibrary(), (context) {
      return sp_demo_page.SpDemoPage();
    });
  },
  "Network Request Demo": (context) {
    return ContainerAsyncRouterPage(http_demo_page.loadLibrary(), (context) {
      return http_demo_page.HttpDemoPage();
    });
  },
  "JSON Serialization Demo": (context) {
    return ContainerAsyncRouterPage(json_demo_page.loadLibrary(), (context) {
      return json_demo_page.JsonDemoPage();
    });
  },
  "Stream & StreamBuilder": (context) {
    return ContainerAsyncRouterPage(stream_demo_page.loadLibrary(), (context) {
      return stream_demo_page.StreamDemoPage();
    });
  },
  "Future & FutureBuilder": (context) {
    return ContainerAsyncRouterPage(future_demo_page.loadLibrary(), (context) {
      return future_demo_page.FutureDemoPage();
    });
  },
  "Async & Await": (context) {
    return ContainerAsyncRouterPage(async_demo_page.loadLibrary(), (context) {
      return async_demo_page.AsyncDemoPage();
    });
  },
  "Permission Request Demo": (context) {
    return ContainerAsyncRouterPage(permission_demo_page.loadLibrary(),
            (context) {
          return permission_demo_page.PermissionDemoPage();
        });
  },
  "Internationalization (i18n)": (context) {
    return ContainerAsyncRouterPage(i18n_demo_page.loadLibrary(), (context) {
      return i18n_demo_page.I18nDemoPage();
    });
  },
  "Theme Switching": (context) {
    return ContainerAsyncRouterPage(theme_demo_page.loadLibrary(), (context) {
      return theme_demo_page.ThemeDemoPage();
    });
  },
  "Dark Mode": (context) {
    return ContainerAsyncRouterPage(dark_demo_page.loadLibrary(), (context) {
      return dark_demo_page.DarkDemoPage();
    });
  },
  "Custom Font": (context) {
    return ContainerAsyncRouterPage(font_demo_page.loadLibrary(), (context) {
      return font_demo_page.FontDemoPage();
    });
  },
  "Adaptive Layout (Responsive)": (context) {
    return ContainerAsyncRouterPage(adaptive_demo_page.loadLibrary(),
            (context) {
          return adaptive_demo_page.AdaptiveDemoPage();
        });
  },
  "Navigation 2.0 Router": (context) {
    return ContainerAsyncRouterPage(router_demo_page.loadLibrary(), (context) {
      return router_demo_page.RouterDemoPage();
    });
  },
  "Deep Link": (context) {
    return ContainerAsyncRouterPage(deep_link_demo_page.loadLibrary(),
            (context) {
          return deep_link_demo_page.DeepLinkDemoPage();
        });
  },
  "WebSocket Demo": (context) {
    return ContainerAsyncRouterPage(websocket_demo_page.loadLibrary(),
            (context) {
          return websocket_demo_page.WebSocketDemoPage();
        });
  },
  "Battery Info": (context) {
    return ContainerAsyncRouterPage(battery_demo_page.loadLibrary(), (context) {
      return battery_demo_page.BatteryDemoPage();
    });
  },
  "Device Info": (context) {
    return ContainerAsyncRouterPage(device_demo_page.loadLibrary(), (context) {
      return device_demo_page.DeviceDemoPage();
    });
  },
  "Package Info": (context) {
    return ContainerAsyncRouterPage(package_demo_page.loadLibrary(), (context) {
      return package_demo_page.PackageDemoPage();
    });
  },
  "Connectivity Check": (context) {
    return ContainerAsyncRouterPage(connectivity_demo_page.loadLibrary(),
            (context) {
          return connectivity_demo_page.ConnectivityDemoPage();
        });
  },
  "Share Plugin": (context) {
    return ContainerAsyncRouterPage(share_demo_page.loadLibrary(), (context) {
      return share_demo_page.ShareDemoPage();
    });
  },
  "URL Launcher": (context) {
    return ContainerAsyncRouterPage(url_launcher_demo_page.loadLibrary(),
            (context) {
          return url_launcher_demo_page.UrlLauncherDemoPage();
        });
  },
  "Path Provider": (context) {
    return ContainerAsyncRouterPage(path_demo_page.loadLibrary(), (context) {
      return path_demo_page.PathDemoPage();
    });
  },
  "Location Service": (context) {
    return ContainerAsyncRouterPage(location_demo_page.loadLibrary(), (context) {
      return location_demo_page.LocationDemoPage();
    });
  },
  "Map Integration": (context) {
    return ContainerAsyncRouterPage(map_demo_page.loadLibrary(), (context) {
      return map_demo_page.MapDemoPage();
    });
  },
  "Camera Demo": (context) {
    return ContainerAsyncRouterPage(camera_demo_page.loadLibrary(), (context) {
      return camera_demo_page.CameraDemoPage();
    });
  },
  "Barcode Scanner": (context) {
    return ContainerAsyncRouterPage(barcode_demo_page.loadLibrary(), (context) {
      return barcode_demo_page.BarcodeDemoPage();
    });
  },
  "Biometric Authentication": (context) {
    return ContainerAsyncRouterPage(biometric_demo_page.loadLibrary(),
            (context) {
          return biometric_demo_page.BiometricDemoPage();
        });
  },
  "Firebase Integration": (context) {
    return ContainerAsyncRouterPage(firebase_demo_page.loadLibrary(), (context) {
      return firebase_demo_page.FirebaseDemoPage();
    });
  },
  "Crashlytics": (context) {
    return ContainerAsyncRouterPage(crashlytics_demo_page.loadLibrary(),
            (context) {
          return crashlytics_demo_page.CrashlyticsDemoPage();
        });
  },
  "Analytics": (context) {
    return ContainerAsyncRouterPage(analytics_demo_page.loadLibrary(),
            (context) {
          return analytics_demo_page.AnalyticsDemoPage();
        });
  },
  "Push Notification": (context) {
    return ContainerAsyncRouterPage(push_demo_page.loadLibrary(), (context) {
      return push_demo_page.PushDemoPage();
    });
  },
  "In-App Purchase": (context) {
    return ContainerAsyncRouterPage(iap_demo_page.loadLibrary(), (context) {
      return iap_demo_page.IAPDemoPage();
    });
  },
  "AdMob Integration": (context) {
    return ContainerAsyncRouterPage(admob_demo_page.loadLibrary(), (context) {
      return admob_demo_page.AdMobDemoPage();
    });
  },
  "Social Login (Google/Facebook)": (context) {
    return ContainerAsyncRouterPage(social_login_demo_page.loadLibrary(),
            (context) {
          return social_login_demo_page.SocialLoginDemoPage();
        });
  },
  "Audio Player": (context) {
    return ContainerAsyncRouterPage(audio_demo_page.loadLibrary(), (context) {
      return audio_demo_page.AudioDemoPage();
    });
  },
  "Audio Recorder": (context) {
    return ContainerAsyncRouterPage(audio_record_demo_page.loadLibrary(),
            (context) {
          return audio_record_demo_page.AudioRecordDemoPage();
        });
  },
  "Speech to Text": (context) {
    return ContainerAsyncRouterPage(stt_demo_page.loadLibrary(), (context) {
      return stt_demo_page.STTDemoPage();
    });
  },
  "Text to Speech": (context) {
    return ContainerAsyncRouterPage(tts_demo_page.loadLibrary(), (context) {
      return tts_demo_page.TTSDemoPage();
    });
  },
  "Bluetooth Demo": (context) {
    return ContainerAsyncRouterPage(bluetooth_demo_page.loadLibrary(),
            (context) {
          return bluetooth_demo_page.BluetoothDemoPage();
        });
  },
  "NFC Demo": (context) {
    return ContainerAsyncRouterPage(nfc_demo_page.loadLibrary(), (context) {
      return nfc_demo_page.NFCDemoPage();
    });
  },
  "Sensor Demo (Accelerometer)": (context) {
    return ContainerAsyncRouterPage(sensor_demo_page.loadLibrary(), (context) {
      return sensor_demo_page.SensorDemoPage();
    });
  },
  "Vibration": (context) {
    return ContainerAsyncRouterPage(vibration_demo_page.loadLibrary(),
            (context) {
          return vibration_demo_page.VibrationDemoPage();
        });
  },
  "Flashlight": (context) {
    return ContainerAsyncRouterPage(flashlight_demo_page.loadLibrary(),
            (context) {
          return flashlight_demo_page.FlashlightDemoPage();
        });
  },
  "Screen Brightness": (context) {
    return ContainerAsyncRouterPage(brightness_demo_page.loadLibrary(),
            (context) {
          return brightness_demo_page.BrightnessDemoPage();
        });
  },
  "Screen Orientation": (context) {
    return ContainerAsyncRouterPage(orientation_demo_page.loadLibrary(),
            (context) {
          return orientation_demo_page.OrientationDemoPage();
        });
  },
  "Full Screen Mode": (context) {
    return ContainerAsyncRouterPage(fullscreen_demo_page.loadLibrary(),
            (context) {
          return fullscreen_demo_page.FullscreenDemoPage();
        });
  },
  "Wake Lock": (context) {
    return ContainerAsyncRouterPage(wakelock_demo_page.loadLibrary(), (context) {
      return wakelock_demo_page.WakeLockDemoPage();
    });
  },
  "App Icon Badge": (context) {
    return ContainerAsyncRouterPage(badge_demo_page.loadLibrary(), (context) {
      return badge_demo_page.BadgeDemoPage();
    });
  },
  "Launch Review": (context) {
    return ContainerAsyncRouterPage(review_demo_page.loadLibrary(), (context) {
      return review_demo_page.ReviewDemoPage();
    });
  },
  "Store Redirect": (context) {
    return ContainerAsyncRouterPage(store_demo_page.loadLibrary(), (context) {
      return store_demo_page.StoreDemoPage();
    });
  },
  "Email Sender": (context) {
    return ContainerAsyncRouterPage(email_demo_page.loadLibrary(), (context) {
      return email_demo_page.EmailDemoPage();
    });
  },
  "SMS Sender": (context) {
    return ContainerAsyncRouterPage(sms_demo_page.loadLibrary(), (context) {
      return sms_demo_page.SmsDemoPage();
    });
  },
  "Phone Call": (context) {
    return ContainerAsyncRouterPage(phone_demo_page.loadLibrary(), (context) {
      return phone_demo_page.PhoneDemoPage();
    });
  },
  "Contact Picker": (context) {
    return ContainerAsyncRouterPage(contact_demo_page.loadLibrary(), (context) {
      return contact_demo_page.ContactDemoPage();
    });
  },
  "Clipboard": (context) {
    return ContainerAsyncRouterPage(clipboard_demo_page.loadLibrary(),
            (context) {
          return clipboard_demo_page.ClipboardDemoPage();
        });
  },
  "App Lifecycle": (context) {
    return ContainerAsyncRouterPage(app_lifecycle_demo_page.loadLibrary(),
            (context) {
          return app_lifecycle_demo_page.AppLifecycleDemoPage();
        });
  },
  "Platform Channel Communication": (context) {
    return ContainerAsyncRouterPage(channel_demo_page.loadLibrary(), (context) {
      return channel_demo_page.ChannelDemoPage();
    });
  },
  "Native Code Integration": (context) {
    return ContainerAsyncRouterPage(native_demo_page.loadLibrary(), (context) {
      return native_demo_page.NativeDemoPage();
    });
  },
  "Package/Plugin Development": (context) {
    return ContainerAsyncRouterPage(plugin_demo_page.loadLibrary(), (context) {
      return plugin_demo_page.PluginDemoPage();
    });
  },
  "Custom Widget Library": (context) {
    return ContainerAsyncRouterPage(custom_widget_demo_page.loadLibrary(),
            (context) {
          return custom_widget_demo_page.CustomWidgetDemoPage();
        });
  },
  "Performance Optimization": (context) {
    return ContainerAsyncRouterPage(performance_demo_page.loadLibrary(),
            (context) {
          return performance_demo_page.PerformanceDemoPage();
        });
  },
  "Memory Management": (context) {
    return ContainerAsyncRouterPage(memory_demo_page.loadLibrary(), (context) {
      return memory_demo_page.MemoryDemoPage();
    });
  },
  "Testing Demo (Unit/Widget/Integration)": (context) {
    return ContainerAsyncRouterPage(test_demo_page.loadLibrary(), (context) {
      return test_demo_page.TestDemoPage();
    });
  },
  "CI/CD Pipeline": (context) {
    return ContainerAsyncRouterPage(cicd_demo_page.loadLibrary(), (context) {
      return cicd_demo_page.CICDDemoPage();
    });
  },
  "Code Generation (build_runner)": (context) {
    return ContainerAsyncRouterPage(codegen_demo_page.loadLibrary(), (context) {
      return codegen_demo_page.CodegenDemoPage();
    });
  },
  "Dependency Injection": (context) {
    return ContainerAsyncRouterPage(di_demo_page.loadLibrary(), (context) {
      return di_demo_page.DIDemoPage();
    });
  },
  "BLoC Pattern": (context) {
    return ContainerAsyncRouterPage(bloc_demo_page.loadLibrary(), (context) {
      return bloc_demo_page.BlocDemoPage();
    });
  },
  "Provider Pattern": (context) {
    return ContainerAsyncRouterPage(provider_demo_page.loadLibrary(), (context) {
      return provider_demo_page.ProviderDemoPage();
    });
  },
  "Riverpod Pattern": (context) {
    return ContainerAsyncRouterPage(riverpod_demo_page.loadLibrary(), (context) {
      return riverpod_demo_page.RiverpodDemoPage();
    });
  },
  "GetX Pattern": (context) {
    return ContainerAsyncRouterPage(getx_demo_page.loadLibrary(), (context) {
      return getx_demo_page.GetXDemoPage();
    });
  },
  "Redux Pattern": (context) {
    return ContainerAsyncRouterPage(redux_demo_page.loadLibrary(), (context) {
      return redux_demo_page.ReduxDemoPage();
    });
  },
  "MobX Pattern": (context) {
    return ContainerAsyncRouterPage(mobx_demo_page.loadLibrary(), (context) {
      return mobx_demo_page.MobXDemoPage();
    });
  },
  "MVVM Architecture": (context) {
    return ContainerAsyncRouterPage(mvvm_demo_page.loadLibrary(), (context) {
      return mvvm_demo_page.MVVMDemoPage();
    });
  },
  "Clean Architecture": (context) {
    return ContainerAsyncRouterPage(clean_demo_page.loadLibrary(), (context) {
      return clean_demo_page.CleanDemoPage();
    });
  },
  "Error Handling": (context) {
    return ContainerAsyncRouterPage(error_demo_page.loadLibrary(), (context) {
      return error_demo_page.ErrorDemoPage();
    });
  },
  "Logging & Debug": (context) {
    return ContainerAsyncRouterPage(log_demo_page.loadLibrary(), (context) {
      return log_demo_page.LogDemoPage();
    });
  },
  "Encryption & Security": (context) {
    return ContainerAsyncRouterPage(security_demo_page.loadLibrary(), (context) {
      return security_demo_page.SecurityDemoPage();
    });
  },
  "Obfuscation": (context) {
    return ContainerAsyncRouterPage(obfuscation_demo_page.loadLibrary(),
            (context) {
          return obfuscation_demo_page.ObfuscationDemoPage();
        });
  },
  "App Signing": (context) {
    return ContainerAsyncRouterPage(signing_demo_page.loadLibrary(), (context) {
      return signing_demo_page.SigningDemoPage();
    });
  },
  "Flavors (Dev/Staging/Prod)": (context) {
    return ContainerAsyncRouterPage(flavor_demo_page.loadLibrary(), (context) {
      return flavor_demo_page.FlavorDemoPage();
    });
  },
  "Build Configuration": (context) {
    return ContainerAsyncRouterPage(build_demo_page.loadLibrary(), (context) {
      return build_demo_page.BuildDemoPage();
    });
  },
  "Desktop App (Windows/Mac/Linux)": (context) {
    return ContainerAsyncRouterPage(desktop_demo_page.loadLibrary(), (context) {
      return desktop_demo_page.DesktopDemoPage();
    });
  },
  "Web App Specific Features": (context) {
    return ContainerAsyncRouterPage(web_specific_demo_page.loadLibrary(),
            (context) {
          return web_specific_demo_page.WebSpecificDemoPage();
        });
  },
  "Embedded Device (IoT)": (context) {
    return ContainerAsyncRouterPage(embedded_demo_page.loadLibrary(), (context) {
      return embedded_demo_page.EmbeddedDemoPage();
    });
  },
  "Accessibility (a11y)": (context) {
    return ContainerAsyncRouterPage(accessibility_demo_page.loadLibrary(),
            (context) {
          return accessibility_demo_page.AccessibilityDemoPage();
        });
  },
  "Localization Advanced": (context) {
    return ContainerAsyncRouterPage(localization_demo_page.loadLibrary(),
            (context) {
          return localization_demo_page.LocalizationDemoPage();
        });
  },
  "Material Design 3": (context) {
    return ContainerAsyncRouterPage(material3_demo_page.loadLibrary(),
            (context) {
          return material3_demo_page.Material3DemoPage();
        });
  },
  "Cupertino (iOS Style) Widgets": (context) {
    return ContainerAsyncRouterPage(cupertino_demo_page.loadLibrary(),
            (context) {
          return cupertino_demo_page.CupertinoDemoPage();
        });
  },
  "Platform-Specific UI": (context) {
    return ContainerAsyncRouterPage(platform_ui_demo_page.loadLibrary(),
            (context) {
          return platform_ui_demo_page.PlatformUIDemoPage();
        });
  },
  "Galaxy Scene": (context) {
    return ContainerAsyncRouterPage(galaxy_scene_page.loadLibrary(), (context) {
      return galaxy_scene_page.GalaxyScene();
    });
  },
};
```

### Commands to Run Web with Specified Address Instead of Localhost

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8989

flutter build web --web-renderer canvaskit  # Specify render mode
flutter build web --release --web-renderer html 

cp -r ./build/app/intermediates/flutter/release/flutter_assets/ ./build/web/assets
```

### Related Articles

- ### [Latest Flutter Articles](https://juejin.im/user/582aca2ba22b9d006b59ae68/posts)
- ### [Flutter Complete Development Series Articles Column](http://mp.weixin.qq.com/mp/homepage?__biz=Mzg3NTA3MDIxOA==&hid=2&sn=679ad0212470f5155c4412e678411374&scene=18#wechat_redirect)
- ### [Flutter Extra World Series Articles Column](http://mp.weixin.qq.com/mp/homepage?__biz=Mzg3NTA3MDIxOA==&hid=3&sn=bf37119ae2b741a1c71125538bf0cd8d&scene=18#wechat_redirect)

----

- ## [Flutter Github Client](https://github.com/CarGuo/gsy_github_app_flutter) 

- ## [Flutter Complete Development Guide Gitbook Preview & Download](https://github.com/CarGuo/GSYFlutterBook)

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=CarGuo/gsy_flutter_demo&type=Date)](https://star-history.com/#CarGuo/gsy_flutter_demo&Date)

## Contributors

Thanks to all contributors! 🎉

## Contact

- **Author**: Shuyu Guo (CarGuo)
- **Email**: guoshuyu@gmail.com
- **WeChat Official Account**: GSYTech
- **Blog**: http://guoshuyu.cn

---

**If you find this project helpful, please give it a ⭐️ Star!**

