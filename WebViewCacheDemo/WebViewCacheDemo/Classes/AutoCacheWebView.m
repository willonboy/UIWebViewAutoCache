//
//  AutoCacheWebView.m
//  WebViewCacheDemo
//
//  Created by tao on 14-7-11.
//  Copyright (c) 2014年 willonboy. All rights reserved.
//

#import "AutoCacheWebView.h"
#import "CustomUrlCache.h"


@interface AutoCacheWebView ()<NSURLConnectionDataDelegate>
@property(copy) void (^completeBlock)(NSError *err);
@property(nonatomic, strong) NSString *requestUrlStr;
@property(nonatomic, strong) NSString *baseUrlStr;
@property(nonatomic, strong) NSMutableData *responseData;
@property(nonatomic) NSStringEncoding responseEncoding;

@end

@implementation AutoCacheWebView

- (id)init
{
    self = [super init];
    if (self)
    {
        [self preLoad];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self preLoad];
    }
    return self;
}

- (void)preLoad
{    
    [CustomUrlCache buildGlobalWebCache];
    self.responseEncoding = NSUTF8StringEncoding;
    self.timeoutInterval = 10;
}

- (void)loadUrl:(NSString *)urlStr baseUrl:(NSString *)baseUrl responseEncodingName:(NSStringEncoding)encodingName completeBlock:(void (^)(NSError *err))completeBlock
{
    self.completeBlock = completeBlock;
    self.baseUrlStr = baseUrl;
    self.responseEncoding = encodingName;
    self.requestUrlStr = urlStr;
    [self startLoad];
}

- (void)startLoad
{
    NSURL *url = [NSURL URLWithString:self.requestUrlStr relativeToURL:[NSURL URLWithString:self.baseUrlStr]];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:self.timeoutInterval];
    [request setHTTPMethod:@"GET"];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)reload
{
    if (self.requestUrlStr)
    {
        [self startLoad];
    }
    else
    {
        [super reload];
    }
}

#pragma mark
#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.completeBlock)
    {
        self.completeBlock(error);
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
    {
        [self.delegate webView:self didFailLoadWithError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (!self.responseData)
    {
        self.responseData = [NSMutableData data];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connection.currentRequest %@", connection.currentRequest);
    if (self.responseData)
    {
        NSString *htmlStr = [[NSString alloc] initWithData:self.responseData encoding:self.responseEncoding];
        [self loadHTMLString:htmlStr baseURL:[NSURL URLWithString:self.baseUrlStr]];
        self.responseData = nil;
    }
    
    if (self.completeBlock)
    {
        if (self.responseData)
        {
            self.completeBlock(nil);
        }
        else
        {
            self.completeBlock([NSError errorWithDomain:@"auto.webview.cache" code:10000 userInfo:@{@"message":@"no data"}]);
        }
    }
}


@end










