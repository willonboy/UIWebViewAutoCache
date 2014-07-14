//
//  RootViewController.h
//  WebViewCacheDemo
//
//  Created by tao on 14-7-3.
//  Copyright (c) 2014年 willonboy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoCacheWebView.h"

@interface RootViewController : UIViewController<UIWebViewDelegate>

@property(nonatomic, strong) AutoCacheWebView   *webView;
@property(nonatomic, strong) IBOutlet UIButton  *refreshBtn;


@end
