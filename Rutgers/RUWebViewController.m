//
//  www.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUWebViewController.h"
#import <TOWebViewController.h>

@interface RUWebViewController ()
@property NSDictionary *channel;
@end

@implementation RUWebViewController

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

+(RUWebViewController *)channelWithConfiguration:(NSDictionary *)channel{
    if ([channel[@"weblink"] boolValue]) {
        RUWebViewController *webViewController = [self.storedChannels objectForKey:channel];
        if (!webViewController) {
            webViewController = [[RUWebViewController alloc] initWithChannel:channel];
            [self.storedChannels setObject:webViewController forKey:channel];
        }
        return webViewController;
    } else {
        return [[RUWebViewController alloc] initWithChannel:channel];
    }
}

-(instancetype)initWithChannel:(NSDictionary *)channel{
    NSString *urlString = [channel channelURL];
    self = [super initWithURLString:urlString];
    if (self) {
        self.channel = channel;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.showPageTitles = NO;
    self.hideWebViewBoundaries = YES;
    self.showUrlWhileLoading = NO;
}

/**
 *  After the webview finshes loading
 *
 *  @param webView The webview
 */
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [super webViewDidFinishLoad:webView];
    
    if (self.channel[@"fontSize"]) {
        NSString *setTextSizeRule = [NSString stringWithFormat:@"document.body.style.fontSize = %@;", self.channel[@"fontSize"]];
        [webView stringByEvaluatingJavaScriptFromString:setTextSizeRule];
    }
}

@end



