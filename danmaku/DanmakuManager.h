//
//  DanmakuManager.h
//  Danmaku
//
//  弹幕管理器 - 提供高级接口和配置
//

#import <UIKit/UIKit.h>
#import "DanmakuEngine.h"
#import "DanmakuComment.h"

NS_ASSUME_NONNULL_BEGIN

@interface DanmakuManager : NSObject

/// 弹幕渲染引擎
@property (nonatomic, strong, readonly) DanmakuEngine *engine;

/// 初始化管理器
/// @param containerView 容器视图 (通常是视频播放器上方的透明视图)
/// @param frame 弹幕显示区域 (相对于容器)
- (instancetype)initWithContainerView:(UIView *)containerView frame:(CGRect)frame;

/// 从JSON数据加载弹幕
/// @param jsonData 弹幕JSON数据
- (void)loadFromJSONData:(NSData *)jsonData;

/// 从字典数据加载弹幕
/// @param dictArray 弹幕字典数组
- (void)loadFromArray:(NSArray<NSDictionary *> *)dictArray;

/// 添加单条弹幕
- (void)addComment:(DanmakuComment *)comment;

/// 添加多条弹幕
- (void)addComments:(NSArray<DanmakuComment *> *)comments;

/// 配置基础设置
- (void)configureWithDuration:(CGFloat)duration
                        alpha:(CGFloat)alpha
                      density:(DanmakuDensity)density
                     fontSize:(CGFloat)fontSize;

/// 配置外观设置
- (void)configureAppearanceWithStrokeWidth:(CGFloat)strokeWidth
                                  strokeColor:(UIColor *)strokeColor
                            backgroundColor:(nullable UIColor *)bgColor
                                cornerRadius:(CGFloat)cornerRadius;

/// 暂停
- (void)pause;

/// 恢复
- (void)resume;

/// 清空所有弹幕
- (void)clear;

/// 销毁管理器
- (void)destroy;

@end

NS_ASSUME_NONNULL_END
