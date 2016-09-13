//
//  CustomWebView.m
//  WebviewTest
//
//  Created by zt on 16/8/29.
//  Copyright © 2016年 zt. All rights reserved.
//

#import "CustomWebView.h"
#import <objc/runtime.h>
#import <objc/message.h>


@implementation CustomWebView

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self swizzMethod:NSSelectorFromString(@"webViewMainFrameDidCommitLoad:") newMethod:@selector(web_ViewMainFrameDidCommitLoad:)];
        [self swizzMethod:NSSelectorFromString(@"webViewMainFrameDidFailLoad:withError:") newMethod:@selector(web_ViewMainFrameDidFailLoad:withError:)];
        [self swizzMethod:NSSelectorFromString(@"webViewMainFrameDidFinishLoad:") newMethod:@selector(web_ViewMainFrameDidFinishLoad:)];
        [self swizzMethod:NSSelectorFromString(@"webViewMainFrameDidFirstVisuallyNonEmptyLayoutInFrame:") newMethod:@selector(web_ViewMainFrameDidFirstVisuallyNonEmptyLayoutInFrame:)];
        [self swizzMethod:NSSelectorFromString(@"webView:decidePolicyForGeolocationRequestFromOrigin:frame:listener:") newMethod:@selector(web_View:decidePolicyForGeolocationRequestFromOrigin:frame:listener:)];
        [self swizzMethod:NSSelectorFromString(@"webView:decidePolicyForMIMEType:request:frame:decisionListener:") newMethod:@selector(web_View:decidePolicyForMIMEType:request:frame:decisionListener:)];
        [self swizzMethod:NSSelectorFromString(@"webView:decidePolicyForNavigationAction:request:frame:decisionListener:") newMethod:@selector(web_View:decidePolicyForNavigationAction:request:frame:decisionListener:)];
        [self swizzMethod:NSSelectorFromString(@"webView:decidePolicyForNewWindowAction:request:newFrameName:decisionListener:") newMethod:@selector(web_View:decidePolicyForNewWindowAction:request:newFrameName:decisionListener:)];
        [self swizzMethod:NSSelectorFromString(@"webView:didChangeLocationWithinPageForFrame:") newMethod:@selector(web_View:didChangeLocationWithinPageForFrame:)];
        [self swizzMethod:NSSelectorFromString(@"webView:didClearWindowObject:forFrame:") newMethod:@selector(web_View:didClearWindowObject:forFrame:)];
        [self swizzMethod:NSSelectorFromString(@"webView:didCommitLoadForFrame:") newMethod:@selector(web_View:didCommitLoadForFrame:)];
        [self swizzMethod:NSSelectorFromString(@"webView:didFailLoadWithError:forFrame:") newMethod:@selector(web_View:didFailLoadWithError:forFrame:)];
        [self swizzMethod:NSSelectorFromString(@"webView:didFailProvisionalLoadWithError:forFrame:") newMethod:@selector(web_View:didFailProvisionalLoadWithError:forFrame:)];
        [self swizzMethod:NSSelectorFromString(@"webView:didFinishLoadForFrame:") newMethod:@selector(web_View:didFinishLoadForFrame:)];
        [self swizzMethod:NSSelectorFromString(@"webView:didFirstLayoutInFrame:") newMethod:@selector(web_View:didFirstLayoutInFrame:)];
        [self swizzMethod:NSSelectorFromString(@"webView:didReceiveServerRedirectForProvisionalLoadForFrame:") newMethod:@selector(web_View:didReceiveServerRedirectForProvisionalLoadForFrame:)];
        [self swizzMethod:NSSelectorFromString(@"webView:didReceiveTitle:forFrame:") newMethod:@selector(web_View:didReceiveTitle:forFrame:)];
        [self swizzMethod:NSSelectorFromString(@"webView:didStartProvisionalLoadForFrame:") newMethod:@selector(web_View:didStartProvisionalLoadForFrame:)];
        [self swizzMethod:NSSelectorFromString(@"webThreadWebView:resource:willSendRequest:redirectResponse:fromDataSource:") newMethod:@selector(web_ThreadWebView:resource:willSendRequest:redirectResponse:fromDataSource:)];
        [self swizzMethod:NSSelectorFromString(@"webView:connectionPropertiesForResource:dataSource:") newMethod:@selector(web_View:connectionPropertiesForResource:dataSource:)];
        [self swizzMethod:NSSelectorFromString(@"webView:identifierForInitialRequest:fromDataSource:") newMethod:@selector(web_View:identifierForInitialRequest:fromDataSource:)];
