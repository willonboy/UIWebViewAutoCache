//
//  ViewController.m
//  WebviewTest
//
//  Created by zt on 16/8/29.
//  Copyright © 2016年 zt. All rights reserved.
//

#import "ViewController.h"
#import "CustomWebView.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "BBPhoneURLProtocol.h"


@interface ViewController () <UIWebViewDelegate>

@property(nonatomic, strong) CustomWebView      *webView;
@property(nonatomic, strong) NSString           *url;
/// UIWebView开始初始化时间(单位妙, 后期上报需要乘1000)
@property (nonatomic) NSTimeInterval startRequestTime;
/// H5所有资源加载完毕(包括mainFrame中引入的iframe/frame, 图片, js, css等) (单位妙, 后期上报需要乘1000)
@property (nonatomic) NSTimeInterval h5PageAllLoadTime;
@end

@implementation ViewController
{
    CFAbsoluteTime startTime;
}

+ (void)load
{
    @autoreleasepool {
        /// 必须提前注册, 否则会出现iframe在一些情况下莫名其妙的重复请求
        [NSURLProtocol registerClass:[BBPhoneURLProtocol class]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.startRequestTime = [[NSDate date] timeIntervalSince1970];
    [self.view addSubview:self.webView = [[CustomWebView alloc] initWithFrame:self.view.bounds]];
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    NSString *url = @"http://www.bilibili.com/html/activity-2233birthday-m.html";
    url = @"http://www.bilibili.com/html/activity-2233birthday.html";
    url = @"http://www.ifanr.com/432516";
    url = @"about:blank;";
    url = @"http://www.bilibili.com/html/activity-cinecism-m.html";
    url = @"http://www.bilibili.com/html/activity-punipuni3-m.html";
    url = @"http://www.bilibili.com/html/activity-2233birthday-m.html";
    url = @"http://www.bilibili.com/html/mobile_MMD.html";
    url = @"http://www.bilibili.com/html/mobile_cover.html";
    url = @"http://www.bilibili.com/html/mobile_ice.html";

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)onClickLeft:(id)sender
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"shouldStartLoadWithRequest %@\n", request.URL.absoluteString);
    if (![request.URL.absoluteString isEqualToString:self.url]) {
        /// 当startRequestTimeOriginal被手动清零后(即H5第一页面加载成功, 并成功上报统计后清零), 请求其他页面需要重新赋值
        if (self.startRequestTime == 0) {
            self.startRequestTime = [[NSDate date] timeIntervalSince1970];
            /// 记录请求时的网络状态
        }
    }
    return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    /// 这里以最后一次赋值为准(h5页面中会有多个iframe/frame会反复走该回调)
    self.h5PageAllLoadTime = [[NSDate date] timeIntervalSince1970];
    JSContext *jscontext = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    /// 统计UIWebView加载H5性能指标
    [self hookPerformanceTiming:jscontext];
    if ([webView canGoBack]) {
        self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(onClickLeft:)]];
    }
}

- (void)hookPerformanceTiming:(JSContext *)jscontext
{
    JSContext *context = jscontext ? : [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    jscontext.exceptionHandler = ^ (JSContext *ctxt, JSValue *exception) {
        NSLog(@"js exception %@", exception);
    };
    NSString *alreadyAddFunc = [[jscontext evaluateScript:@"window.analysised"] toString];
    if ([alreadyAddFunc isEqualToString:@"true"]) {
        return;
    }
    __weak typeof(self) _wself = self;
    context[@"readPerformanceTiming"] = ^() {
        NSLog(@"+++++++Begin Log+++++++");
        NSArray *args = [JSContext currentArguments];
        NSLog(@"+++++++[JSContext currentArguments]+++++++");
        
        NSDictionary *dict = [(JSValue *)[args firstObject] toDictionary];
        NSLog(@"+++++++[args firstObject] toDictionary+++++++");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_wself reportWebViewAnalysis:dict];
        });
    };
    
    NSString *js = @"if(window.analysised==undefined){window.analysised=true;if(document.readyState==\"complete\"){if(window.performance!=undefined){readPerformanceTiming(window.performance.timing);}}else{if(window.performance!=undefined){window.addEventListener(\"load\",function(){readPerformanceTiming(window.performance.timing);},false)}}};";
    [context evaluateScript:js];
}

- (void)reportWebViewAnalysis:(NSDictionary *)dict
{
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSLog(@"%@=%@", key, obj);
    }];
    
    double navigationStart = [(NSNumber *)dict[@"navigationStart"] doubleValue];
    double responseStart = [(NSNumber *)dict[@"responseStart"] doubleValue];
    double responseEnd = [(NSNumber *)dict[@"responseEnd"] doubleValue];
    double domContentLoadedEventEnd = [(NSNumber *)dict[@"domContentLoadedEventEnd"] doubleValue];
    double loadEventEnd = [(NSNumber *)dict[@"loadEventEnd"] doubleValue];
    
    NSDictionary *pars = @{@"page_url":self.url?:@"",
                           @"page_init":@((long)(self.startRequestTime * 1000)).stringValue,
                           @"navigation_start":@(navigationStart).stringValue,
                           @"response_start":@(responseStart).stringValue,
                           @"response_end":@(responseEnd).stringValue,
                           @"dom_content_loaded_event_end":@(domContentLoadedEventEnd).stringValue,
                           @"load_event_end":@(loadEventEnd?:(long)(self.h5PageAllLoadTime * 1000)).stringValue,
                           @"optimize_mode":@(0).stringValue //优化模式，采用位掩码，每位代表一种优化方案，0x0表示没有任何优化，0x1表示使用离线包优化
                           };
    NSLog(@"web analysis %@", pars);
    /// 上报数据
    
    /// 清零
    self.startRequestTime = self.h5PageAllLoadTime = 0;
}


@end
