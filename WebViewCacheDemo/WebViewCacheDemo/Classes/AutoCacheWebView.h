//
//  AutoCacheWebView.h
//  WebViewCacheDemo
//
//  Created by tao on 14-7-11.
//  Copyright (c) 2014年 willonboy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CFNetwork/CFNetwork.h>

@interface AutoCacheWebView : UIWebView

- (void)loadUrl:(NSString *)urlStr baseUrl:(NSString *)baseUrl
responseEncodingName:(NSStringEncoding)encodingName completeBlock:(void (^)(NSError *err))completeBlock;

@end
