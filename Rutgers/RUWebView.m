//
//  RUWebView.m
//  Rutgers
//
//  Created by Open Systems Solutions on 7/22/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import "RUWebView.h"
#import <WebKit/WebKit.h>
#import <PureLayout.h>

@interface RUWebViewWrapper : UIView <RUWebView>

@end

@interface UIWebView (RUWebViewExtensions) <RUWebView>

@end

@interface WKWebView (RUWebViewExtensions) <RUWebView>

@end

@interface RUWebView () <UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate>
@property (nonatomic) UIView <RUWebView> *webView;
@property (nonatomic) NSDictionary *channel;
@end

@implementation RUWebView
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.webView = [[[self webViewClass] alloc] initWithFrame:frame];
        [self addSubview:self.webView];
        [self.webView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    }
    return self;
}


-(Class)webViewClass{
    return [WKWebView class] ? [WKWebView class] : [UIWebView class];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature* signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        signature = [_webView methodSignatureForSelector:selector];
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([_webView respondsToSelector:[anInvocation selector]])
        [anInvocation invokeWithTarget:_webView];
    else
        [super forwardInvocation:anInvocation];
}


@end

