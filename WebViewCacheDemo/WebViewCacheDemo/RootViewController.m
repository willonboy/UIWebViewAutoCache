//
//  RootViewController.m
//  WebViewCacheDemo
//
//  Created by tao on 14-7-3.
//  Copyright (c) 2014年 willonboy. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView = [[AutoCacheWebView alloc] initWithFrame:CGRectMake(0, 64, 320, 504)];
    self.webView.delegate = self;
    
    self.webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.webView.scalesPageToFit = YES;
    self.webView.dataDetectorTypes = UIDataDetectorTypeLink;
    self.webView.userInteractionEnabled = YES;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scrollView.minimumZoomScale = 0.1;
    [self.view addSubview:self.webView];
    
    NSString *url = @"http://www.ifanr.com";
    
        // [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]]];
    [self.webView loadUrl:url baseUrl:@"/432516" responseEncodingName:NSUTF8StringEncoding completeBlock:^(NSError *err) {
        
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






