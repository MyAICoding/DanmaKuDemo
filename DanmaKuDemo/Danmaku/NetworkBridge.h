//
//  NetworkBridge.h
//  DanmaKuDemo
//
//  Created by 王贵彬 on 2025/11/30.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkBridge : NSObject <WKScriptMessageHandler>

// 持有 WebView 的弱引用，以便回调 JS
@property (nonatomic, weak) WKWebView *webView;

// 初始化方法
- (instancetype)initWithWebView:(WKWebView *)webView;

// 注册供 JS 调用的方法名
- (void)registerHandler;

// 移除（防止内存泄漏）
- (void)removeHandler;

@end

NS_ASSUME_NONNULL_END
