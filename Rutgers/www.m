//
//  www.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "www.h"
#import <PBWebViewController.h>
#import "RUChannelManager.h"

@interface www ()
@property NSCache *storedChannels;

@end

@implementation www
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.storedChannels = [[NSCache alloc] init];
        self.storedChannels.countLimit = 6;
    }
    return self;
}
+(instancetype)sharedInstance{
    static www * shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[www alloc] init];
    });
    return shared;
}
-(UIViewController *)webComponentForChannel:(NSDictionary *)channel{
    NSURL *url = [self urlForChannel:channel];
    if ([self.storedChannels objectForKey:url]) return [self.storedChannels objectForKey:url];
    else {
        PBWebViewController *webBrowser = [[PBWebViewController alloc] init];
        webBrowser.URL = url;
        webBrowser.title = [[RUChannelManager sharedInstance] titleForChannel:channel];
        [self.storedChannels setObject:webBrowser forKey:url];
        return webBrowser;
    }
}
-(NSURL *)urlForChannel:(NSDictionary *)shortcut{
    return [NSURL URLWithString:shortcut[@"url"]];
}

+(UIViewController *)componentForChannel:(NSDictionary *)channel{
    return [[self sharedInstance] webComponentForChannel:channel];
}
@end
