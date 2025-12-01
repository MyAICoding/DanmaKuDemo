//
//  DanmakuEngineCAVersion.m
//  Danmaku
//

#import "DanmakuEngineCAVersion.h"
#import "DanmakuCATextLayer.h"
#import <QuartzCore/QuartzCore.h>

static const NSInteger MAX_VISIBLE_COMMENTS = 60;
static const NSInteger CACHE_POOL_SIZE = 200;
static const NSInteger TRACK_CHECK_INTERVAL = 3;

@interface DanmakuEngineCAVersion () {
    NSInteger _trackCount;
    NSMutableArray<DanmakuCATextLayer *> *_layerPool;
    NSMutableSet<DanmakuCATextLayer *> *_activeLayersSet;
    NSMutableArray<DanmakuComment *> *_pendingComments;
    CADisplayLink *_displayLink;
    NSLock *_lock;
    NSInteger _frameCounter;
}

@end

@implementation DanmakuEngineCAVersion

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.userInteractionEnabled = NO;

        _duration = 5.0f;
        _alpha = 1.0f;
        _density = DanmakuDensityMedium;
        _fontSize = 16.0f;
        _strokeWidth = 2.0f;
        _strokeColor = [UIColor blackColor];
        _cornerRadius = 0.0f;
        _isPaused = NO;

        CGFloat trackHeight = _fontSize + 8.0f;
        _trackCount = MAX((NSInteger)(frame.size.height / trackHeight), 1);

        _layerPool = [NSMutableArray arrayWithCapacity:CACHE_POOL_SIZE];
        _activeLayersSet = [NSMutableSet set];
        _pendingComments = [NSMutableArray array];
        _lock = [[NSLock alloc] init];
        _frameCounter = 0;

        [self preCreateLayerPool];
        [self setupDisplayLink];
    }
    return self;
}

- (void)preCreateLayerPool {
    for (NSInteger i = 0; i < CACHE_POOL_SIZE; i++) {
        DanmakuCATextLayer *layer = [[DanmakuCATextLayer alloc] init];
        layer.font = [UIFont systemFontOfSize:_fontSize weight:UIFontWeightRegular];
        layer.textColor = [UIColor whiteColor];
        layer.strokeWidth = _strokeWidth;
        layer.strokeColor = _strokeColor;
        layer.opaque = NO;
        [_layerPool addObject:layer];
    }
}

- (void)setupDisplayLink {
    __weak typeof(self) weakSelf = self;
    _displayLink = [CADisplayLink displayLinkWithTarget:weakSelf selector:@selector(updateDanmaku)];
    _displayLink.preferredFramesPerSecond = 60;
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)addComment:(DanmakuComment *)comment {
    if (!comment || !comment.message || comment.message.length == 0) {
        return;
    }

    [_lock lock];
    [_pendingComments addObject:comment];
    [_lock unlock];
}

- (void)addComments:(NSArray<DanmakuComment *> *)comments {
    if (!comments || comments.count == 0) {
        return;
    }

    [_lock lock];
    [_pendingComments addObjectsFromArray:comments];
    [_lock unlock];
}

- (void)updateDanmaku {
    if (_isPaused) {
        return;
    }

    _frameCounter++;
    [_lock lock];

    NSInteger commentsToAdd = [self calculateCommentsToAdd];
    NSMutableArray *commentsToDisplay = [NSMutableArray arrayWithCapacity:commentsToAdd];

    for (NSInteger i = 0; i < commentsToAdd && _pendingComments.count > 0; i++) {
        DanmakuComment *comment = _pendingComments.firstObject;
        [_pendingComments removeObjectAtIndex:0];
        [commentsToDisplay addObject:comment];
    }

    [_lock unlock];

    for (DanmakuComment *comment in commentsToDisplay) {
        [self displayComment:comment];
    }

    if (_frameCounter % TRACK_CHECK_INTERVAL == 0) {
        [self cleanupFinishedAnimations];
    }
}

- (NSInteger)calculateCommentsToAdd {
    NSInteger visibleCount = _activeLayersSet.count;
    NSInteger maxCount = MAX_VISIBLE_COMMENTS / _density;

    if (visibleCount < maxCount) {
        return MIN(maxCount - visibleCount, 3);
    }
    return 0;
}

