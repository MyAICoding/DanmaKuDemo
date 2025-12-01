//
//  GetDanmuWebViewController.h
//  OCBarrage
//
//  Created by 王贵彬 on 2025/11/30.
//  Copyright © 2025 LFC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GetDanmuWebViewController : UIViewController

@property (nonatomic,copy) NSString *searchText;
@property (nonatomic,copy) void(^getDanmuDataBlock) (NSString  *json);

@end

NS_ASSUME_NONNULL_END
