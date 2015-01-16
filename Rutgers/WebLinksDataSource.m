//
//  WebLinksDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "WebLinksDataSource.h"

@implementation WebLinksDataSource
-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUChannelManager sharedInstance] webLinksWithCompletion:^(NSArray *webLinks, NSError *error) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            if (!error) {
                [loading updateWithContent:^(typeof(self) me) {
                    me.items = webLinks;
                }];
            } else {
                [loading doneWithError:error];
            }

        }];
    }];
}
@end
