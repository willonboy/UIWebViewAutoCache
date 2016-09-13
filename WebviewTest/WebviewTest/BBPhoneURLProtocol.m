//
//  BBPhoneURLProtocol.m
//  BBPhoneBase
//
//  Created by zt on 16/9/1.
//  Copyright © 2016年 bilibili. All rights reserved.
//

#import "BBPhoneURLProtocol.h"

#define BBPHONE_NoHandleByURLProtocolKey       (@"NoNeedHandleByURLProtocol")

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
    if([NSURLProtocol propertyForKey:BBPHONE_NoHandleByURLProtocolKey inRequest:request]) {
        return NO;
    }
    
    NSString *acceptStr = [request valueForHTTPHeaderField:@"Accept"];
    /// 如果url已http或https开头，则进行拦截处理，否则不处理
    /// 仅处理自家域名
    if (acceptStr.length && ([request.URL.absoluteString hasPrefix:@"http://"] /*|| [request.URL.absoluteString hasPrefix:@"https://"]*/)) {
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
    [NSURLProtocol setProperty:@YES forKey:BBPHONE_NoHandleByURLProtocolKey inRequest:request];
    
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
    [self.client URLProtocol:self didLoadData:data];
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


