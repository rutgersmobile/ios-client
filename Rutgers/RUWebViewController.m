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
#import "RUChannelManager.h"
#import "NSDictionary+Channel.h"
#import "UIColor+RutgersColors.h"


#import "RURootController.h" // to get access to the menu bar button item

@interface RUWebViewController ()
@property NSDictionary *channelConfiguration;
@end

@implementation RUWebViewController

// tag sepcific to this ViewCon..
+(NSString *)channelHandle{
    return @"www";
}

// Registers itself with the RUChannelMan which is like a central system which manages the seperate classes
+(void)load
{
    [[RUChannelManager sharedInstance] registerClass:[self class]];
}

//Global cache holding RUWebViewController objects
// cache can be cleared on demand by the system. This does not matter for the WebViewController objects
+(NSCache *)storedChannels{
    static NSCache * storedChannels = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storedChannels = [[NSCache alloc] init];
        storedChannels.countLimit = 5;
    });
    return storedChannels;
}


// Config specifics of View Controller
+(id)channelWithConfiguration:(NSDictionary *)channel{
    
    // if the content channel has a web view , then search for it in the cache , if present in the cache return that web VC , else recreate a new view controller
    // Recreation is also done if the content channel does not have a web view
    if ([[RUChannelManager sharedInstance].contentChannels containsObject:channel]) {
        RUWebViewController *webViewController = [self.storedChannels objectForKey:channel];
        if (!webViewController) {
            webViewController = [self _channelWithConfiguration:channel];
            [self.storedChannels setObject:webViewController forKey:channel];
        }
        return webViewController;
    } else {
        return [self _channelWithConfiguration:channel];   // Recreate new Web View Controller
    }
}


/*
    Create a web View controller ...
 */
+(id)_channelWithConfiguration:(NSDictionary *)channel{
    /*
    if ([SFSafariViewController class]) {
        SFSafariViewController *sfWebViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[channel channelURL]]];
        sfWebViewController.view.tintColor = [UIColor rutgersRedColor];
        return sfWebViewController;
    } else */
    if ([WKWebView class])
    {
        RUWKWebViewController *wkWebViewController = [RUWKWebViewController channelWithConfiguration:channel];
        wkWebViewController.showPageTitles = NO;
        wkWebViewController.hideWebViewBoundaries = YES;
        wkWebViewController.showUrlWhileLoading = NO;
        return wkWebViewController;
    }
    else // ios 7 version
    {
        RUUIWebViewController *uiWebViewController = [RUUIWebViewController channelWithConfiguration:channel];
        uiWebViewController.showPageTitles = NO;
        uiWebViewController.showUrlWhileLoading = NO;
          uiWebViewController.hideWebViewBoundaries = YES;
     //   UIBarButtonItem * menu = [RURootController sharedInstance].menuBarButtonItem;
    //    uiWebViewController.applicationLeftBarButtonItems = @[menu];
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



