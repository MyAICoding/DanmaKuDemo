//
//  DanmakuLabel.h
//  Danmaku
//
//  带描边效果的弹幕标签 (高性能优化版)
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DanmakuLabel : UILabel

/// 描边宽度 (默认2.0)
@property (nonatomic, assign) CGFloat strokeWidth;

/// 描边颜色 (默认黑色)
@property (nonatomic, strong) UIColor *strokeColor;

/// 背景色 (可选)
@property (nonatomic, strong, nullable) UIColor *backgroundColor;

/// 背景圆角 (默认0)
@property (nonatomic, assign) CGFloat cornerRadius;

/// 背景内边距
@property (nonatomic, assign) UIEdgeInsets backgroundPadding;

/// 缓存的描边文本 (性能优化)
@property (nonatomic, strong, nullable) NSAttributedString *cachedStrokeText;

/// 缓存的文本内容 (用于检测变更)
@property (nonatomic, copy, nullable) NSString *cachedTextContent;

@end

NS_ASSUME_NONNULL_END
