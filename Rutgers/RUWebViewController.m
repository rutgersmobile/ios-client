//
//  www.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUWebViewController.h"
#import "RUChannelManager.h"
#import <TOWebViewController.h>



@implementation RUWebViewController

+(NSCache *)storedChannels{
    static NSCache * storedChannels = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storedChannels = [[NSCache alloc] init];
        storedChannels.countLimit = 10;
    });
    return storedChannels;
}

+(TOWebViewController *)channelWithConfiguration:(NSDictionary *)channel{
    NSString *urlString = channel[@"url"];
    TOWebViewController *webViewController = [self.storedChannels objectForKey:urlString];
    if (!webViewController) {
        webViewController = [[TOWebViewController alloc] initWithURLString:urlString];
        webViewController.showPageTitles = NO;
        [self.storedChannels setObject:webViewController forKey:urlString];

        webViewController.hideWebViewBoundaries = YES;
        webViewController.showUrlWhileLoading = NO;
    }
    return webViewController;
}
@end



