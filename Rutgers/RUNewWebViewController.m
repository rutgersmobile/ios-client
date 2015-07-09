//
//  RUNewWebViewController.m
//  Rutgers
//
//  Created by Open Systems Solutions on 7/8/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import "RUNewWebViewController.h"
#import <WebKit/WebKit.h>
#import <PureLayout.h>
#import "WebViewProvider.h"

@interface RUNewWebViewController () <UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate>
@property (nonatomic) UIView <FLWebViewProvider> *webView;
@end

@implementation RUNewWebViewController

//Global cache holding RUWebViewController objects
+(NSCache *)storedChannels{
    static NSCache * storedChannels = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storedChannels = [[NSCache alloc] init];
        storedChannels.countLimit = 5;
    });
    return storedChannels;
}

/**
 *  After the webview finshes loading
 *
 *  @param webView The webview
 *//*
-(void)webViewDidFinishLoad:(UIWebView *)webView{    
    if (self.channel[@"fontSize"]) {
        NSString *setTextSizeRule = [NSString stringWithFormat:@"document.body.style.fontSize = %@;", self.channel[@"fontSize"]];
        [webView stringByEvaluatingJavaScriptFromString:setTextSizeRule];
    }
}*/
@end

