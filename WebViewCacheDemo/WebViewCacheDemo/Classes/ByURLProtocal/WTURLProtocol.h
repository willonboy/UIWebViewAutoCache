//
//  WTURLProtocol.h
//  WebViewCacheDemo
//
//  Created by trojan on 16/3/8.
//  Copyright © 2016年 willonboy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kLocalWebSourceDirectory            (@"web_sources")

@interface WTURLProtocol : NSURLProtocol

+ (void)setReplaceRequestFileWithLocalFile:(NSDictionary *)replaceFiles;

+ (void)buildGlobalWebCache;

@end
