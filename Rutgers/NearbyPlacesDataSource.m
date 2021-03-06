//
//  NearbyPlacesDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/24/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NearbyPlacesDataSource.h"
#import "RULocationManager.h"
#import "RUPlacesDataLoadingManager.h"

@implementation NearbyPlacesDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"Nearby Places";
        self.itemLimit = 10;

        self.noContentTitle = @"No nearby places";
        self.noContentMessage = @"Search for places using the search bar";
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsLoadContent) name:LocationManagerDidChangeLocationKey object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUPlacesDataLoadingManager sharedInstance] placesNearLocation:[RULocationManager sharedLocationManager].location completion:^(NSArray *nearbyPlaces, NSError *error) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            
            if (!error) {
                [loading updateWithContent:^(typeof(self) me) {
                    me.items = nearbyPlaces;
                }];
            } else {
                [loading doneWithError:error];
            }
        }];
    }];
}

@end
