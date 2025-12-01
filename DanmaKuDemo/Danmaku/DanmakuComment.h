//
//  DanmakuComment.h
//  Danmaku
//
//  弹幕评论数据模型
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DanmakuComment : NSObject

/// 评论ID
@property (nonatomic, assign) NSInteger cid;

/// 位置信息: time, type, color, [source]
/// p 格式: "time,type,color,[source]"
@property (nonatomic, copy) NSString *p;

/// 弹幕内容
@property (nonatomic, copy) NSString *message;

/// 时间戳 (秒)
@property (nonatomic, assign) CGFloat timestamp;

/// 弹幕类型 (1-5: 滚动, 6: 底部, 7: 顶部, 8: 逆向)
@property (nonatomic, assign) NSInteger type;

/// 弹幕颜色
@property (nonatomic, strong) UIColor *color;

/// 弹幕大小 (默认25)
@property (nonatomic, assign) CGFloat fontSize;

/// 是否是大小号 (0: 标准, 1: 大)
@property (nonatomic, assign) BOOL isBold;

/// 初始化方法
- (instancetype)initWithDictionary:(NSDictionary *)dict;

/// 从原始数据解析位置信息
- (void)parsePositionInfo;

@end

NS_ASSUME_NONNULL_END
