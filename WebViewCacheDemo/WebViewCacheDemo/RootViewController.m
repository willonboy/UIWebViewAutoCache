//
//  RootViewController.m
//  WebViewCacheDemo
//
//  Created by tao on 14-7-3.
//  Copyright (c) 2014年 willonboy. All rights reserved.
//

#import "RootViewController.h"
#import "CustomUrlCache.h"

@interface RootViewController ()

@end

@implementation RootViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
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