//        [self swizzMethod:NSSelectorFromString(@"webViewMainFrameDidCommitLoad:") newMethod:@selector(web_ViewMainFrameDidCommitLoad:)];
//        [self swizzMethod:NSSelectorFromString(@"webViewMainFrameDidCommitLoad:") newMethod:@selector(web_ViewMainFrameDidCommitLoad:)];
//        [self swizzMethod:NSSelectorFromString(@"webViewMainFrameDidCommitLoad:") newMethod:@selector(web_ViewMainFrameDidCommitLoad:)];
//        [self swizzMethod:NSSelectorFromString(@"webViewMainFrameDidCommitLoad:") newMethod:@selector(web_ViewMainFrameDidCommitLoad:)];
//        [self swizzMethod:NSSelectorFromString(@"webViewMainFrameDidCommitLoad:") newMethod:@selector(web_ViewMainFrameDidCommitLoad:)];
    });
}

+ (void)swizzMethod:(SEL)originalSel newMethod:(SEL)newSel
{
    Method oriMethod = class_getInstanceMethod([self class], originalSel);
    Method newMethod = class_getInstanceMethod([self class], newSel);
    method_exchangeImplementations(oriMethod, newMethod);
}

- (id)web_View:(id)arg1 identifierForInitialRequest:(id)arg2 fromDataSource:(id)arg3
{
//    NSLog(@"---identifierForInitialRequest:fromDataSource: %@ %@", arg2, arg3);
    id identifier = [self web_View:arg1 identifierForInitialRequest:arg2 fromDataSource:arg3];
    return identifier;
}

- (id)web_ThreadWebView:(id)arg1 resource:(id)arg2 willSendRequest:(id)arg3 redirectResponse:(id)arg4 fromDataSource:(id)arg5
{
    NSLog(@"---willSendRequest:redirectResponse %@", arg3);
    return [self web_ThreadWebView:arg1 resource:arg2 willSendRequest:arg3 redirectResponse:arg4 fromDataSource:arg5];
}

- (id)web_View:(id)arg1 connectionPropertiesForResource:(id)arg2 dataSource:(id)arg3
{
//    NSLog(@"---web_View:connectionPropertiesForResource:dataSource: %@ %@", arg2, arg3);
    NSDictionary *dic = [self web_View:arg1 connectionPropertiesForResource:arg2 dataSource:arg3];
    return dic;
}

- (void)web_ViewMainFrameDidCommitLoad:(id)arg1
{
    NSLog(@"---webViewMainFrameDidCommitLoad");
    [self web_ViewMainFrameDidCommitLoad:arg1];
}

- (void)web_ViewMainFrameDidFailLoad:(id)arg1 withError:(id)arg2
{
    NSLog(@"---webViewMainFrameDidFailLoad");
    [self web_ViewMainFrameDidFailLoad:arg1 withError:arg2];
}

- (void)web_ViewMainFrameDidFinishLoad:(id)arg1
{
    NSLog(@"---webViewMainFrameDidFinishLoad");
    [self web_ViewMainFrameDidFinishLoad:arg1];
}

- (void)web_ViewMainFrameDidFirstVisuallyNonEmptyLayoutInFrame:(id)arg1
{
    NSLog(@"---webViewMainFrameDidFirstVisuallyNonEmptyLayoutInFrame");
    [self web_ViewMainFrameDidFirstVisuallyNonEmptyLayoutInFrame:arg1];
}

- (void)web_View:(id)arg1 decidePolicyForGeolocationRequestFromOrigin:(id)arg2 frame:(id)arg3 listener:(id)arg4
{
    NSLog(@"---decidePolicyForGeolocationRequestFromOrigin");
    [self web_View:arg1 decidePolicyForGeolocationRequestFromOrigin:arg2 frame:arg3 listener:arg4];
}

