//
//  DanmakuLabel.m
//  Danmaku
//
//  高性能优化版本
//

#import "DanmakuLabel.h"

@implementation DanmakuLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _strokeWidth = 2.0f;
        _strokeColor = [UIColor blackColor];
        _cornerRadius = 0.0f;
        _backgroundPadding = UIEdgeInsetsMake(4, 6, 4, 6);

        // 性能优化: 启用光栅化
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.clipsToBounds = NO;
    }
    return self;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    // 清除缓存，文本改变时重新生成
    self.cachedStrokeText = nil;
    self.cachedTextContent = nil;
}

- (void)drawTextInRect:(CGRect)rect {
    // 绘制背景 (仅在需要时)
    if (self.backgroundColor && ![self.backgroundColor isEqual:[UIColor clearColor]]) {
        [self drawBackgroundInRect:rect];
    }

    // 绘制描边效果 (使用缓存优化)
    if (self.strokeWidth > 0 && self.strokeColor && self.text) {
        [self drawStrokeInRect:rect];
    }

    // 绘制正常的文字
    [super drawTextInRect:rect];
}

- (void)drawBackgroundInRect:(CGRect)rect {
    CGRect bgRect = CGRectInset(rect, -self.backgroundPadding.left, -self.backgroundPadding.top);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bgRect cornerRadius:self.cornerRadius];
    [self.backgroundColor setFill];
    [path fill];
}

- (void)drawStrokeInRect:(CGRect)rect {
    // 生成缓存的描边属性文本 (仅在文本变更时生成)
    if (!self.cachedStrokeText || ![self.cachedTextContent isEqualToString:self.text]) {
        self.cachedTextContent = self.text;

        NSMutableDictionary *strokeAttributes = [NSMutableDictionary dictionary];
        strokeAttributes[NSFontAttributeName] = self.font ?: [UIFont systemFontOfSize:17.0f];
        strokeAttributes[NSStrokeWidthAttributeName] = @(-self.strokeWidth);
        strokeAttributes[NSStrokeColorAttributeName] = self.strokeColor;

        self.cachedStrokeText = [[NSAttributedString alloc] initWithString:self.text attributes:strokeAttributes];
    }

    // 直接使用缓存的描边文本绘制
    [self.cachedStrokeText drawInRect:rect];
}

@end
