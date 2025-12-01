//
//  DanmakuComment.m
//  Danmaku
//

#import "DanmakuComment.h"

@implementation DanmakuComment

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _cid = [dict[@"cid"] integerValue];
        _p = dict[@"p"];
        _message = dict[@"m"];
        _timestamp = [dict[@"t"] floatValue];
        _fontSize = 25.0f;
        _isBold = NO;

        [self parsePositionInfo];
    }
    return self;
}

- (void)parsePositionInfo {
    if (!self.p || self.p.length == 0) {
        self.type = 1; // 默认滚动弹幕
        self.color = [UIColor whiteColor];
        return;
    }

    NSArray *components = [self.p componentsSeparatedByString:@","];
    if (components.count >= 3) {
        // type (第二个参数)
        self.type = [components[1] integerValue];

        // color (第三个参数，十进制转RGB)
        NSInteger colorValue = [components[2] integerValue];
        self.color = [self colorFromIntValue:colorValue];

        // 检查是否有其他属性
        if (components.count > 3) {
            NSString *extra = components[3];
            if ([extra containsString:@"bold"]) {
                self.isBold = YES;
            }
        }
    }
}

- (UIColor *)colorFromIntValue:(NSInteger)value {
    CGFloat red = ((value >> 16) & 0xFF) / 255.0f;
    CGFloat green = ((value >> 8) & 0xFF) / 255.0f;
    CGFloat blue = (value & 0xFF) / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

@end
