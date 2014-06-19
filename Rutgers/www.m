//
//  www.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "www.h"
#import <TOWebViewController.h>
#import "RUChannelManager.h"

@interface www ()

@end

@implementation www

+(NSCache *)storedChannels{
    static NSCache * storedChannels = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storedChannels = [[NSCache alloc] init];
        storedChannels.countLimit = 6;
    });
    return storedChannels;
}

+(NSURL *)urlForChannel:(NSDictionary *)shortcut{
    return [NSURL URLWithString:shortcut[@"url"]];
}

+(UIViewController *)componentForChannel:(NSDictionary *)channel{
    NSURL *url = [self urlForChannel:channel];
    if ([self.storedChannels objectForKey:url]) return [self.storedChannels objectForKey:url];
    else {
        TOWebViewController *webBrowser = [[TOWebViewController alloc] initWithURL:url];
        [self.storedChannels setObject:webBrowser forKey:url];
        return webBrowser;
    }
}
@end
