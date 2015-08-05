//
//  www.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUWebViewController.h"
#import <TOWebViewController.h>
#import <WebKit/WebKit.h>
#import <SafariServices/SafariServices.h>
#import "RUUIWebViewController.h"
#import "RUWKWebViewController.h"

@interface RUWebViewController ()
@property NSDictionary *channelConfiguration;
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

+(id)channelWithConfiguration:(NSDictionary *)channel{
    if ([[RUChannelManager sharedInstance].allChannels containsObject:channel]) {
        RUWebViewController *webViewController = [self.storedChannels objectForKey:channel];
        if (!webViewController) {
            webViewController = [self _channelWithConfiguration:channel];
            [self.storedChannels setObject:webViewController forKey:channel];
        }
        return webViewController;
    } else {
        return [self _channelWithConfiguration:channel];
    }
}

+(id)_channelWithConfiguration:(NSDictionary *)channel{

    if ([WKWebView class]) {
        RUWKWebViewController *wkWebViewController = [RUWKWebViewController channelWithConfiguration:channel];
        wkWebViewController.showPageTitles = NO;
        wkWebViewController.hideWebViewBoundaries = YES;
        wkWebViewController.showUrlWhileLoading = NO;
        return wkWebViewController;
    } else {
        RUUIWebViewController *uiWebViewController = [RUUIWebViewController channelWithConfiguration:channel];
        uiWebViewController.showPageTitles = NO;
        uiWebViewController.hideWebViewBoundaries = YES;
        uiWebViewController.showUrlWhileLoading = NO;
        return uiWebViewController;
    }
    return nil;
}
/*
+(SFSafariViewController *)safariViewControllerWithChannel:(NSDictionary *)channel{
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[channel channelURL]] entersReaderIfAvailable:NO];
    safariVC.view.tintColor = [UIColor rutgersRedColor];
    return safariVC;
}
*/


@end



