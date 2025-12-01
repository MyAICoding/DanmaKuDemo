//
//  NetworkBridge.m
//  DanmaKuDemo
//
//  Created by 王贵彬 on 2025/11/30.
//

#import "NetworkBridge.h"

@implementation NetworkBridge

- (instancetype)initWithWebView:(WKWebView *)webView {
    self = [super init];
    if (self) {
        _webView = webView;
    }
    return self;
}

- (void)registerHandler {
    // 注册一个名为 "nativeRequest" 的消息处理器
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"nativeRequest"];
}

- (void)removeHandler {
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"nativeRequest"];
}

// 接收 JS 消息的核心方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"nativeRequest"]) {
        NSDictionary *body = message.body;
        if (![body isKindOfClass:[NSDictionary class]]) return;
        
        NSString *urlStr = body[@"url"];
        NSString *method = body[@"method"] ?: @"GET";
        NSDictionary *headers = body[@"headers"];
        NSString *requestBody = body[@"body"];
        NSString *callbackId = body[@"callbackId"]; // JS 生成的唯一ID，用于回调
        
        if (urlStr && callbackId) {
            [self performRequestWithURL:urlStr method:method headers:headers body:requestBody callbackId:callbackId];
        }
    }
}

// 发起原生网络请求 (绕过 CORS)
- (void)performRequestWithURL:(NSString *)urlString method:(NSString *)method headers:(NSDictionary *)headers body:(NSString *)bodyStr callbackId:(NSString *)callbackId {
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = method;
    
    // 设置请求头
    if (headers) {
        for (NSString *key in headers) {
            [request setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    
    // 设置 Body
    if (bodyStr && ![bodyStr isKindOfClass:[NSNull class]] && bodyStr.length > 0) {
        request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    // 使用 URLSession 发起请求
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSMutableDictionary *resultData = [NSMutableDictionary dictionary];
        
        if (error) {
            resultData[@"success"] = @(NO);
            resultData[@"error"] = error.localizedDescription;
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            resultData[@"success"] = @(YES);
            resultData[@"status"] = @(httpResponse.statusCode);
            
            if (data) {
                // 将二进制数据转为 String 回传给 JS
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                resultData[@"data"] = responseString ?: @"";
                //printf("native请求成功 %s \n",responseString.UTF8String);
            }
        }
        
        // 回调 JS
        [self sendResponseToJS:resultData callbackId:callbackId];
    }];
    
    [task resume];
}

// 将结果传回给 JS
- (void)sendResponseToJS:(NSDictionary *)result callbackId:(NSString *)callbackId {
    // 将字典转为 JSON 字符串，防止特殊字符导致 JS 语法错误
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:&error];
    if (!jsonData) return;
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    // 调用 JS 全局函数: window.handleNativeResponse(callbackId, jsonResponse)
    NSString *jsCode = [NSString stringWithFormat:@"window.handleNativeResponse('%@', %@)", callbackId, jsonString];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webView evaluateJavaScript:jsCode completionHandler:^(id result,NSError *error){
            if (error) {
                NSLog(@"注入请求回调的js失败 %@",error);
            }
        }];
    });
}

@end
