# iOS 弹幕组件 - 项目集成指南

## 文件清单

```
DanmakuComponent/
├── DanmakuComment.h/.m          # 弹幕数据模型 (解析弹幕信息)
├── DanmakuLabel.h/.m            # 自定义标签视图 (带描边效果)
├── DanmakuEngine.h/.m           # 弹幕渲染引擎 (核心)
├── DanmakuManager.h/.m          # 高级接口管理器
├── DemoViewController.m          # 完整使用示例
└── README.md                    # 完整文档
```

## 快速集成步骤

### Step 1: 添加文件到项目

1. 在Xcode中,右键点击你的项目
2. 选择 "Add Files to..."
3. 选择上面列出的 `.h` 和 `.m` 文件
4. 确保 "Copy items if needed" 被选中
5. 确保目标配置正确

### Step 2: 导入头文件

```objc
#import "DanmakuManager.h"
```

### Step 3: 最小化集成代码

```objc
- (void)setupDanmaku {
    // 创建弹幕容器
    UIView *danmakuContainer = [[UIView alloc] initWithFrame:self.videoView.bounds];
    danmakuContainer.backgroundColor = [UIColor clearColor];
    danmakuContainer.userInteractionEnabled = NO; // 关键
    [self.videoView addSubview:danmakuContainer];

    // 初始化管理器
    self.danmakuManager = [[DanmakuManager alloc]
                           initWithContainerView:danmakuContainer
                           frame:danmakuContainer.bounds];

    // 加载弹幕
    [self.danmakuManager loadFromArray:self.danmakuData];
}
```

## 部署检查清单

- [ ] 所有 `.h` 和 `.m` 文件都已添加到target
- [ ] 项目部署目标 >= iOS 16.0
- [ ] 弹幕容器的 `userInteractionEnabled = NO`
- [ ] 弹幕管理器在 `dealloc` 中调用了 `destroy`
- [ ] 数据格式正确 (JSON或字典数组)

## 常见集成问题

### 问题1: 编译错误 "Cannot find interface"

**原因**: 没有正确导入头文件或文件没有添加到target

**解决**:
```objc
#import "DanmakuManager.h"  // 添加这行
```

### 问题2: 弹幕不显示

**检查清单**:
1. 容器视图是否正确添加到视图层级
2. 容器 frame 是否有正确的宽高
3. 数据是否正确解析
4. 容器是否在正确的 Z-order (应该在视频播放器上方)

```objc
// ✓ 正确的顺序
[self.view addSubview:self.videoView];           // 底层
UIView *container = [[UIView alloc] init...];
[self.videoView addSubview:container];           // 上层
```

### 问题3: 事件响应问题

**确保**:
```objc
danmakuContainer.userInteractionEnabled = NO;    // 必须为NO
```

这样可以让事件穿透到下层的控制按钮。

### 问题4: 内存泄漏

**必须在适当时机销毁**:
```objc
- (void)dealloc {
    [self.danmakuManager destroy];
}

// 或者在页面关闭时
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.danmakuManager destroy];
}
```

## 性能优化建议

### 1. 根据内容调整密度

```objc
// 检查视频时长和弹幕数量
if (self.danmakuData.count > 500) {
    self.danmakuManager.engine.density = DanmakuDensityLow;
} else if (self.danmakuData.count > 200) {
    self.danmakuManager.engine.density = DanmakuDensityMedium;
}
```

### 2. 异步加载弹幕

```objc
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // 在后台线程处理数据
    NSMutableArray *comments = [NSMutableArray array];
    for (NSDictionary *dict in largeDataArray) {
        DanmakuComment *comment = [[DanmakuComment alloc] initWithDictionary:dict];
        [comments addObject:comment];
    }

    // 回到主线程添加
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.danmakuManager addComments:comments];
    });
});
```

### 3. 监控性能

