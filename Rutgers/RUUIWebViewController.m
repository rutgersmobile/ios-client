//
//  RUUIWebViewController.m
//  Rutgers
//
//  Created by Open Systems Solutions on 7/31/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import "RUUIWebViewController.h"

@interface RUUIWebViewController ()
@property (nonatomic) NSDictionary *channelConfiguration;
@end

@implementation RUUIWebViewController
+(id)channelWithConfiguration:(NSDictionary *)channel{
    return [[self alloc] initWithChannel:channel];
}
-(instancetype)initWithChannel:(NSDictionary *)channel{
    NSString *urlString = [channel channelURL];
    self = [super initWithURLString:urlString];
    if (self) {
        self.channelConfiguration = channel;
    }
    return self;
}

/**
 *  After the webview finshes loading
 *
 *  @param webView The webview
 */
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [super webViewDidFinishLoad:webView];
    
    if (self.channelConfiguration[@"fontSize"]) {
        NSString *setTextSizeRule = [NSString stringWithFormat:@"document.body.style.fontSize = %@;", self.channelConfiguration[@"fontSize"]];
        [webView stringByEvaluatingJavaScriptFromString:setTextSizeRule];
    }
}
@end
