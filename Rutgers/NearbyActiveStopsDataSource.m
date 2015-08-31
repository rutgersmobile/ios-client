//
//  NearbyActiveStopsDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NearbyActiveStopsDataSource.h"
#import "RUBusDataLoadingManager.h"
#import "RULocationManager.h"

@implementation NearbyActiveStopsDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"Nearby Active Stops";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsLoadContent) name:LocationManagerDidChangeLocationKey object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        if (self.location) {
            self.noContentTitle = @"No Nearby Active Stops";
        } else {
            self.noContentTitle = @"Unable to find location";
        }
        
        [[RUBusDataLoadingManager sharedInstance] fetchActiveStopsNearbyLocation:self.location completion:^(NSArray *stops, NSError *error) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            
            if (!error) {
                [loading updateWithContent:^(typeof(self) me) {
                    self.items = stops;
                }];
            } else {
                [loading doneWithError:error];
            }
        }];
    }];
}

-(CLLocation *)location{
    if (!_location) {
        return [RULocationManager sharedLocationManager].location;
    }
    return _location;
}
@end
