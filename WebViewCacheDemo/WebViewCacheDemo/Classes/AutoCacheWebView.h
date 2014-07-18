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
    //请求超时时间默认30秒
@property(nonatomic) float timeoutInterval;

- (void)loadUrl:(NSString *)urlStr baseUrl:(NSString *)baseUrl
responseEncodingName:(NSStringEncoding)encodingName completeBlock:(void (^)(NSError *err))completeBlock;

@end
