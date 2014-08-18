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
        self.title = [NSString stringWithFormat:@"%@ Active Stops",TITLES[agency]];
    }
    return self;
}

-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUBusDataLoadingManager sharedInstance] fetchActiveStopsForAgency:self.agency completion:^(NSArray *routes, NSError *error) {
            if (!error) {
                [loading updateWithContent:^(ActiveStopsDataSource *me) {
                    self.items = routes;
                }];
            } else {
                [loading doneWithError:^(ActiveStopsDataSource *me) {
                    
                }];
            }
        }];
    }];
}
@end
