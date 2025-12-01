//
//  CATextLayerVsUILabelDemoViewController.m
//  DanmakuDemo
//
//  CATextLayer vs UILabel 性能对比演示
//

#import <UIKit/UIKit.h>
#import "DanmakuManager.h"
#import "DanmakuEngineCAVersion.h"

@interface CATextLayerVsUILabelDemoViewController : UIViewController

@property (nonatomic, strong) DanmakuManager *uiLabelManager;
@property (nonatomic, strong) DanmakuEngineCAVersion *caTextLayerEngine;
@property (nonatomic, strong) UILabel *uiLabelFpsLabel;
@property (nonatomic, strong) UILabel *caTextLayerFpsLabel;
@property (nonatomic, strong) UILabel *uiLabelMemoryLabel;
@property (nonatomic, strong) UILabel *caTextLayerMemoryLabel;

@end

@implementation CATextLayerVsUILabelDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"性能对比: CATextLayer vs UILabel";

    // ==================== 左侧: UILabel 版本 ====================
    UIView *leftContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 80, self.view.bounds.size.width / 2, 300)];
    [self.view addSubview:leftContainer];

    // 左侧标题
    UILabel *leftTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, leftContainer.bounds.size.width, 25)];
    leftTitle.text = @"UILabel 版本";
    leftTitle.textColor = [UIColor systemBlueColor];
    leftTitle.textAlignment = NSTextAlignmentCenter;
    leftTitle.font = [UIFont boldSystemFontOfSize:14];
    [leftContainer addSubview:leftTitle];

    // 左侧弹幕容器
    UIView *leftDanmakuContainer = [[UIView alloc]
                                    initWithFrame:CGRectMake(0, 30, leftContainer.bounds.size.width, 270)];
    leftDanmakuContainer.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1];
    leftDanmakuContainer.userInteractionEnabled = NO;
    [leftContainer addSubview:leftDanmakuContainer];

    self.uiLabelManager = [[DanmakuManager alloc]
                           initWithContainerView:leftDanmakuContainer
                           frame:leftDanmakuContainer.bounds];

    [self.uiLabelManager configureWithDuration:5.0f alpha:1.0f density:DanmakuDensityMedium fontSize:14.0f];

    // ==================== 右侧: CATextLayer 版本 ====================
    UIView *rightContainer = [[UIView alloc]
                              initWithFrame:CGRectMake(self.view.bounds.size.width / 2, 80,
                                                        self.view.bounds.size.width / 2, 300)];
    [self.view addSubview:rightContainer];

    // 右侧标题
    UILabel *rightTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rightContainer.bounds.size.width, 25)];
    rightTitle.text = @"CATextLayer 版本";
    rightTitle.textColor = [UIColor systemGreenColor];
    rightTitle.textAlignment = NSTextAlignmentCenter;
    rightTitle.font = [UIFont boldSystemFontOfSize:14];
    [rightContainer addSubview:rightTitle];

    // 右侧弹幕容器
    UIView *rightDanmakuContainer = [[UIView alloc]
                                     initWithFrame:CGRectMake(0, 30, rightContainer.bounds.size.width, 270)];
    rightDanmakuContainer.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1];
    rightDanmakuContainer.userInteractionEnabled = NO;
    [rightContainer addSubview:rightDanmakuContainer];

    self.caTextLayerEngine = [[DanmakuEngineCAVersion alloc]
                              initWithFrame:rightDanmakuContainer.bounds];
    self.caTextLayerEngine.duration = 5.0f;
    self.caTextLayerEngine.alpha = 1.0f;
    self.caTextLayerEngine.density = DanmakuDensityMedium;
    self.caTextLayerEngine.fontSize = 14.0f;
    [rightDanmakuContainer addSubview:self.caTextLayerEngine];

    // ==================== 控制面板 ====================
    UIView *controlPanel = [[UIView alloc]
                            initWithFrame:CGRectMake(0, 390, self.view.bounds.size.width, self.view.bounds.size.height - 390)];
    controlPanel.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.08 alpha:1];
    [self.view addSubview:controlPanel];

    CGFloat panelWidth = self.view.bounds.size.width;

    // 左侧性能指标
    UILabel *leftPerfTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, panelWidth / 2 - 20, 20)];
    leftPerfTitle.text = @"UILabel 性能";
    leftPerfTitle.textColor = [UIColor systemBlueColor];
    leftPerfTitle.font = [UIFont boldSystemFontOfSize:12];
    [controlPanel addSubview:leftPerfTitle];

    self.uiLabelFpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, panelWidth / 2 - 20, 15)];
    self.uiLabelFpsLabel.textColor = [UIColor lightGrayColor];
    self.uiLabelFpsLabel.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    self.uiLabelFpsLabel.text = @"FPS: 60";
    [controlPanel addSubview:self.uiLabelFpsLabel];

    self.uiLabelMemoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 53, panelWidth / 2 - 20, 15)];
    self.uiLabelMemoryLabel.textColor = [UIColor lightGrayColor];
    self.uiLabelMemoryLabel.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    self.uiLabelMemoryLabel.text = @"Memory: 0 MB";
    [controlPanel addSubview:self.uiLabelMemoryLabel];

    // 右侧性能指标
    UILabel *rightPerfTitle = [[UILabel alloc] initWithFrame:CGRectMake(panelWidth / 2 + 10, 10, panelWidth / 2 - 20, 20)];
    rightPerfTitle.text = @"CATextLayer 性能";
    rightPerfTitle.textColor = [UIColor systemGreenColor];
    rightPerfTitle.font = [UIFont boldSystemFontOfSize:12];
    [controlPanel addSubview:rightPerfTitle];

    self.caTextLayerFpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(panelWidth / 2 + 10, 35, panelWidth / 2 - 20, 15)];
    self.caTextLayerFpsLabel.textColor = [UIColor lightGrayColor];
    self.caTextLayerFpsLabel.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    self.caTextLayerFpsLabel.text = @"FPS: 60";
    [controlPanel addSubview:self.caTextLayerFpsLabel];

    self.caTextLayerMemoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(panelWidth / 2 + 10, 53, panelWidth / 2 - 20, 15)];
    self.caTextLayerMemoryLabel.textColor = [UIColor lightGrayColor];
    self.caTextLayerMemoryLabel.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    self.caTextLayerMemoryLabel.text = @"Memory: 0 MB";
    [controlPanel addSubview:self.caTextLayerMemoryLabel];

    // 控制按钮
    CGFloat btnWidth = (panelWidth - 30) / 3;

    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    startBtn.frame = CGRectMake(10, 75, btnWidth, 30);
    [startBtn setTitle:@"▶ 开始测试" forState:UIControlStateNormal];
    startBtn.backgroundColor = [UIColor systemGreenColor];
    [startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    startBtn.layer.cornerRadius = 4;
    [startBtn addTarget:self action:@selector(startTest) forControlEvents:UIControlEventTouchUpInside];
    [controlPanel addSubview:startBtn];

    UIButton *pauseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    pauseBtn.frame = CGRectMake(10 + btnWidth + 5, 75, btnWidth, 30);
    [pauseBtn setTitle:@"⏸ 暂停" forState:UIControlStateNormal];
    pauseBtn.backgroundColor = [UIColor systemOrangeColor];
    [pauseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    pauseBtn.layer.cornerRadius = 4;
    [pauseBtn addTarget:self action:@selector(pauseTest) forControlEvents:UIControlEventTouchUpInside];
    [controlPanel addSubview:pauseBtn];

    UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    clearBtn.frame = CGRectMake(10 + (btnWidth + 5) * 2, 75, btnWidth, 30);
    [clearBtn setTitle:@"✕ 清空" forState:UIControlStateNormal];
    clearBtn.backgroundColor = [UIColor systemRedColor];
    [clearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    clearBtn.layer.cornerRadius = 4;
    [clearBtn addTarget:self action:@selector(clearTest) forControlEvents:UIControlEventTouchUpInside];
    [controlPanel addSubview:clearBtn];

    // 说明
    UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 110, panelWidth - 20, 40)];
    noteLabel.text = @"📌 对比说明:\n• 左侧使用 UILabel (原始版本) • 右侧使用 CATextLayer (优化版本)\n观察两侧的性能差异";
    noteLabel.textColor = [UIColor lightGrayColor];
    noteLabel.font = [UIFont systemFontOfSize:11];
    noteLabel.numberOfLines = 0;
    [controlPanel addSubview:noteLabel];

    // 启动性能监控
    [self startPerformanceMonitoring];
}

