//
//  DanmakuTimelineController.m
//  Danmaku
//
//  时间轴控制实现
//

#import "DanmakuTimelineController.h"

@interface DanmakuTimelineController ()

@property (nonatomic, strong) DanmakuManager *danmakuManager;
@property (nonatomic, strong) NSArray<DanmakuComment *> *allComments;
@property (nonatomic, strong) NSMutableSet<NSNumber *> *displayedCommentIds;
@property (nonatomic, assign) CGFloat lastUpdateTime;

@end

@implementation DanmakuTimelineController

- (instancetype)initWithContainerView:(UIView *)containerView
                                frame:(CGRect)frame
                           allComments:(NSArray<DanmakuComment *> *)allComments {
    if (self = [super init]) {
        _danmakuManager = [[DanmakuManager alloc]
                           initWithContainerView:containerView
                           frame:frame];

        _allComments = [allComments sortedArrayUsingComparator:^NSComparisonResult(DanmakuComment *obj1, DanmakuComment *obj2) {
            if (obj1.timestamp < obj2.timestamp) {
                return NSOrderedAscending;
            } else if (obj1.timestamp > obj2.timestamp) {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }];

        _displayedCommentIds = [NSMutableSet set];
        _autoCleanExpiredComments = YES;
        _preFetchTime = 0.5f;
        _lastUpdateTime = -1.0f;
        _currentTime = 0.0f;
    }
    return self;
}

- (instancetype)initWithContainerView:(UIView *)containerView
                                frame:(CGRect)frame
                       commentDictArray:(NSArray<NSDictionary *> *)commentDicts {
    NSMutableArray<DanmakuComment *> *comments = [NSMutableArray arrayWithCapacity:commentDicts.count];
    for (NSDictionary *dict in commentDicts) {
        DanmakuComment *comment = [[DanmakuComment alloc] initWithDictionary:dict];
        [comments addObject:comment];
    }

    return [self initWithContainerView:containerView
                                 frame:frame
                            allComments:comments];
}

- (instancetype)initWithContainerView:(UIView *)containerView
                                frame:(CGRect)frame
                             JSONData:(NSData *)jsonData {
    NSError *error = nil;
    NSArray *dictArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

    if (error || !dictArray) {
        NSLog(@"Failed to parse JSON: %@", error);
        return nil;
    }

    return [self initWithContainerView:containerView
                                 frame:frame
                        commentDictArray:dictArray];
}

- (void)updatePlaybackTime:(CGFloat)time {
    // 避免频繁更新,只在时间明显变化时更新
    if (ABS(time - _lastUpdateTime) < 0.01f) {
        return;
    }

    _currentTime = time;
    _lastUpdateTime = time;

    // 寻找需要显示的弹幕
    CGFloat windowStart = time;
    CGFloat windowEnd = time + _preFetchTime;

    NSMutableArray<DanmakuComment *> *commentsToAdd = [NSMutableArray array];

    for (DanmakuComment *comment in _allComments) {
        // 在时间窗口内且还没有显示过
        if (comment.timestamp >= windowStart && comment.timestamp <= windowEnd &&
            ![_displayedCommentIds containsObject:@(comment.cid)]) {
            [commentsToAdd addObject:comment];
            [_displayedCommentIds addObject:@(comment.cid)];
        }
    }

    // 批量添加新弹幕
    if (commentsToAdd.count > 0) {
        [_danmakuManager addComments:commentsToAdd];
    }
}

- (void)seekToTime:(CGFloat)time {
    // 清除所有弹幕
    [_danmakuManager clear];

    // 重置状态
    [_displayedCommentIds removeAllObjects];
    _lastUpdateTime = -1.0f;
    _currentTime = time;

    // 加载指定时间的弹幕
    [self updatePlaybackTime:time];
}

- (void)pause {
    [_danmakuManager pause];
}

- (void)resume {
    [_danmakuManager resume];
}

- (void)clearAllComments {
    [_danmakuManager clear];
    [_displayedCommentIds removeAllObjects];
}

- (void)destroy {
    [_danmakuManager destroy];
    [_displayedCommentIds removeAllObjects];
}

@end
