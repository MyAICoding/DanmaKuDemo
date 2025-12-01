//
//  DanmakuEngineCAVersion.h
//  Danmaku
//
//  使用 CATextLayer 的高品质弹幕引擎
//

#import <UIKit/UIKit.h>
#import "DanmakuComment.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DanmakuDensity) {
    DanmakuDensityLow = 1,
    DanmakuDensityMedium = 2,
    DanmakuDensityHigh = 3
};

/**
 CATextLayer 版本的弹幕引擎
 相比 UILabel 版本:
 - 文本更清晰锐利
 - 性能更优 (CALayer 比 UIView 更轻)
 - 内存占用更低
 - 渲染品质更高
 */
@interface DanmakuEngineCAVersion : UIView

/// 弹幕速度 (秒)
@property (nonatomic, assign) CGFloat duration;

/// 透明度 (0-1)
@property (nonatomic, assign) CGFloat alpha;

/// 密度
@property (nonatomic, assign) DanmakuDensity density;

/// 字体大小
@property (nonatomic, assign) CGFloat fontSize;

/// 描边宽度
@property (nonatomic, assign) CGFloat strokeWidth;

/// 描边颜色
@property (nonatomic, strong) UIColor *strokeColor;

/// 背景色
@property (nonatomic, strong, nullable) UIColor *danmakuBackgroundColor;

/// 背景圆角
@property (nonatomic, assign) CGFloat cornerRadius;

/// 是否暂停
@property (nonatomic, assign) BOOL isPaused;

/// 初始化方法
- (instancetype)initWithFrame:(CGRect)frame;

/// 添加弹幕
- (void)addComment:(DanmakuComment *)comment;

/// 添加多个弹幕
- (void)addComments:(NSArray<DanmakuComment *> *)comments;

/// 清空所有弹幕
- (void)clearAllComments;

/// 暂停
- (void)pauseDanmaku;

/// 恢复
- (void)resumeDanmaku;

/// 销毁
- (void)destroy;

@end

NS_ASSUME_NONNULL_END
