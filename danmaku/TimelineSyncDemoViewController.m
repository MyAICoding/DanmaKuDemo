//
//  TimelineSyncDemoViewController.m
//  DanmakuDemo
//
//  时间轴同步演示 - 根据视频播放进度显示弹幕
//

#import <UIKit/UIKit.h>
#import "DanmakuTimelineController.h"

@interface TimelineSyncDemoViewController : UIViewController

@property (nonatomic, strong) DanmakuTimelineController *timelineController;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) NSArray<DanmakuComment *> *allComments;
@property (nonatomic, assign) CGFloat totalDuration;

@end

@implementation TimelineSyncDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"时间轴同步弹幕";

    // ==================== 视频播放区域 ====================
    UIView *videoPlayerView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 300)];
    videoPlayerView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    [self.view addSubview:videoPlayerView];

    // 播放器标签
    UILabel *playerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, videoPlayerView.bounds.size.width, 240)];
    playerLabel.text = @"▶ 视频播放区域\n\n拖动下方进度条\n即时显示对应时间的弹幕";
    playerLabel.textColor = [UIColor whiteColor];
    playerLabel.textAlignment = NSTextAlignmentCenter;
    playerLabel.font = [UIFont systemFontOfSize:16];
    playerLabel.numberOfLines = 0;
    [videoPlayerView addSubview:playerLabel];

    // ==================== 弹幕容器 ====================
    UIView *danmakuContainer = [[UIView alloc] initWithFrame:videoPlayerView.bounds];
    danmakuContainer.backgroundColor = [UIColor clearColor];
    danmakuContainer.userInteractionEnabled = NO;
    [videoPlayerView addSubview:danmakuContainer];

    // ==================== 准备弹幕数据 ====================
    [self prepareDanmakuData];

    // ==================== 初始化时间轴控制器 ====================
    self.timelineController = [[DanmakuTimelineController alloc]
                               initWithContainerView:danmakuContainer
                               frame:danmakuContainer.bounds
                               allComments:_allComments];

    // 配置弹幕
    [self.timelineController.danmakuManager configureWithDuration:5.0f
                                                             alpha:1.0f
                                                           density:DanmakuDensityMedium
                                                          fontSize:14.0f];

    [self.timelineController.danmakuManager configureAppearanceWithStrokeWidth:2.0f
                                                                   strokeColor:[UIColor blackColor]
                                                             backgroundColor:nil
                                                                 cornerRadius:0.0f];

    // ==================== 控制界面 ====================
    UIView *controlPanel = [[UIView alloc]
                            initWithFrame:CGRectMake(0, 420, self.view.bounds.size.width, self.view.bounds.size.height - 420)];
    controlPanel.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
    [self.view addSubview:controlPanel];

    // 时间显示标签
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, self.view.bounds.size.width - 40, 30)];
    self.timeLabel.textColor = [UIColor systemYellowColor];
    self.timeLabel.font = [UIFont monospacedSystemFontOfSize:16 weight:UIFontWeightRegular];
    self.timeLabel.text = [NSString stringWithFormat:@"时间: 0.00s / %.2fs", _totalDuration];
    [controlPanel addSubview:self.timeLabel];

    // 进度滑块
    self.progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 50, self.view.bounds.size.width - 40, 30)];
    self.progressSlider.minimumValue = 0;
    self.progressSlider.maximumValue = _totalDuration;
    self.progressSlider.value = 0;
    [self.progressSlider addTarget:self action:@selector(onProgressChanged:) forControlEvents:UIControlEventValueChanged];
    [controlPanel addSubview:self.progressSlider];

    // 说明文字
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, self.view.bounds.size.width - 40, 60)];
    infoLabel.text = @"📌 使用说明:\n1. 拖动进度条查看任意时间点的弹幕\n2. 弹幕会根据时间戳自动显示\n3. 支持快速跳转和单帧加载";
    infoLabel.textColor = [UIColor lightGrayColor];
    infoLabel.font = [UIFont systemFontOfSize:12];
    infoLabel.numberOfLines = 0;
    [controlPanel addSubview:infoLabel];
}

- (void)prepareDanmakuData {
    // 生成时间轴上的弹幕数据
    NSMutableArray<DanmakuComment *> *comments = [NSMutableArray array];

    NSArray *texts = @[
        @"时间轴同步",
        @"拖动进度条",
        @"实时显示弹幕",
        @"支持快速跳转",
        @"完美同步",
        @"高品质渲染",
        @"流畅动画",
        @"生产级质量",
        @"推荐使用",
        @"棒棒哒"
    ];

    NSArray *colors = @[
        @16777215,  // 白
        @16711680,  // 红
        @65280,     // 绿
        @255,       // 蓝
        @16776960,  // 黄
        @16711935,  // 品红
        @65535,     // 青
        @13382401,  // 灰
        @9420159,   // 深紫
        @16776704   // 橙
    ];

    // 在 0-20 秒的时间范围内生成弹幕
    for (NSInteger i = 0; i < 30; i++) {
        CGFloat timestamp = (i * 20.0f) / 30.0f;  // 均匀分布在 0-20 秒
        NSString *text = texts[i % texts.count];
        NSInteger color = [colors[i % colors.count] integerValue];

        DanmakuComment *comment = [[DanmakuComment alloc] initWithDictionary:@{
            @"cid": @(i),
            @"p": [NSString stringWithFormat:@"%.2f,5,%ld,[timeline]", timestamp, (long)color],
            @"m": [NSString stringWithFormat:@"%s %@", i < 10 ? "0" : "", text],
            @"t": @(timestamp)
        }];

        [comments addObject:comment];
    }

    // 设置总时长
    _totalDuration = 20.0f;
    _allComments = comments;
}

- (void)onProgressChanged:(UISlider *)slider {
    CGFloat currentTime = slider.value;

    // 更新时间标签
    self.timeLabel.text = [NSString stringWithFormat:@"时间: %.2fs / %.2fs", currentTime, _totalDuration];

    // 更新时间轴控制器
    [self.timelineController updatePlaybackTime:currentTime];
}

- (void)dealloc {
    [self.timelineController destroy];
}

@end
