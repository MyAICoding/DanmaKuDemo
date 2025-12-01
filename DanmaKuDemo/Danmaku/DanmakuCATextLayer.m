//
//  DanmakuCATextLayer.m
//  Danmaku
//

#import "DanmakuCATextLayer.h"
#import <CoreText/CoreText.h>

@interface DanmakuCATextLayer ()

@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, strong) CATextLayer *textLayer;
@property (nonatomic, strong) CATextLayer *strokeLayer;
@property (nonatomic, assign) CGSize cachedSize;
@property (nonatomic, copy) NSString *cachedText;

@end



@implementation DanmakuCATextLayer

@synthesize backgroundColor = _backgroundColor;
@synthesize cornerRadius = _cornerRadius;

+ (instancetype)danmakuLayerWithText:(NSString *)text
                                font:(UIFont *)font
                           textColor:(UIColor *)textColor {
    DanmakuCATextLayer *layer = [[DanmakuCATextLayer alloc] init];
    layer.text = text;
    layer.font = font;
    layer.textColor = textColor;
    layer.strokeWidth = 2.0f;
    layer.strokeColor = [UIColor blackColor];
    layer.cornerRadius = 0.0f;
    layer.backgroundPadding = UIEdgeInsetsMake(4, 6, 4, 6);
    layer.textAlignment = NSTextAlignmentCenter;

    return layer;
}

- (instancetype)init {
    if (self = [super init]) {
        // 初始化背景层
        _backgroundLayer = [CAShapeLayer layer];
        _backgroundLayer.fillColor = [UIColor clearColor].CGColor;
        [self addSublayer:_backgroundLayer];

        // 初始化描边文本层
        _strokeLayer = [[CATextLayer alloc] init];
        _strokeLayer.alignmentMode = kCAAlignmentCenter;
        _strokeLayer.truncationMode = kCATruncationEnd;
        _strokeLayer.wrapped = NO;
        _strokeLayer.opaque = NO;
        [self addSublayer:_strokeLayer];

        // 初始化普通文本层
        _textLayer = [[CATextLayer alloc] init];
        _textLayer.alignmentMode = kCAAlignmentCenter;
        _textLayer.truncationMode = kCATruncationEnd;
        _textLayer.wrapped = NO;
        _textLayer.opaque = NO;
        [self addSublayer:_textLayer];

        _cachedSize = CGSizeZero;
    }
    return self;
}

- (void)setText:(NSString *)text {
    if ([_cachedText isEqualToString:text]) {
        return;
    }

    _text = [text copy];
    _cachedText = [text copy];
    _cachedSize = CGSizeZero;

    [self updateTextLayers];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    [self updateTextLayers];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    if (_textLayer) {
        _textLayer.foregroundColor = textColor.CGColor;
    }
}

- (void)setStrokeWidth:(CGFloat)strokeWidth {
    _strokeWidth = strokeWidth;
    [self updateTextLayers];
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    [self updateTextLayers];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    [self updateBackgroundLayer];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self updateBackgroundLayer];
}

- (void)updateTextLayers {
    if (!_text || _text.length == 0) {
        return;
    }

    // 更新字体
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)_font.fontName,
                                            _font.pointSize, NULL);

    // 描边层 - 使用 NSAttributedString
    NSMutableDictionary *strokeAttrs = [NSMutableDictionary dictionary];
    strokeAttrs[(NSString *)kCTFontAttributeName] = (__bridge id)ctFont;

    if (_strokeWidth > 0 && _strokeColor) {
        strokeAttrs[(NSString *)kCTStrokeWidthAttributeName] = @(-_strokeWidth);
        strokeAttrs[(NSString *)kCTStrokeColorAttributeName] = (__bridge id)_strokeColor.CGColor;
    }

    NSAttributedString *strokeAttrString = [[NSAttributedString alloc]
        initWithString:_text attributes:strokeAttrs];
    _strokeLayer.string = strokeAttrString;
    _strokeLayer.font = (__bridge CFTypeRef)_font;
    _strokeLayer.fontSize = _font.pointSize;

    // 普通文本层
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[(NSString *)kCTFontAttributeName] = (__bridge id)ctFont;
    textAttrs[(NSString *)kCTForegroundColorAttributeName] = (__bridge id)_textColor.CGColor;

    NSAttributedString *textAttrString = [[NSAttributedString alloc]
        initWithString:_text attributes:textAttrs];
    _textLayer.string = textAttrString;
    _textLayer.font = (__bridge CFTypeRef)_font;
    _textLayer.fontSize = _font.pointSize;
    _textLayer.foregroundColor = _textColor.CGColor;

    CFRelease(ctFont);

    // 计算大小
    _cachedSize = [self calculateTextSize];

    // 更新层的大小和位置
    [self layoutTextLayers];
    [self updateBackgroundLayer];
}

- (CGSize)calculateTextSize {
    if (!_text || _text.length == 0) {
        return CGSizeZero;
    }

    NSDictionary *attributes = @{
        NSFontAttributeName: _font
    };

    CGSize size = [_text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, _font.lineHeight)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attributes
                                     context:nil].size;

    return CGSizeMake(ceil(size.width) + _backgroundPadding.left + _backgroundPadding.right,
                      ceil(size.height) + _backgroundPadding.top + _backgroundPadding.bottom);
}

- (void)layoutTextLayers {
    CGSize size = _cachedSize;

    if (size.width == 0 || size.height == 0) {
        return;
    }

    CGFloat textY = _backgroundPadding.top;
    CGFloat textHeight = size.height - _backgroundPadding.top - _backgroundPadding.bottom;

    // 设置描边层
    _strokeLayer.frame = CGRectMake(_backgroundPadding.left,
                                    textY,
                                    size.width - _backgroundPadding.left - _backgroundPadding.right,
                                    textHeight);

    // 设置文本层
    _textLayer.frame = CGRectMake(_backgroundPadding.left,
                                  textY,
                                  size.width - _backgroundPadding.left - _backgroundPadding.right,
                                  textHeight);
}

- (void)updateBackgroundLayer {
    if (!_backgroundColor || [_backgroundColor isEqual:[UIColor clearColor]]) {
        _backgroundLayer.hidden = YES;
        return;
    }

    _backgroundLayer.hidden = NO;

    CGSize size = _cachedSize;
    if (size.width == 0 || size.height == 0) {
        return;
    }

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height)
                                                     cornerRadius:_cornerRadius];
    _backgroundLayer.path = path.CGPath;
    _backgroundLayer.fillColor = _backgroundColor.CGColor;
}

- (CGSize)sizeThatFits:(CGSize)constrainedSize {
    if (_cachedSize.width > 0 && _cachedSize.height > 0) {
        return _cachedSize;
    }

    return [self calculateTextSize];
}

- (void)clearCache {
    _cachedText = nil;
    _cachedSize = CGSizeZero;
}

@end
