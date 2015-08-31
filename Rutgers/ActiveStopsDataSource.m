//
//  ActiveStopsDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ActiveStopsDataSource.h"
#import "RUBusDataLoadingManager.h"

@interface ActiveStopsDataSource ()
@property NSString *agency;
@end

@implementation ActiveStopsDataSource
- (instancetype)initWithAgency:(NSString *)agency
{
    self = [super init];
    if (self) {
        self.agency = agency;
        self.title = [NSString stringWithFormat:@"%@ Active Stops",[RUBusDataLoadingManager titleForAgency:agency]];
        self.noContentTitle = [NSString stringWithFormat:@"No %@ Active Stops",[RUBusDataLoadingManager titleForAgency:agency]];
    }
    return self;
}

-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUBusDataLoadingManager sharedInstance] fetchActiveStopsForAgency:self.agency completion:^(NSArray *stops, NSError *error) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            
            if (!error) {
                [loading updateWithContent:^(typeof(self) me) {
                    me.items = stops;
                }];
            } else {
                [loading doneWithError:error];
            }
        }];
    }];
}
@end
