//
//  RootViewController.m
//  WebViewCacheDemo
//
//  Created by tao on 14-7-3.
//  Copyright (c) 2014年 willonboy. All rights reserved.
//

#import "RootViewController.h"
#import "CustomUrlCache.h"
#import "WTURLProtocol.h"

@interface RootViewController ()

@end

@implementation RootViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self cacheByUrlCache];
    [self cacheByUrlProtocol];
}

- (void)cacheByUrlCache
{
    NSDictionary *localWebSourcesFiles = @{@"http://www.ifanr.com/res/css/message.css":@"message.css",
                                           @"http://www.ifanr.com/res/js/lib/jquery.js":@"jquery.js"};
    [CustomUrlCache setReplaceRequestFileWithLocalFile:localWebSourcesFiles];
    
    self.webView = [[AutoCacheWebView alloc] initWithFrame:CGRectMake(0, 64, 320, 504)];
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
    
    NSString *baseUrl = @"http://www.ifanr.com";
    NSString *url = @"/432516";
    
    [self.webView loadUrl:url baseUrl:baseUrl responseEncodingName:NSUTF8StringEncoding completeBlock:^(NSError *err) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请求html完成" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)cacheByUrlProtocol
{
    NSDictionary *localWebSourcesFiles = @{@"http://cdnzz.ifanr.com/wp-content/plugins/ifanr-widget-buzz/dist/build/buzz.auto_create_ts_1446046962.css?ver=4.2.4":@"message.css",
                                           @"http://images.ifanr.cn/wp-content/uploads/2014/07/DSCF2493.jpg":@"test.jpg",
                                           @"http://images.ifanr.cn/wp-content/uploads/2016/02/zhuzhanzhengwen.jpg":@"test.jpg",
                                           @"http://cdn.ifanr.cn/wp-content/themes/apple4us/js/libs/jquery/1.10.1/jquery.min.js?ver=4.2.4":@"jquery.js"};
    [WTURLProtocol setReplaceRequestFileWithLocalFile:localWebSourcesFiles];
    [WTURLProtocol buildGlobalWebCache];
    
    self.webView2 = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, 320, 504)];
    self.webView2.delegate = self;
    self.webView2.scalesPageToFit = YES;
    [self.view addSubview:self.webView2];
    
    NSString *baseUrl = @"http://www.ifanr.com";
    NSString *url = @"/432516";
    
    [self.webView2 loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url relativeToURL:[NSURL URLWithString:baseUrl]]]];
}


- (IBAction)refreshBtnClicked:(id)sender
{
    [self.webView reload];
}

- (IBAction)gobackBtnClicked:(id)sender
{
    [self.webView goBack];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"shouldStartLoadWithRequest request %@", request);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad webView %@", webView);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad webView %@", webView);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError webView %@ error %@", webView, error);
}

@end






