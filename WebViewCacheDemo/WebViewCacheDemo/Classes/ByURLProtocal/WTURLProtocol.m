//
//  WTURLProtocol.m
//  WebViewCacheDemo
//
//  Created by trojan on 16/3/8.
//  Copyright © 2016年 willonboy. All rights reserved.
//

#import "WTURLProtocol.h"
#import <CommonCrypto/CommonDigest.h>

#define kNoHandleByURLProtocolKey       (@"NoHandleByURLProtocol")

@interface WTURLProtocol ()

@end



@implementation WTURLProtocol

    //替换请求的web文件为资源包里的相对应的文件
static NSDictionary *replaceRequestFileWithLocalFile = nil;

NSArray *supportExts        = nil;
NSDictionary *cacheMimeDict = nil;

+(void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        supportExts     = @[@"jpg", @"jpeg", @"png", @"gif", @"css", @"js"];
        cacheMimeDict   = @{@"jpg":@"image/jpg", @"jpeg":@"image/jpeg", @"png":@"image/png", @"gif":@"image/gif", @"css":@"text/css", @"js":@"application/javascript"};

    });
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSLog(@"request %@", request);
        /// 对于SDWebImage或其他下截图片或css, js等NSURLRequest可以通过添加kNoHandleByURLProtocolKey在header中标识不被处理
    if([request.allHTTPHeaderFields.allKeys containsObject:kNoHandleByURLProtocolKey])
    {
        return NO;
    }
    
    NSString *pathString    = [[request URL] absoluteString];
    NSString *ext           = [self getExtFromUrl:pathString];
    if ([supportExts containsObject:ext])
    {
        NSString *localWebCacheFilePath = [[self class] loadLocalWebSourcePathWithUrl:request.URL.absoluteString];
        if (localWebCacheFilePath && localWebCacheFilePath.length)
        {
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


#pragma mark 通信协议内容实现


- (void)startLoading
{
    NSString *ext           = [[self class] getExtFromUrl:self.request.URL.absoluteString];
    NSString *mime          = cacheMimeDict[ext];
    NSString *localWebCacheFilePath = [[self class] loadLocalWebSourcePathWithUrl:self.request.URL.absoluteString];
    NSData *data            = [NSData dataWithContentsOfFile:localWebCacheFilePath];
    if (data && data.length)
    {
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:mime expectedContentLength:data.length textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
    }
}


- (void)stopLoading
{

}


#pragma mark - Custom Methods

+ (void)setReplaceRequestFileWithLocalFile:(NSDictionary *)replaceFiles
{
    @synchronized(replaceRequestFileWithLocalFile)
    {
        replaceRequestFileWithLocalFile = replaceFiles;
    }
}

+ (void)buildGlobalWebCache
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *destPath  = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), kLocalWebSourceDirectory];
        NSError *err        = nil;
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:destPath])
        {
            NSString *path = [[NSBundle mainBundle] pathForResource:kLocalWebSourceDirectory ofType:nil];
                //默认copy一份工程中web_sources目录到Documents/xxx, 这样方便日后更新, 当前没有实现更新
            BOOL isSuccess = [[NSFileManager defaultManager] copyItemAtPath:path toPath:destPath error:&err];
            if (err || !isSuccess)
            {
                NSLog(@"err %@", err);
                return ;
            }
        }
        
        [NSURLProtocol registerClass:[WTURLProtocol class]];
    });
}


+ (NSString *)getExtFromUrl:(NSString *)absoluteUrl
{
    NSString *pathString = absoluteUrl;
    NSString *ext = [pathString lastPathComponent];
    ext = [ext lowercaseString];
    NSRange rang = [ext rangeOfString:@"?"];
    if (rang.location != NSNotFound)
    {
        ext = [ext substringToIndex:rang.location];
    }
    rang = [ext rangeOfString:@"!"];
    if (rang.location != NSNotFound)
    {
        ext = [ext substringToIndex:rang.location];
    }
    ext = [ext pathExtension];
    return ext;
}

    //本地存不存在打包时就发布的web资源文件
+ (NSString *)loadLocalWebSourcePathWithUrl:(NSString *)absoluteUrl
{
    @synchronized(replaceRequestFileWithLocalFile)
    {
        if (replaceRequestFileWithLocalFile && [replaceRequestFileWithLocalFile count])
        {
            if ([replaceRequestFileWithLocalFile.allKeys containsObject:absoluteUrl])
            {
                NSString *localWebSourceFileName = replaceRequestFileWithLocalFile[absoluteUrl];
                NSString *path = [NSString stringWithFormat:@"%@/Documents/%@/%@", NSHomeDirectory(), kLocalWebSourceDirectory, localWebSourceFileName];
                return path;
            }
        }
    }
    return nil;
}




@end





















