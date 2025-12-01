//
//  DanmakuManager.m
//  Danmaku
//

#import "DanmakuManager.h"

@interface DanmakuManager ()

@property (nonatomic, strong) DanmakuEngine *engine;
@property (nonatomic, strong) UIView *containerView;

@end

@implementation DanmakuManager

- (instancetype)initWithContainerView:(UIView *)containerView frame:(CGRect)frame {
    if (self = [super init]) {
        _containerView = containerView;
        _engine = [[DanmakuEngine alloc] initWithFrame:frame];
        [containerView addSubview:_engine];
    }
    return self;
}

- (void)loadFromJSONData:(NSData *)jsonData {
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

    if (error || !dict) {
        NSLog(@"Failed to parse JSON: %@", error);
        return;
    }

    NSArray *comments = dict[@"comments"];
    [self loadFromArray:comments];
}

- (void)loadFromArray:(NSArray<NSDictionary *> *)dictArray {
    if (!dictArray || dictArray.count == 0) {
        return;
    }

    NSMutableArray<DanmakuComment *> *comments = [NSMutableArray arrayWithCapacity:dictArray.count];
    for (NSDictionary *dict in dictArray) {
        DanmakuComment *comment = [[DanmakuComment alloc] initWithDictionary:dict];
        [comments addObject:comment];
    }

    // 按时间戳排序
    [comments sortUsingComparator:^NSComparisonResult(DanmakuComment *obj1, DanmakuComment *obj2) {
        if (obj1.timestamp < obj2.timestamp) {
            return NSOrderedAscending;
        } else if (obj1.timestamp > obj2.timestamp) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];

    [_engine addComments:comments];
}

- (void)addComment:(DanmakuComment *)comment {
    [_engine addComment:comment];
}

- (void)addComments:(NSArray<DanmakuComment *> *)comments {
    [_engine addComments:comments];
}

- (void)configureWithDuration:(CGFloat)duration
                        alpha:(CGFloat)alpha
                      density:(DanmakuDensity)density
                     fontSize:(CGFloat)fontSize {
    _engine.duration = duration;
    _engine.alpha = alpha;
    _engine.density = density;
    _engine.fontSize = fontSize;
}

- (void)configureAppearanceWithStrokeWidth:(CGFloat)strokeWidth
                                strokeColor:(UIColor *)strokeColor
                          backgroundColor:(nullable UIColor *)bgColor
                              cornerRadius:(CGFloat)cornerRadius {
    _engine.strokeWidth = strokeWidth;
    _engine.strokeColor = strokeColor;
    _engine.danmakuBackgroundColor = bgColor;
    _engine.cornerRadius = cornerRadius;
}

- (void)pause {
    [_engine pauseDanmaku];
}

- (void)resume {
    [_engine resumeDanmaku];
}

- (void)clear {
    [_engine clearAllComments];
}

- (void)destroy {
    [_engine destroy];
}

@end
