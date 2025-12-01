//
//  DanmakuCATextLayer.h
//  Danmaku
//
//  使用 CATextLayer 实现的高品质弹幕 - 更清晰,性能更优
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 CATextLayer 版本的弹幕
 相比 UILabel 版本:
 - 文本渲染更清晰
 - 性能更优 (避免 UIView 布局开销)
 - 内存占用更低
 - 支持更多自定义选项
 */
@interface DanmakuCATextLayer : CALayer

/// 弹幕文本内容
@property (nonatomic, copy) NSString *text;

/// 字体
@property (nonatomic, strong) UIFont *font;

/// 文字颜色
@property (nonatomic, strong) UIColor *textColor;

/// 描边宽度
@property (nonatomic, assign) CGFloat strokeWidth;

/// 描边颜色
@property (nonatomic, strong) UIColor *strokeColor;

/// 背景颜色
@property (nonatomic, strong, nullable) UIColor *backgroundColor;

/// 背景圆角
@property (nonatomic, assign) CGFloat cornerRadius;

/// 背景内边距
@property (nonatomic, assign) UIEdgeInsets backgroundPadding;

/// 文本对齐方式
@property (nonatomic, assign) NSTextAlignment textAlignment;

/// 初始化方法
+ (instancetype)danmakuLayerWithText:(NSString *)text
                                font:(UIFont *)font
                           textColor:(UIColor *)textColor;

/// 计算文本大小
- (CGSize)sizeThatFits:(CGSize)constrainedSize;

/// 清除缓存
- (void)clearCache;

@end

NS_ASSUME_NONNULL_END
