//
//  CustomUrlCache.h
//  WebViewCacheDemo
//
//  Created by tao on 14-7-11.
//  Copyright (c) 2014年 willonboy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

#define kLocalWebSourceDirectory            (@"web_sources")


@interface CustomUrlCache : NSURLCache

+ (void)setCacheDirectPath:(NSString *)directPath;

+ (void)setReplaceRequestFileWithLocalFile:(NSDictionary *)replaceFiles;

+ (instancetype)sharedCache;

+ (void)buildGlobalWebCache;


@end
