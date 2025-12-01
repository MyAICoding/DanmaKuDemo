//
//  DemoViewController.m
//  DanmakuDemo
//
//  完整的弹幕组件使用示例
//

#import <UIKit/UIKit.h>
#import "DanmakuManager.h"

@interface DemoViewController : UIViewController

@property (nonatomic, strong) DanmakuManager *danmakuManager;
@property (nonatomic, strong) UISlider *speedSlider;
@property (nonatomic, strong) UISlider *alphaSlider;
@property (nonatomic, strong) UISlider *densitySlider;
@property (nonatomic, strong) UILabel *speedLabel;
@property (nonatomic, strong) UILabel *alphaLabel;
@property (nonatomic, strong) UILabel *densityLabel;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"弹幕组件Demo";

    // ==================== 播放区域 ====================
    // 模拟视频播放器
    UIView *videoPlayerView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 300)];
    videoPlayerView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    [self.view addSubview:videoPlayerView];

    // 添加播放器标签
    UILabel *playerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, videoPlayerView.bounds.size.width, videoPlayerView.bounds.size.height)];
    playerLabel.text = @"▶ 视频播放器区域";
    playerLabel.textColor = [UIColor whiteColor];
    playerLabel.textAlignment = NSTextAlignmentCenter;
    playerLabel.font = [UIFont boldSystemFontOfSize:18];
    [videoPlayerView addSubview:playerLabel];

    // 创建弹幕容器 (关键步骤)
    UIView *danmakuContainer = [[UIView alloc] initWithFrame:videoPlayerView.bounds];
    danmakuContainer.backgroundColor = [UIColor clearColor];
    danmakuContainer.userInteractionEnabled = NO; // 事件穿透
    [videoPlayerView addSubview:danmakuContainer];

    // 初始化弹幕管理器
    self.danmakuManager = [[DanmakuManager alloc]
                           initWithContainerView:danmakuContainer
                           frame:danmakuContainer.bounds];

    // 配置基础参数
    [self.danmakuManager configureWithDuration:6.0f
                                        alpha:1.0f
                                      density:DanmakuDensityMedium
                                     fontSize:16.0f];

    // 配置外观
    [self.danmakuManager configureAppearanceWithStrokeWidth:2.0f
                                                strokeColor:[UIColor blackColor]
                                          backgroundColor:[UIColor colorWithWhite:0 alpha:0.2]
                                              cornerRadius:4.0f];

    // 加载示例数据
    [self loadSampleDanmakuData];

    // ==================== 控制面板 ====================
    UIScrollView *controlPanel = [[UIScrollView alloc]
                                  initWithFrame:CGRectMake(0, 420, self.view.bounds.size.width, self.view.bounds.size.height - 420)];
    controlPanel.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    [self.view addSubview:controlPanel];

    CGFloat contentY = 20;

    // 标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, contentY, 200, 30)];
    titleLabel.text = @"弹幕参数调整";
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [controlPanel addSubview:titleLabel];
    contentY += 40;

    // 1. 速度控制
    [self createSliderControlWithTitle:@"滚动速度 (秒)"
                                  frame:CGRectMake(20, contentY, self.view.bounds.size.width - 40, 80)
                            inScrollView:controlPanel
                                   slider:&_speedSlider
                                   label:&_speedLabel
                                minValue:2.0
                                maxValue:15.0
                            defaultValue:6.0
                                  action:@selector(onSpeedChanged:)];
    contentY += 100;

    // 2. 透明度控制
    [self createSliderControlWithTitle:@"透明度"
                                  frame:CGRectMake(20, contentY, self.view.bounds.size.width - 40, 80)
                            inScrollView:controlPanel
                                   slider:&_alphaSlider
                                   label:&_alphaLabel
                                minValue:0.2
                                maxValue:1.0
                            defaultValue:1.0
                                  action:@selector(onAlphaChanged:)];
    contentY += 100;

    // 3. 密度控制
    [self createSliderControlWithTitle:@"密度 (1=低, 2=中, 3=高)"
                                  frame:CGRectMake(20, contentY, self.view.bounds.size.width - 40, 80)
                            inScrollView:controlPanel
                                   slider:&_densitySlider
                                   label:&_densityLabel
                                minValue:1.0
                                maxValue:3.0
                            defaultValue:2.0
                                  action:@selector(onDensityChanged:)];
    contentY += 100;

    // 4. 按钮控制
    CGRect buttonFrame = CGRectMake(20, contentY, self.view.bounds.size.width - 40, 40);

    UIButton *pauseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    pauseBtn.frame = CGRectMake(buttonFrame.origin.x, buttonFrame.origin.y, 100, 40);
    [pauseBtn setTitle:@"⏸ 暂停" forState:UIControlStateNormal];
    pauseBtn.backgroundColor = [UIColor systemOrangeColor];
    [pauseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    pauseBtn.layer.cornerRadius = 5;
    [pauseBtn addTarget:self action:@selector(pauseDanmaku) forControlEvents:UIControlEventTouchUpInside];
    [controlPanel addSubview:pauseBtn];

    UIButton *resumeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    resumeBtn.frame = CGRectMake(buttonFrame.origin.x + 120, buttonFrame.origin.y, 100, 40);
    [resumeBtn setTitle:@"▶ 播放" forState:UIControlStateNormal];
    resumeBtn.backgroundColor = [UIColor systemGreenColor];
    [resumeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    resumeBtn.layer.cornerRadius = 5;
    [resumeBtn addTarget:self action:@selector(resumeDanmaku) forControlEvents:UIControlEventTouchUpInside];
    [controlPanel addSubview:resumeBtn];

    UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    clearBtn.frame = CGRectMake(buttonFrame.origin.x + 240, buttonFrame.origin.y, 80, 40);
    [clearBtn setTitle:@"✕ 清空" forState:UIControlStateNormal];
    clearBtn.backgroundColor = [UIColor systemRedColor];
    [clearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    clearBtn.layer.cornerRadius = 5;
    [clearBtn addTarget:self action:@selector(clearDanmaku) forControlEvents:UIControlEventTouchUpInside];
    [controlPanel addSubview:clearBtn];

    contentY += 60;

    // 5. 快速加载按钮
    UIButton *loadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    loadBtn.frame = CGRectMake(20, contentY, self.view.bounds.size.width - 40, 40);
    [loadBtn setTitle:@"+ 添加更多弹幕" forState:UIControlStateNormal];
    loadBtn.backgroundColor = [UIColor systemBlueColor];
    [loadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loadBtn.layer.cornerRadius = 5;
    [loadBtn addTarget:self action:@selector(loadMoreDanmaku) forControlEvents:UIControlEventTouchUpInside];
    [controlPanel addSubview:loadBtn];
    contentY += 50;

    // 设置scrollView的contentSize
    controlPanel.contentSize = CGSizeMake(self.view.bounds.size.width, contentY + 20);
}

- (void)createSliderControlWithTitle:(NSString *)title
                               frame:(CGRect)frame
                         inScrollView:(UIScrollView *)scrollView
                              slider:(UISlider **)slider
                              label:(UILabel **)label
                           minValue:(float)minValue
                           maxValue:(float)maxValue
                       defaultValue:(float)defaultValue
                             action:(SEL)action {

    // 标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 300, 20)];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor darkGrayColor];
    [scrollView addSubview:titleLabel];

    // Slider
    *slider = [[UISlider alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y + 25, frame.size.width - 80, 20)];
    (*slider).minimumValue = minValue;
    (*slider).maximumValue = maxValue;
    (*slider).value = defaultValue;
    [(*slider) addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [scrollView addSubview:*slider];

    // 数值标签
    *label = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + frame.size.width - 60, frame.origin.y + 25, 60, 20)];
    (*label).text = [NSString stringWithFormat:@"%.2f", defaultValue];
    (*label).font = [UIFont boldSystemFontOfSize:14];
    (*label).textAlignment = NSTextAlignmentRight;
    (*label).textColor = [UIColor systemBlueColor];
    [scrollView addSubview:*label];
}

#pragma mark - 弹幕控制

- (void)loadSampleDanmakuData {
    // 示例弹幕数据
    NSArray *commentArray = @[
        @{@"cid": @1, @"p": @"1.0,5,14811775,[bilibili1]", @"m": @"开幕雷鸣", @"t": @1.0},
        @{@"cid": @2, @"p": @"1.5,5,16777215,[bilibili1]", @"m": @"好家伙", @"t": @1.5},
        @{@"cid": @3, @"p": @"2.0,5,16711680,[bilibili1]", @"m": @"我来了", @"t": @2.0},
        @{@"cid": @4, @"p": @"2.5,5,65280,[bilibili1]", @"m": @"画面清晰度不错", @"t": @2.5},
        @{@"cid": @5, @"p": @"3.0,5,255,[bilibili1]", @"m": @"这是什么节目", @"t": @3.0},
        @{@"cid": @6, @"p": @"3.5,5,14811775,[bilibili1]", @"m": @"笑死我了", @"t": @3.5},
        @{@"cid": @7, @"p": @"4.0,5,16777215,[bilibili1]", @"m": @"666666", @"t": @4.0},
        @{@"cid": @8, @"p": @"4.5,5,16711680,[bilibili1]", @"m": @"不愧是你", @"t": @4.5},
        @{@"cid": @9, @"p": @"5.0,5,65280,[bilibili1]", @"m": @"哈哈哈", @"t": @5.0},
        @{@"cid": @10, @"p": @"5.5,5,255,[bilibili1]", @"m": @"完全同意", @"t": @5.5},
    ];

    [self.danmakuManager loadFromArray:commentArray];
}

- (void)loadMoreDanmaku {
    NSArray *moreComments = @[
        @{@"cid": @11, @"p": @"6.0,5,14811775,[bilibili1]", @"m": @"再来一波", @"t": @6.0},
        @{@"cid": @12, @"p": @"6.5,5,16777215,[bilibili1]", @"m": @"没想到", @"t": @6.5},
        @{@"cid": @13, @"p": @"7.0,5,16711680,[bilibili1]", @"m": @"妙啊", @"t": @7.0},
        @{@"cid": @14, @"p": @"7.5,5,65280,[bilibili1]", @"m": @"这段好", @"t": @7.5},
        @{@"cid": @15, @"p": @"8.0,5,255,[bilibili1]", @"m": @"绝了", @"t": @8.0},
    ];

    [self.danmakuManager addComments:[[NSArray alloc] initWithArray:moreComments]];
}

- (void)onSpeedChanged:(UISlider *)slider {
    CGFloat speed = slider.value;
    self.danmakuManager.engine.duration = speed;
    self.speedLabel.text = [NSString stringWithFormat:@"%.2f秒", speed];
}

- (void)onAlphaChanged:(UISlider *)slider {
    CGFloat alpha = slider.value;
    self.danmakuManager.engine.alpha = alpha;
    self.alphaLabel.text = [NSString stringWithFormat:@"%.2f", alpha];
}

- (void)onDensityChanged:(UISlider *)slider {
    NSInteger density = (NSInteger)slider.value;
    self.danmakuManager.engine.density = (DanmakuDensity)density;

    NSString *densityText = @"";
    switch (density) {
        case 1: densityText = @"低"; break;
        case 2: densityText = @"中"; break;
        case 3: densityText = @"高"; break;
        default: densityText = @"中"; break;
    }
    self.densityLabel.text = densityText;
}

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
