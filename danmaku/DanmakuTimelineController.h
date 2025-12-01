//
//  DanmakuTimelineController.h
//  Danmaku
//
//  弹幕时间轴控制器 - 根据视频播放进度同步显示弹幕
//

#import <UIKit/UIKit.h>
#import "DanmakuManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 时间轴控制器
 用于根据视频播放进度实时显示相应时间点的弹幕
 */
@interface DanmakuTimelineController : NSObject

/// 弹幕管理器
@property (nonatomic, strong, readonly) DanmakuManager *danmakuManager;

/// 当前播放时间 (秒)
@property (nonatomic, assign) CGFloat currentTime;

/// 是否自动清理超时弹幕
@property (nonatomic, assign) BOOL autoCleanExpiredComments;

/// 弹幕显示提前时间 (秒,默认0.5秒提前显示)
@property (nonatomic, assign) CGFloat preFetchTime;

/// 初始化方法
/// @param containerView 容器视图
/// @param frame 弹幕显示区域
/// @param allComments 所有弹幕数据
- (instancetype)initWithContainerView:(UIView *)containerView
                                frame:(CGRect)frame
                           allComments:(NSArray<DanmakuComment *> *)allComments;

/// 初始化方法 (从字典数组)
/// @param containerView 容器视图
/// @param frame 弹幕显示区域
/// @param commentDicts 弹幕字典数组
- (instancetype)initWithContainerView:(UIView *)containerView
                                frame:(CGRect)frame
                       commentDictArray:(NSArray<NSDictionary *> *)commentDicts;

/// 初始化方法 (从JSON)
/// @param containerView 容器视图
/// @param frame 弹幕显示区域
/// @param jsonData 弹幕JSON数据
- (instancetype)initWithContainerView:(UIView *)containerView
                                frame:(CGRect)frame
                             JSONData:(NSData *)jsonData;

/// 更新播放进度
/// @param time 当前播放时间 (秒)
- (void)updatePlaybackTime:(CGFloat)time;

/// 跳转到指定时间 (清空当前弹幕,加载指定时间的弹幕)
/// @param time 目标时间 (秒)
- (void)seekToTime:(CGFloat)time;

/// 暂停
- (void)pause;

/// 恢复
- (void)resume;

/// 清空所有弹幕
- (void)clearAllComments;

/// 销毁资源
- (void)destroy;

@end

NS_ASSUME_NONNULL_END
