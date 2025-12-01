# ⚡ 弹幕组件快速参考卡

**版本**: 3.0 | **更新**: 2025年11月30日

---

## 🚀 最常用的 3 行代码

```objc
// 初始化
DanmakuManager *manager = [[DanmakuManager alloc]
                          initWithContainerView:container frame:frame];

// 配置
[manager configureWithDuration:5.0f alpha:1.0f density:DanmakuDensityMedium fontSize:14.0f];

// 显示
[manager addComments:comments];
```

---

## 📋 完整 API 快速查表

### DanmakuManager (管理器) ⭐ 最常用
```objc
// 初始化
DanmakuManager *manager = [[DanmakuManager alloc]
                          initWithContainerView:container
                          frame:frame];

// 配置基本属性
[manager configureWithDuration:5.0f           // 速度(秒)
                         alpha:1.0f           // 透明度(0-1)
                       density:DanmakuDensityMedium  // 密度(Low/Medium/High)
                      fontSize:14.0f];        // 字体大小

// 配置外观
[manager configureAppearanceWithStrokeWidth:2.0f           // 描边宽度
                                 strokeColor:[UIColor blackColor]
                           backgroundColor:nil            // 可选
                               cornerRadius:0.0f];        // 圆角

// 添加弹幕
[manager addComment:comment];                // 单个
[manager addComments:comments];              // 批量

// 控制
[manager pause];                             // 暂停
[manager resume];                            // 恢复
[manager clear];                             // 清空
[manager destroy];                           // 销毁(必须!)
```

### DanmakuTimelineController (时间轴) [新增]
```objc
// 初始化
self.timeline = [[DanmakuTimelineController alloc]
    initWithContainerView:container
    frame:frame
    allComments:comments];

// 操作
[self.timeline updatePlaybackTime:currentTime];  // 持续更新(视频播放中)
[self.timeline seekToTime:targetTime];           // 快速跳转
[self.timeline destroy];                         // 销毁(必须!)
```

---

## 🎯 方案选择速查表

| 场景 | 推荐方案 | 原因 |
|------|---------|------|
| 快速原型 | DanmakuManager | 最简洁 |
| 视频播放 | DanmakuTimelineController | 时间同步 |
| 极致性能 | DanmakuEngineCAVersion | 最快 (CPU 6%) |

---

## ⚙️ 常用配置

### 中密度 (推荐) ⭐
```objc
[manager configureWithDuration:5.0f alpha:1.0f
                       density:DanmakuDensityMedium fontSize:14.0f];
```

### 背景气泡
```objc
[manager configureAppearanceWithStrokeWidth:2.0f
                               strokeColor:[UIColor blackColor]
                         backgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.8]
                             cornerRadius:10.0f];
```

---

## 📊 性能参考

| 指标 | UILabel | CATextLayer | 改进 |
|------|---------|------------|------|
| FPS | 60 | 60 | ✅ |
| CPU | 8% | **6%** | ⬇️ 25% |
| 内存 | 13.2MB | **10.8MB** | ⬇️ 18% |

---

## 🚀 一分钟快速开始

```objc
- (void)viewDidLoad {
    [super viewDidLoad];

    // 1. 创建容器
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 320, 200)];
    [self.view addSubview:container];

    // 2. 初始化
    DanmakuManager *manager = [[DanmakuManager alloc]
                              initWithContainerView:container
                              frame:container.bounds];

    // 3. 配置
    [manager configureWithDuration:5.0f alpha:1.0f
                           density:DanmakuDensityMedium fontSize:14.0f];

    // 4. 添加数据
    NSArray *comments = [NSArray arrayWithObjects:
        [[DanmakuComment alloc] initWithDictionary:@{
            @"cid": @(1),
            @"p": @"5.0,5,16777215,[test]",
            @"m": @"Hello Danmaku!",
            @"t": @(0)
        }],
        nil
    ];

    [manager addComments:comments];
}
```

---

**现在就开始使用吧!** 🚀
