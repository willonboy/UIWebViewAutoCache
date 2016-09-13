//
//  BBPhoneURLProtocol.m
//  BBPhoneBase
//
//  Created by zt on 16/9/1.
//  Copyright © 2016年 bilibili. All rights reserved.
//

#import "BBPhoneURLProtocol.h"
#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define kNoHandleByURLProtocolKey       (@"NoNeedHandleByURLProtocol")

@interface BBPhoneURLProtocol ()<NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession  *session;
@end

@implementation BBPhoneURLProtocol

/// 这个方法用来返回是否需要处理这个请求，如果需要处理，返回YES，否则返回NO。在该方法中可以对不需要处理的请求进行过滤。
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return [self canProcess:request];
}

+ (BOOL)canInitWithTask:(NSURLSessionTask *)task
{
    return [self canProcess:task.currentRequest];
}

+ (BOOL)canProcess:(NSURLRequest *)request
{
    if([NSURLProtocol propertyForKey:kNoHandleByURLProtocolKey inRequest:request]) {
        return NO;
    }
    
    NSString *acceptStr = [request valueForHTTPHeaderField:@"Accept"];
    /// 如果url已http或https开头，则进行拦截处理，否则不处理
    if (acceptStr.length && ([request.URL.absoluteString hasPrefix:@"http://"] || [request.URL.absoluteString hasPrefix:@"https://"])) {
        /// 只处理html
        if ([acceptStr rangeOfString:@"text/html,application/xhtml+xml,application/xml"].location != NSNotFound) {
            return YES;
        }
    }
    
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

/// 重写该方法，需要在该方法中发起一个请求
- (void)startLoading
{
    NSLog(@"startLoading %@", self.request.URL);
    NSMutableURLRequest *request = [self.request mutableCopy];
    /// 表示该请求已经被处理，防止无限循环
    [NSURLProtocol setProperty:@YES forKey:kNoHandleByURLProtocolKey inRequest:request];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request];
    [task resume];
}

/// 重写该方法，需要停止响应的请求
- (void)stopLoading
{
    [self.session invalidateAndCancel];
    self.session = nil;
}

#pragma NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * __nullable))completionHandler
{
    NSLog(@"willPerformHTTPRedirection %@ \n request %@", task.currentRequest.URL, request.URL);
    if([response statusCode] == 301 || [response statusCode] == 302)
    {
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        [mutableRequest setURL:[NSURL URLWithString:[response.allHeaderFields objectForKey:@"Location"]]];
        request = [mutableRequest copy];
        [self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
    completionHandler(request);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSLog(@"didReceiveResponse %@", dataTask.currentRequest.URL);
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    completionHandler(NSURLSessionResponseAllow);
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData %@", dataTask.currentRequest.URL);
    /// iOS9之前系统
    if (!(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0"))) {
        NSString *js = @"</title>\n<script type=\"text/javascript\">if(window.injected==undefined){window.injected=true;if(window.performance==undefined){window.performance={};window.performance.timing={};window.performance.timing.domLoading=(new Date()).getTime();window.performance.timing.responseEnd=%zd;window.addEventListener(\"DOMContentLoaded\",function(){window.performance.timing.domContentLoadedEventEnd=(new Date()).getTime()});window.addEventListener(\"load\",function(){window.performance.timing.loadEventEnd=(new Date()).getTime()})}else{if(window.performance.timing==undefined){window.performance.timing={};window.performance.timing.domLoading=(new Date()).getTime();window.performance.timing.responseEnd=%zd;window.addEventListener(\"DOMContentLoaded\",function(){window.performance.timing.domContentLoadedEventEnd=(new Date()).getTime()});window.addEventListener(\"load\",function(){window.performance.timing.loadEventEnd=(new Date()).getTime()})}}};</script>";
        /// iOS9之前将timing.responseEnd赋值[[NSDate date] timeIntervalSince1970]
        long responseEnd = [[NSDate date] timeIntervalSince1970] * 1000;
        js = [NSString stringWithFormat:js, responseEnd, responseEnd];
        
        NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSRange rang = [html rangeOfString:@"</title>"];
        if (rang.location != NSNotFound) {
            html = [html stringByReplacingOccurrencesOfString:@"</title>" withString:js];
            NSData *newData = [html dataUsingEncoding:NSUTF8StringEncoding];
            [self.client URLProtocol:self didLoadData:newData];
        }
    } else {
        [self.client URLProtocol:self didLoadData:data];
    }
}

//- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse
// completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
//{
//    NSLog(@"willCacheResponse %@", dataTask.currentRequest.URL);
//    [self.client URLProtocol:self cachedResponseIsValid:proposedResponse];
//    completionHandler(proposedResponse);
//}
    
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
        NSLog(@"didCompleteWithError %@\n error %@", task.currentRequest.URL, error);
    } else {
        [self.client URLProtocolDidFinishLoading:self];
        NSLog(@"didCompleteWithError %@\n", task.currentRequest.URL);
    }
}

@end


