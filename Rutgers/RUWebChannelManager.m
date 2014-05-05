//
//  RUWebChannelManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/2/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUWebChannelManager.h"
@interface RUWebChannelManager ()
@property NSMutableDictionary *storedChannels;
@property NSURL *mostRecentUrl;
@end
@implementation RUWebChannelManager
+(RUWebChannelManager *)sharedInstance{
    static RUWebChannelManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RUWebChannelManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.storedChannels = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            RUWebComponent *mostRecentComponent = self.storedChannels[self.mostRecentUrl];
            NSInteger numberOfCachedViewControllers = self.storedChannels.count;
            self.storedChannels = [NSMutableDictionary dictionary];
            
            //if our cache is bigger than just one view controller, lets only clear all but the newest
            if (numberOfCachedViewControllers > 1) {
                self.storedChannels[self.mostRecentUrl] = mostRecentComponent;
            }
            
        }];
    }
    return self;
}

-(RUWebComponent *)webComponentWithURL:(NSURL *)url title:(NSString *)title delegate:(id<RUComponentDelegate>)delegate{
    if (self.storedChannels[url]) return self.storedChannels[url];
    else {
        RUWebComponent *webComponent = [[RUWebComponent alloc] initWithURL:url title:title delegate:delegate];
        self.storedChannels[url] = webComponent;
        return webComponent;
    }
}
@end
