//
//  GetDanmuWebViewController.m
//  OCBarrage
//
//  Created by 王贵彬 on 2025/11/30.
//  Copyright © 2025 LFC. All rights reserved.
//

#import "GetDanmuWebViewController.h"
#import <WebKit/WebKit.h>
#import "NetworkBridge.h"

@interface GetDanmuWebViewController ()<WKUIDelegate,WKScriptMessageHandler,WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NetworkBridge *networkBridge;

@end

@implementation GetDanmuWebViewController

- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        [config.preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];
        if (@available(iOS 10.0, *)) {
            [config setValue:@YES forKey:@"allowUniversalAccessFromFileURLs"];
        }
        if (@available(iOS 14.0, *)) {
            config.defaultWebpagePreferences.allowsContentJavaScript = YES;
        }else {
            config.preferences.javaScriptEnabled = YES;
        }
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (void)dealloc {
    [self.networkBridge removeHandler];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.webView.frame = self.view.bounds;
    // 初始化桥接
    self.networkBridge = [[NetworkBridge alloc] initWithWebView:self.webView];
    [self.networkBridge registerHandler]; // 注册 'nativeRequest'
    NSString *path = [[NSBundle mainBundle] pathForResource:@"danmaku.html" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:req];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self.webView configuration].userContentController addScriptMessageHandler:self name:@"getDanmuFromJS"];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[self.webView configuration].userContentController  removeScriptMessageHandlerForName:@"getDanmuFromJS"];
}


///JS执行window.webkit.messageHandlers.<方法名>.postMessage(<数据>).
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
   // NSLog(@"方法名是message.name = %@ \n 参数message.body = %@",message.name,message.body);
    if ([message.name isEqualToString:@"getDanmuFromJS"]) {
        !self.getDanmuDataBlock? : self.getDanmuDataBlock(message.body);
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


//页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    NSString *js = [NSString stringWithFormat:@"document.documentElement.style.webkitTouchCallout='none';document.getElementById('search-input').value='%@';",self.searchText?:@""];
    [webView evaluateJavaScript:js completionHandler:nil];
}



- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
