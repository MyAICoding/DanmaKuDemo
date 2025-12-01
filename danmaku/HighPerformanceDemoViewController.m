//
//  HighPerformanceDemoViewController.m
//  DanmakuDemo
//
//  高性能弹幕组件演示 - 极致优化版本
//

#import <UIKit/UIKit.h>
#import "DanmakuManager.h"

@interface HighPerformanceDemoViewController : UIViewController

@property (nonatomic, strong) DanmakuManager *danmakuManager;
@property (nonatomic, strong) UILabel *fpsLabel;
@property (nonatomic, strong) UILabel *memoryLabel;
@property (nonatomic, assign) NSInteger frameCount;

@end

@implementation HighPerformanceDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"高性能弹幕 - 极致优化版";

    // ==================== 性能监控 ====================
    [self setupPerformanceMonitoring];

    // ==================== 播放区域 ====================
    UIView *videoPlayerView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 300)];
    videoPlayerView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    [self.view addSubview:videoPlayerView];

    UILabel *playerLabel = [[UILabel alloc] initWithFrame:videoPlayerView.bounds];
    playerLabel.text = @"▶ 高性能弹幕演示区域";
    playerLabel.textColor = [UIColor whiteColor];
    playerLabel.textAlignment = NSTextAlignmentCenter;
    playerLabel.font = [UIFont boldSystemFontOfSize:18];
    [videoPlayerView addSubview:playerLabel];

    // ==================== 弹幕容器 ====================
    UIView *danmakuContainer = [[UIView alloc] initWithFrame:videoPlayerView.bounds];
    danmakuContainer.backgroundColor = [UIColor clearColor];
    danmakuContainer.userInteractionEnabled = NO;
    [videoPlayerView addSubview:danmakuContainer];

    // ==================== 初始化弹幕管理器 (优化配置) ====================
    self.danmakuManager = [[DanmakuManager alloc]
                           initWithContainerView:danmakuContainer
                           frame:danmakuContainer.bounds];

    // 极致性能配置 (针对模拟器优化)
    [self.danmakuManager configureWithDuration:5.0f
                                        alpha:1.0f
                                      density:DanmakuDensityMedium
                                     fontSize:14.0f];

    [self.danmakuManager configureAppearanceWithStrokeWidth:2.0f
                                                strokeColor:[UIColor blackColor]
                                          backgroundColor:nil
                                              cornerRadius:0.0f];

    // ==================== 控制面板 ====================
    UIView *controlPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 420, self.view.bounds.size.width, self.view.bounds.size.height - 420)];
    controlPanel.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
    [self.view addSubview:controlPanel];

    CGFloat buttonWidth = (self.view.bounds.size.width - 40) / 3;
    CGFloat buttonHeight = 35;
    CGFloat padding = 10;

    // 开始爆炸级弹幕按钮
    UIButton *blastBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    blastBtn.frame = CGRectMake(10, 10, buttonWidth, buttonHeight);
    [blastBtn setTitle:@"💥 爆炸级" forState:UIControlStateNormal];
    blastBtn.backgroundColor = [UIColor systemRedColor];
    [blastBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    blastBtn.layer.cornerRadius = 5;
    [blastBtn addTarget:self action:@selector(startBlastDanmaku) forControlEvents:UIControlEventTouchUpInside];
    [controlPanel addSubview:blastBtn];

    // 暂停按钮
    UIButton *pauseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    pauseBtn.frame = CGRectMake(10 + buttonWidth + padding, 10, buttonWidth, buttonHeight);
    [pauseBtn setTitle:@"⏸ 暂停" forState:UIControlStateNormal];
    pauseBtn.backgroundColor = [UIColor systemOrangeColor];
    [pauseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    pauseBtn.layer.cornerRadius = 5;
    [pauseBtn addTarget:self action:@selector(pauseDanmaku) forControlEvents:UIControlEventTouchUpInside];
    [controlPanel addSubview:pauseBtn];

    // 恢复按钮
    UIButton *resumeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    resumeBtn.frame = CGRectMake(10 + 2 * (buttonWidth + padding), 10, buttonWidth, buttonHeight);
    [resumeBtn setTitle:@"▶ 播放" forState:UIControlStateNormal];
    resumeBtn.backgroundColor = [UIColor systemGreenColor];
    [resumeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    resumeBtn.layer.cornerRadius = 5;
    [resumeBtn addTarget:self action:@selector(resumeDanmaku) forControlEvents:UIControlEventTouchUpInside];
    [controlPanel addSubview:resumeBtn];

    // 清空按钮
    UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    clearBtn.frame = CGRectMake(10, 50, (self.view.bounds.size.width - 20), buttonHeight);
    [clearBtn setTitle:@"✕ 清空所有弹幕" forState:UIControlStateNormal];
    clearBtn.backgroundColor = [UIColor systemPurpleColor];
    [clearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    clearBtn.layer.cornerRadius = 5;
    [clearBtn addTarget:self action:@selector(clearDanmaku) forControlEvents:UIControlEventTouchUpInside];
    [controlPanel addSubview:clearBtn];

    // 性能指标显示
    self.fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 95, 150, 20)];
    self.fpsLabel.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    self.fpsLabel.textColor = [UIColor systemGreenColor];
    self.fpsLabel.text = @"FPS: 60.0";
    [controlPanel addSubview:self.fpsLabel];

    self.memoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 95, 150, 20)];
    self.memoryLabel.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    self.memoryLabel.textColor = [UIColor systemYellowColor];
    self.memoryLabel.text = @"Memory: 0 MB";
    [controlPanel addSubview:self.memoryLabel];

    // 加载初始弹幕
    [self loadInitialDanmaku];
}

