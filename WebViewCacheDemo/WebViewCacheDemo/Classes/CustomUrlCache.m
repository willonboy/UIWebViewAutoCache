//
//  CustomUrlCache.m
//  WebViewCacheDemo
//
//  Created by tao on 14-7-11.
//  Copyright (c) 2014年 willonboy. All rights reserved.
//

#import "CustomUrlCache.h"

@implementation CustomUrlCache

static NSString *cacheDirect = nil;

+ (void)setCacheDirectPath:(NSString *)directPath
{
    @synchronized(cacheDirect)
    {
        cacheDirect = directPath;
    }
}

+ (NSString *)md5String:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (instancetype)sharedCache
{
    static CustomUrlCache *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _shareInstance = [CustomUrlCache new];
    });
    return _shareInstance;
}

+ (void)buildGlobalWebCache
{
    if (![[NSURLCache sharedURLCache] isKindOfClass:[CustomUrlCache class]])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            [NSURLCache setSharedURLCache:[CustomUrlCache new]];
        });
    }
}

- (BOOL)hasDataForURL:(NSString *)url
{
    NSString *cacheDirect = [self webCacheDirectPath];
    NSString *md5 = [CustomUrlCache md5String:url];
    NSString *ext = [url pathExtension];
    ext = ext ? [NSString stringWithFormat:@".%@", ext] : nil;
    NSString *cachePath = [NSString stringWithFormat:@"%@/%@%@", cacheDirect, md5, ext ? ext : @""];
    
    BOOL isDirect = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDirect] && !isDirect)
    {
        return YES;
    }
    return NO;
}

- (NSString *)webCacheDirectPath
{
    NSString *direct = nil;
    @synchronized(cacheDirect)
    {
        if (!cacheDirect)
        {
            cacheDirect = NSHomeDirectory();
            cacheDirect = [NSString stringWithFormat:@"%@/%@/", cacheDirect, @"webCache"];
        }
        direct = cacheDirect;
    }
    
    BOOL isDirect = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:direct isDirectory:&isDirect] || !isDirect)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:direct withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return direct;
}

- (NSString *)getExtFromUrl:(NSString *)absoluteUrl
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

- (NSData *)dataForURL:(NSString *)url
{
    NSString *cacheDirect = [self webCacheDirectPath];
    NSString *md5 = [CustomUrlCache md5String:url];
    NSString *ext = [self getExtFromUrl:url];
    ext = ext ? [NSString stringWithFormat:@".%@", ext] : nil;
    NSString *cachePath = [NSString stringWithFormat:@"%@/%@%@", cacheDirect, md5, ext ? ext : @""];
    
    NSData *cacheData = [NSData dataWithContentsOfFile:cachePath];
    
#ifdef DEBUG
    NSLog(@"look for cachePath %@", cachePath);
    if (cacheData)
    {
        NSLog(@"exist cachePath %@", cachePath);
    }
#endif
    return cacheData;
}

- (void)storeData:(NSData *)data forURL:(NSString *)url
{
    NSString *cacheDirect = [self webCacheDirectPath];
    NSString *md5 = [CustomUrlCache md5String:url];
    NSString *ext = [self getExtFromUrl:url];
    ext = ext ? [NSString stringWithFormat:@".%@", ext] : nil;
    NSString *cachePath = [NSString stringWithFormat:@"%@/%@%@", cacheDirect, md5, ext ? ext : @""];
    [data writeToFile:cachePath atomically:YES];
    
#ifdef DEBUG
    NSLog(@"store url %@ to %@", url, cachePath);
    if ([self hasDataForURL:url])
    {
        NSLog(@"store success");
    }
#endif
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
    NSString *pathString = [[request URL] absoluteString];
    NSString *ext = [self getExtFromUrl:pathString];
    
    NSArray *supportExt = @[@"jpg", @"jpeg", @"png", @"gif", @"css", @"js"];
    if (![supportExt containsObject:ext])
    {
        return [super cachedResponseForRequest:request];
    }
    
    NSDictionary *cacheMimeDict = @{@"jpg":@"image/jpg", @"jpeg":@"image/jpeg", @"png":@"image/png", @"gif":@"image/gif", @"css":@"text/css", @"js":@"application/javascript"};
    NSString *mime = cacheMimeDict[ext];
    
    if ([[CustomUrlCache sharedCache] hasDataForURL:pathString])
    {
        NSData *data = [[CustomUrlCache sharedCache] dataForURL:pathString];
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[request URL] MIMEType:mime expectedContentLength:[data length] textEncodingName:nil];
        return [[NSCachedURLResponse alloc] initWithResponse:response data:data];
    }
    
    return [super cachedResponseForRequest:request];
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request
{
    NSString *pathString = [[request URL] absoluteString];
    NSString *ext = [self getExtFromUrl:pathString];
    
    NSArray *supportExt = @[@"jpg", @"jpeg", @"png", @"gif", @"css", @"js"];
    if (![supportExt containsObject:ext])
    {
        [super storeCachedResponse:cachedResponse forRequest:request];
        return;
    }
    
    [[CustomUrlCache sharedCache] storeData:cachedResponse.data forURL:pathString];
}

@end
