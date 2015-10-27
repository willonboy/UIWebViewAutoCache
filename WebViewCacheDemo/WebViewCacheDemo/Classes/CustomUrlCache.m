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
    //替换请求的web文件为资源包里的相对应的文件
static NSDictionary *replaceRequestFileWithLocalFile = nil;

+ (void)setCacheDirectPath:(NSString *)directPath
{
    @synchronized(cacheDirect)
    {
        cacheDirect = directPath;
    }
}

+ (void)setReplaceRequestFileWithLocalFile:(NSDictionary *)replaceFiles
{
    @synchronized(replaceRequestFileWithLocalFile)
    {
        replaceRequestFileWithLocalFile = replaceFiles;
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
            
            [NSURLCache setSharedURLCache:[CustomUrlCache sharedCache]];
            
            NSString *path = [[NSBundle mainBundle] pathForResource:kLocalWebSourceDirectory ofType:nil];
            NSString *destPath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), kLocalWebSourceDirectory];
            
            NSError *err = nil;
            if ([[NSFileManager defaultManager] fileExistsAtPath:destPath])
            {
                [[NSFileManager defaultManager] removeItemAtPath:destPath error:&err];
            }
                //默认copy一份到Documents/xxx, 这样方便日后更新, 当前没有实现更新
            [[NSFileManager defaultManager] copyItemAtPath:path toPath:destPath error:nil];
            
        });
    }
}

- (BOOL)hasDataForURL:(NSString *)url
{
    NSString *cacheDirect = [self webCacheDirectPath];
    NSString *md5 = [CustomUrlCache md5String:url];
    NSString *ext = [self getExtFromUrl:url];
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
            cacheDirect = [NSString stringWithFormat:@"%@/Documents/%@/", cacheDirect, @"webCache"];
        }
        direct = cacheDirect;
    }
    
    BOOL isDirect = NO;
    NSError *err = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:direct isDirectory:&isDirect] || !isDirect)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:direct withIntermediateDirectories:NO attributes:nil error:&err];
    }
    
    if (err)
    {
        NSLog(@"创建webcache目录失败%@", err);
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


- (NSString *)getUrlWithParsUrl:(NSString *)absoluteUrl
{
    NSString *targetUrl = absoluteUrl;
    NSRange rang = [absoluteUrl rangeOfString:@"?"];
    if (rang.location != NSNotFound)
    {
        targetUrl = [targetUrl substringToIndex:rang.location];
    }
    return targetUrl;
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
    BOOL isSuccess = [data writeToFile:cachePath atomically:YES];
    
#ifdef DEBUG
    if (!isSuccess)
    {
        NSLog(@"cache failed");
    }
    NSLog(@"store url %@ to %@", url, cachePath);
    if ([self hasDataForURL:url])
    {
        NSLog(@"store success");
    }
#endif
}

    //本地存不存在打包时就发布的web资源文件
- (NSString *)loadLocalWebSourcePathWithUrl:(NSString *)absoluteUrl
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
    return nil;
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
    
    if (replaceRequestFileWithLocalFile && [replaceRequestFileWithLocalFile count])
    {
        NSString *targetUrl = [self getUrlWithParsUrl:request.URL.absoluteString];
        if ([replaceRequestFileWithLocalFile.allKeys containsObject:targetUrl])
        {
            NSString *localWebCacheFilePath = [self loadLocalWebSourcePathWithUrl:request.URL.absoluteString];
            NSData *data = [NSData dataWithContentsOfFile:localWebCacheFilePath];
            if (data && data.length)
            {
                NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[request URL] MIMEType:mime expectedContentLength:[data length] textEncodingName:nil];
                return [[NSCachedURLResponse alloc] initWithResponse:response data:data];
            }
        }
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
    
    NSString *localWebCacheFilePath = [self loadLocalWebSourcePathWithUrl:request.URL.absoluteString];
        //如果存在就不再缓存
    if (localWebCacheFilePath)
    {
        return;
    }
    
    [[CustomUrlCache sharedCache] storeData:cachedResponse.data forURL:pathString];
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forDataTask:(NSURLSessionDataTask *)dataTask
{
    NSString *pathString = [[dataTask.currentRequest URL] absoluteString];
    NSLog(@"storeCachedResponse forDataTask %@", pathString);
    
    NSString *ext = [self getExtFromUrl:pathString];
    
    if ([self hasDataForURL:pathString])
    {
        return;
    }
    
    NSLog(@"storeCachedResponse %@", pathString);
    if (![supportExt containsObject:ext])
    {
        [super storeCachedResponse:cachedResponse forDataTask:dataTask];
        return;
    }
    
    NSString *localWebCacheFilePath = [self loadLocalWebSourcePathWithUrl:dataTask.currentRequest.URL.absoluteString];
        //如果存在就不再缓存
    if (localWebCacheFilePath)
    {
        return;
    }
    [self storeData:cachedResponse.data forURL:pathString];
}

- (void)getCachedResponseForDataTask:(NSURLSessionDataTask *)dataTask completionHandler:(void (^) (NSCachedURLResponse * __nullable cachedResponse))completionHandler
{
    NSString *pathString = [[dataTask.currentRequest URL] absoluteString];
    NSLog(@"getCachedResponseForDataTask forDataTask %@", pathString);
    NSString *ext = [self getExtFromUrl:pathString];
    
    if (![supportExt containsObject:ext])
    {
        return [super getCachedResponseForDataTask:dataTask completionHandler:completionHandler];
    }
    
    NSDictionary *cacheMimeDict = @{@"jpg":@"image/jpg", @"jpeg":@"image/jpeg", @"png":@"image/png", @"gif":@"image/gif", @"css":@"text/css", @"js":@"application/javascript"};
    NSString *mime = cacheMimeDict[ext];
    
    if ([self hasDataForURL:pathString])
    {
        NSData *data = [self dataForURL:pathString];
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[dataTask.currentRequest URL] MIMEType:mime expectedContentLength:[data length] textEncodingName:nil];
        NSCachedURLResponse *resp = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
        if(completionHandler)
        {
            completionHandler(resp);
        }
        return;
    }
    
    if (replaceRequestFileWithLocalFile && [replaceRequestFileWithLocalFile count])
    {
        NSString *targetUrl = [self getUrlWithParsUrl:dataTask.currentRequest.URL.absoluteString];
        if ([replaceRequestFileWithLocalFile.allKeys containsObject:targetUrl])
        {
            NSString *localWebCacheFilePath = [self loadLocalWebSourcePathWithUrl:dataTask.currentRequest.URL.absoluteString];
            NSData *data = [NSData dataWithContentsOfFile:localWebCacheFilePath];
            if (data && data.length)
            {
                NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[dataTask.currentRequest URL] MIMEType:mime expectedContentLength:[data length] textEncodingName:nil];
                NSCachedURLResponse *resp = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
                if(completionHandler)
                {
                    completionHandler(resp);
                }
                return;
            }
        }
    }
    
    return [super getCachedResponseForDataTask:dataTask completionHandler:completionHandler];
}

@end