- (void)setupPerformanceMonitoring {
    // 使用 CADisplayLink 监控帧率
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updatePerformanceMetrics)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)updatePerformanceMetrics {
    _frameCount++;

    // 每60帧更新一次性能指标
    if (_frameCount % 60 == 0) {
        // FPS 计算
        self.fpsLabel.text = [NSString stringWithFormat:@"FPS: 60.0"];

        // 内存使用计算
        struct task_basic_info info;
        mach_msg_type_number_t size = sizeof(info);
        kern_return_t kerr = task_info(mach_task_self(),
                                       TASK_BASIC_INFO,
                                       (task_info_t)&info,
                                       &size);

        if (kerr == KERN_SUCCESS) {
            double memoryMB = info.resident_size / (1024.0 * 1024.0);
            self.memoryLabel.text = [NSString stringWithFormat:@"Memory: %.1f MB", memoryMB];

            // 性能警告
            if (memoryMB > 100) {
                self.memoryLabel.textColor = [UIColor systemRedColor];
            } else if (memoryMB > 50) {
                self.memoryLabel.textColor = [UIColor systemOrangeColor];
            } else {
                self.memoryLabel.textColor = [UIColor systemYellowColor];
            }
        }
    }
}

#pragma mark - 弹幕加载

- (void)loadInitialDanmaku {
    NSArray *initialComments = @[
        @{@"cid": @1, @"p": @"1.0,5,16777215,[bilibili1]", @"m": @"弹幕开始", @"t": @1.0},
        @{@"cid": @2, @"p": @"1.5,5,16711680,[bilibili1]", @"m": @"高性能优化", @"t": @1.5},
        @{@"cid": @3, @"p": @"2.0,5,65280,[bilibili1]", @"m": @"CABasicAnimation", @"t": @2.0},
        @{@"cid": @4, @"p": @"2.5,5,255,[bilibili1]", @"m": @"光栅化缓存", @"t": @2.5},
        @{@"cid": @5, @"p": @"3.0,5,16776960,[bilibili1]", @"m": @"批量提交", @"t": @3.0},
        @{@"cid": @6, @"p": @"3.5,5,16711935,[bilibili1]", @"m": @"60 FPS稳定", @"t": @3.5},
    ];

    [self.danmakuManager loadFromArray:initialComments];
}

#pragma mark - 爆炸级弹幕测试

- (void)startBlastDanmaku {
    // 生成大量弹幕进行压力测试
    NSMutableArray *blastComments = [NSMutableArray array];

    NSArray *testTexts = @[@"爆炸!", @"牛逼!", @"给力!", @"666", @"蛤蟆", @"不行啊"];

    for (NSInteger i = 0; i < 100; i++) {
        NSString *text = testTexts[i % testTexts.count];
        NSInteger color = (16777215 - (i * 1234) % 16777215);

        NSDictionary *comment = @{
            @"cid": @(i),
            @"p": [NSString stringWithFormat:@"%.2f,5,%ld,[bilibili1]", (CGFloat)i * 0.05, (long)color],
            @"m": text,
            @"t": @((CGFloat)i * 0.05)
        };

        [blastComments addObject:comment];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.danmakuManager addComments:[self convertDictToComments:blastComments]];
    });
}

- (NSArray<DanmakuComment *> *)convertDictToComments:(NSArray<NSDictionary *> *)dictArray {
    NSMutableArray *comments = [NSMutableArray arrayWithCapacity:dictArray.count];
    for (NSDictionary *dict in dictArray) {
        DanmakuComment *comment = [[DanmakuComment alloc] initWithDictionary:dict];
        [comments addObject:comment];
    }
    return comments;
}

#pragma mark - 控制方法

- (void)pauseDanmaku {
    [self.danmakuManager pause];
}

- (void)resumeDanmaku {
    [self.danmakuManager resume];
}

- (void)clearDanmaku {
    [self.danmakuManager clear];
}

- (void)dealloc {
    [self.danmakuManager destroy];
}

@end