- (void)displayComment:(DanmakuComment *)comment {
    DanmakuCATextLayer *layer = [self obtainLayer];

    layer.text = comment.message;
    layer.textColor = comment.color;
    layer.opacity = _alpha;
    layer.backgroundColor = _danmakuBackgroundColor;
    layer.cornerRadius = _cornerRadius;

    UIFont *font = [UIFont systemFontOfSize:_fontSize weight:comment.isBold ? UIFontWeightBold : UIFontWeightRegular];
    layer.font = font;

    CGSize size = [layer sizeThatFits:CGSizeMake(CGFLOAT_MAX, _fontSize + 8.0f)];
    if (size.height < _fontSize) {
        size.height = _fontSize + 8.0f;
    }

    NSInteger trackIndex = arc4random_uniform((u_int32_t)_trackCount);
    CGFloat yPosition = trackIndex * size.height;

    layer.frame = CGRectMake(self.bounds.size.width, yPosition, size.width, size.height);
    [self.layer addSublayer:layer];
    [_activeLayersSet addObject:layer];

    [self animateLayerWithCAAnimation:layer duration:_duration];
}

- (void)animateLayerWithCAAnimation:(DanmakuCATextLayer *)layer duration:(CGFloat)duration {
    __weak typeof(self) weakSelf = self;

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setCompletionBlock:^{
        [layer removeFromSuperlayer];
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->_activeLayersSet removeObject:layer];
        [weakSelf recycleLayer:layer];
    }];

    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.fromValue = [NSValue valueWithCGPoint:layer.position];

    CGPoint toPoint = layer.position;
    toPoint.x = -layer.bounds.size.width / 2;
    positionAnimation.toValue = [NSValue valueWithCGPoint:toPoint];

    positionAnimation.duration = duration;
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    positionAnimation.fillMode = kCAFillModeForwards;
    positionAnimation.removedOnCompletion = NO;

    [layer addAnimation:positionAnimation forKey:@"danmakuPosition"];

    [CATransaction commit];
}

- (DanmakuCATextLayer *)obtainLayer {
    DanmakuCATextLayer *layer = nil;

    if (_layerPool.count > 0) {
        layer = _layerPool.lastObject;
        [_layerPool removeLastObject];
    } else {
        layer = [[DanmakuCATextLayer alloc] init];
        layer.font = [UIFont systemFontOfSize:_fontSize weight:UIFontWeightRegular];
        layer.strokeWidth = _strokeWidth;
        layer.strokeColor = _strokeColor;
        layer.opaque = NO;
    }

    return layer;
}

- (void)recycleLayer:(DanmakuCATextLayer *)layer {
    if (_layerPool.count < CACHE_POOL_SIZE) {
        layer.text = nil;
        layer.frame = CGRectZero;
        layer.textColor = [UIColor whiteColor];
        layer.opacity = 1.0f;
        layer.backgroundColor = nil;
        [layer clearCache];
        [layer removeAllAnimations];

        [_layerPool addObject:layer];
    }
}

- (void)cleanupFinishedAnimations {
    NSMutableSet *toRemove = [NSMutableSet set];

    for (DanmakuCATextLayer *layer in _activeLayersSet) {
        if (layer.superlayer == nil) {
            [toRemove addObject:layer];
            [self recycleLayer:layer];
        }
    }

    [_activeLayersSet minusSet:toRemove];
}

- (void)pauseDanmaku {
    if (_isPaused) return;

    _isPaused = YES;
    [_displayLink setPaused:YES];

    for (DanmakuCATextLayer *layer in _activeLayersSet.allObjects) {
        layer.speed = 0.0f;
    }
}

- (void)resumeDanmaku {
    if (!_isPaused) return;

    _isPaused = NO;

    for (DanmakuCATextLayer *layer in _activeLayersSet.allObjects) {
        layer.speed = 1.0f;
    }

    [_displayLink setPaused:NO];
}

- (void)clearAllComments {
    [_lock lock];

    [_pendingComments removeAllObjects];

    for (DanmakuCATextLayer *layer in _activeLayersSet.allObjects) {
        [layer removeAllAnimations];
        [layer removeFromSuperlayer];
        [self recycleLayer:layer];
    }
    [_activeLayersSet removeAllObjects];

    [_lock unlock];
}

- (void)destroy {
    [self clearAllComments];
    [_displayLink invalidate];
    _displayLink = nil;
    [_layerPool removeAllObjects];
}

- (void)dealloc {
    [self destroy];
}

@end