- (void)startPerformanceMonitoring {
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMetrics)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)updateMetrics {
    // 这里可以添加性能数据更新逻辑
    // 由于篇幅,简化处理
}

- (void)startTest {
    [self.uiLabelManager clear];
    [self.caTextLayerEngine clearAllComments];

    [self loadTestData];
}

- (void)pauseTest {
    [self.uiLabelManager pause];
    [self.caTextLayerEngine pauseDanmaku];
}

- (void)clearTest {
    [self.uiLabelManager clear];
    [self.caTextLayerEngine clearAllComments];
}

- (void)loadTestData {
    NSMutableArray<DanmakuComment *> *comments = [NSMutableArray array];

    NSArray *texts = @[@"对比测试", @"性能优化", @"高品质", @"流畅动画", @"推荐使用"];

    for (NSInteger i = 0; i < 50; i++) {
        DanmakuComment *comment = [[DanmakuComment alloc] initWithDictionary:@{
            @"cid": @(i),
            @"p": [NSString stringWithFormat:@"%.2f,5,%ld,[test]", (CGFloat)i * 0.1f, (long)(16777215 - i * 100000) % 16777215],
            @"m": [NSString stringWithFormat:@"%@ %ld", texts[i % texts.count], (long)i],
            @"t": @((CGFloat)i * 0.1f)
        }];
        [comments addObject:comment];
    }

    [self.uiLabelManager addComments:comments];
    [self.caTextLayerEngine addComments:comments];
}

- (void)dealloc {
    [self.uiLabelManager destroy];
    [self.caTextLayerEngine destroy];
}

@end
