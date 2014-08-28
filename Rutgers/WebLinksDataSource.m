//
//  WebLinksDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "WebLinksDataSource.h"

@implementation WebLinksDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"Web Links";
    }
    return self;
}

-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUChannelManager sharedInstance] webLinksWithCompletion:^(NSArray *webLinks) {
            [loading updateWithContent:^(typeof(self) me) {
                me.items = webLinks;
            }];
        }];
    }];
}
@end