```objc
// 添加FPS监控
#import <QuartzCore/QuartzCore.h>

CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick)];
[displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

static CFTimeInterval lastTimestamp = 0;
- (void)tick {
    CFTimeInterval timestamp = CACurrentMediaTime();
    if (lastTimestamp > 0) {
        CGFloat fps = 1.0 / (timestamp - lastTimestamp);
        NSLog(@"FPS: %.1f", fps);
    }
    lastTimestamp = timestamp;
}
```

## 配置参考

### 预设配置

```objc
// 低端设备 (iPhone SE)
[self.danmakuManager configureWithDuration:8.0f
                                    alpha:0.85f
                                  density:DanmakuDensityLow
                                 fontSize:14.0f];

// 中端设备 (iPhone 12)
[self.danmakuManager configureWithDuration:6.0f
                                    alpha:1.0f
                                  density:DanmakuDensityMedium
                                 fontSize:16.0f];

// 高端设备 (iPhone 15 Pro)
[self.danmakuManager configureWithDuration:5.0f
                                    alpha:1.0f
                                  density:DanmakuDensityHigh
                                 fontSize:17.0f];
```

## 高级用法

### 自定义弹幕样式

创建 `DanmakuLabel` 的子类:

```objc
@interface CustomDanmakuLabel : DanmakuLabel
@end

@implementation CustomDanmakuLabel

- (void)drawTextInRect:(CGRect)rect {
    // 自定义绘制逻辑
    [super drawTextInRect:rect];
}

@end
```

### 动态调整参数

```objc
// 实时调整速度
self.danmakuManager.engine.duration = 4.0f;

// 实时调整透明度
self.danmakuManager.engine.alpha = 0.8f;

// 实时调整密度
self.danmakuManager.engine.density = DanmakuDensityHigh;
```

### 处理暂停/恢复

```objc
- (void)onPause {
    [self.danmakuManager pause];
}

- (void)onResume {
    [self.danmakuManager resume];
}

- (void)onSeek:(CGFloat)seconds {
    // 切换视频进度时清空旧弹幕
    [self.danmakuManager clear];

    // 加载新的弹幕范围
    NSArray *newComments = [self filterCommentsInRange:seconds duration:10];
    [self.danmakuManager addComments:newComments];
}
```

## 版本兼容性

| iOS版本 | 支持状态 | 备注 |
|--------|--------|------|
| < 16.0 | ❌ 不支持 | - |
| 16.0 - 16.4 | ✅ 完全支持 | - |
| 17.0+ | ✅ 完全支持 | 优化的CADisplayLink支持 |

## 测试建议

### 单元测试

```objc
@interface DanmakuEngineTests : XCTestCase
@property (nonatomic, strong) DanmakuEngine *engine;
@end

@implementation DanmakuEngineTests

- (void)setUp {
    self.engine = [[DanmakuEngine alloc] initWithFrame:CGRectMake(0, 0, 375, 300)];
}

- (void)testAddComment {
    DanmakuComment *comment = [[DanmakuComment alloc] initWithDictionary:@{
        @"cid": @1,
        @"p": @"1.0,5,16777215,[test]",
        @"m": @"测试弹幕",
        @"t": @1.0
    }];

    [self.engine addComment:comment];
    XCTAssertEqual(self.engine.activeViews.count, 1);
}

@end
```

### 集成测试

1. 启动应用
2. 播放视频
3. 验证弹幕显示
4. 测试暂停/恢复
5. 测试参数调整
6. 检查内存使用

## 构建和发布

### 编译优化

在 Build Settings 中:
```
Optimization Level: Fast
Strip Linked Product: Yes
Dead Code Stripping: Yes
```

### 架构支持

确保支持的架构:
- arm64 (必须)
- arm64e (可选)
- x86_64 (模拟器)

## 许可和支持

- 许可证: MIT
- iOS最低版本: 16.0
- 支持架构: arm64, x86_64

## 更新日志

### v1.0.0 (初始版本)
- 基础弹幕渲染
- 配置管理
- 性能优化
- 完整文档

## 反馈和改进

如遇到任何问题或有改进建议,请:
1. 检查文档和FAQ
2. 查看示例代码
3. 测试最新版本
4. 提供详细错误日志
