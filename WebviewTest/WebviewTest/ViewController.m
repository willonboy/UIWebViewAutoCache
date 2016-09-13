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
@end

@implementation ViewController
{
    CFAbsoluteTime startTime;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NSURLProtocol registerClass:[BBPhoneURLProtocol class]];

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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"shouldStartLoadWithRequest %@\n", request.URL.absoluteString);
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
}


@end