- (void)web_View:(id)arg1 decidePolicyForMIMEType:(id)arg2 request:(id)arg3 frame:(id)arg4 decisionListener:(id)arg5
{
    NSLog(@"---decidePolicyForMIMEType [arg4 parentFrame] %@", [[arg4 performSelector:@selector(parentFrame)] performSelector:@selector(name)]);
    [self web_View:arg1 decidePolicyForMIMEType:arg2 request:arg3 frame:arg4 decisionListener:arg5];
}

- (void)web_View:(id)arg1 decidePolicyForNavigationAction:(id)arg2 request:(id)arg3 frame:(id)arg4 decisionListener:(id)arg5
{
    NSLog(@"---decidePolicyForNavigationAction [arg4 parentFrame] %@", [[arg4 performSelector:@selector(parentFrame)] performSelector:@selector(name)]);
    [self web_View:arg1 decidePolicyForNavigationAction:arg2 request:arg3 frame:arg4 decisionListener:arg5];
}

- (void)web_View:(id)arg1 decidePolicyForNewWindowAction:(id)arg2 request:(id)arg3 newFrameName:(id)arg4 decisionListener:(id)arg5
{
    NSLog(@"---decidePolicyForNewWindowAction");
    [self web_View:arg1 decidePolicyForNewWindowAction:arg2 request:arg3 newFrameName:arg4 decisionListener:arg5];
}

- (void)web_View:(id)arg1 didChangeLocationWithinPageForFrame:(id)arg2
{
    NSLog(@"---didChangeLocationWithinPageForFrame");
    [self web_View:arg1 didChangeLocationWithinPageForFrame:arg2];
}

- (void)web_View:(id)arg1 didClearWindowObject:(id)arg2 forFrame:(id)arg3
{
    NSLog(@"---didClearWindowObject");
    [self web_View:arg1 didClearWindowObject:arg2 forFrame:arg3];
}

- (void)web_View:(id)arg1 didCommitLoadForFrame:(id)arg2
{
    NSLog(@"---didCommitLoadForFrame");
    [self web_View:arg1 didCommitLoadForFrame:arg2];
}

- (void)web_View:(id)arg1 didFailLoadWithError:(id)arg2 forFrame:(id)arg3
{
    NSLog(@"---didFailLoadWithError");
    [self web_View:arg1 didFailLoadWithError:arg2 forFrame:arg3];
}

- (void)web_View:(id)arg1 didFailProvisionalLoadWithError:(id)arg2 forFrame:(id)arg3
{
    NSLog(@"---didFailProvisionalLoadWithError");
    [self web_View:arg1 didFailProvisionalLoadWithError:arg2 forFrame:arg3];
}

- (void)web_View:(id)arg1 didFinishLoadForFrame:(id)arg2
{
    NSLog(@"---didFinishLoadForFrame");
    [self web_View:arg1 didFinishLoadForFrame:arg2];
}

- (void)web_View:(id)arg1 didFirstLayoutInFrame:(id)arg2
{
    NSLog(@"---didFirstLayoutInFrame");
    [self web_View:arg1 didFirstLayoutInFrame:arg2];
}

- (void)web_View:(id)arg1 didReceiveServerRedirectForProvisionalLoadForFrame:(id)arg2
{
    NSLog(@"---didReceiveServerRedirectForProvisionalLoadForFrame");
    [self web_View:arg1 didReceiveServerRedirectForProvisionalLoadForFrame:arg2];
}

- (void)web_View:(id)arg1 didReceiveTitle:(id)arg2 forFrame:(id)arg3
{
    NSLog(@"---didReceiveTitle");
    [self web_View:arg1 didReceiveTitle:arg2 forFrame:arg3];
}

- (void)web_View:(id)arg1 didStartProvisionalLoadForFrame:(id)arg2
{
    NSLog(@"---didStartProvisionalLoadForFrame");
    [self web_View:arg1 didStartProvisionalLoadForFrame:arg2];
}

@end
