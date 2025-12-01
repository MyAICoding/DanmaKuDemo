//
//  DanmakuEngine.h
//  Danmaku
//
//  弹幕引擎 - 高性能弹幕渲染核心
//

#import <UIKit/UIKit.h>
#import "DanmakuComment.h"

NS_ASSUME_NONNULL_BEGIN

/// 弹幕密度等级
typedef NS_ENUM(NSInteger, DanmakuDensity) {
    DanmakuDensityLow = 1,      // 低密度
    DanmakuDensityMedium = 2,   // 中密度
    DanmakuDensityHigh = 3      // 高密度
};

@interface DanmakuEngine : UIView

/// 弹幕速度 (秒, 默认5)
@property (nonatomic, assign) CGFloat duration;

/// 弹幕透明度 (0-1, 默认1.0)
@property (nonatomic, assign) CGFloat alpha;

/// 弹幕密度
@property (nonatomic, assign) DanmakuDensity density;

/// 弹幕字体大小 (默认16)
@property (nonatomic, assign) CGFloat fontSize;

/// 描边宽度 (默认2.0)
@property (nonatomic, assign) CGFloat strokeWidth;

/// 描边颜色 (默认黑色)
@property (nonatomic, strong) UIColor *strokeColor;

/// 弹幕背景色 (可选)
@property (nonatomic, strong, nullable) UIColor *danmakuBackgroundColor;

/// 背景圆角
@property (nonatomic, assign) CGFloat cornerRadius;

/// 是否暂停
@property (nonatomic, assign) BOOL isPaused;

/// 初始化方法
- (instancetype)initWithFrame:(CGRect)frame;

/// 添加弹幕评论
- (void)addComment:(DanmakuComment *)comment;

/// 添加多个弹幕评论
- (void)addComments:(NSArray<DanmakuComment *> *)comments;

/// 清空所有弹幕
- (void)clearAllComments;

/// 暂停弹幕
- (void)pauseDanmaku;

/// 恢复弹幕
- (void)resumeDanmaku;

/// 销毁引擎释放资源
- (void)destroy;

@end

NS_ASSUME_NONNULL_END
