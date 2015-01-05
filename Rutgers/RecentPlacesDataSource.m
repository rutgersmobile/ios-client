//
//  RecentPlacesDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/24/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RecentPlacesDataSource.h"
#import "RULocationManager.h"
#import "RUPlacesDataLoadingManager.h"

@implementation RecentPlacesDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"Recently Viewed";
        
        self.noContentTitle = @"No recent places.";
        self.noContentMessage = @"Search for places using the search bar.";

        self.itemLimit = 8;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsLoadContent) name:PlacesDataDidUpdateRecentPlacesKey object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUPlacesDataLoadingManager sharedInstance] getRecentPlacesWithCompletion:^(NSArray *recentPlaces) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            if (recentPlaces.count) {
                [loading updateWithContent:^(typeof(self) me) {
                    me.items = recentPlaces;
                }];
            } else {
                [loading updateWithNoContent:^(typeof(self) me) {
                    me.items = recentPlaces;
                }];
            }
        }];
    }];
}
@end
