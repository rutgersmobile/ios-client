//
//  www.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "www.h"
#import "RUChannelManager.h"
#import <TOWebViewController.h>



@implementation www

-(void)setTitle:(NSString *)title{
    if (self.title) return;
    [super setTitle:title];
}

+(NSCache *)storedChannels{
    static NSCache * storedChannels = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storedChannels = [[NSCache alloc] init];
        storedChannels.countLimit = 6;
    });
    return storedChannels;
}

+(instancetype)componentForChannel:(NSDictionary *)channel{
    NSString *urlString = channel[@"url"];
    if ([self.storedChannels objectForKey:urlString]) return [self.storedChannels objectForKey:urlString];
    else {
        www *webViewController = [[www alloc] initWithURLString:urlString];
        webViewController.hideWebViewBoundaries = YES;
        webViewController.showUrlWhileLoading = NO;
        [self.storedChannels setObject:webViewController forKey:urlString];
        return webViewController;
    }
}
@end



