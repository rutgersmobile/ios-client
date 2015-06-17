//
//  AllStopsDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "AllStopsDataSource.h"
#import "RUBusDataLoadingManager.h"

@interface AllStopsDataSource ()
@property NSString *agency;
@end

@implementation AllStopsDataSource
- (instancetype)initWithAgency:(NSString *)agency
{
    self = [super init];
    if (self) {
        self.agency = agency;
        self.title = [NSString stringWithFormat:@"All %@ Stops",[RUBusDataLoadingManager titleForAgency:agency]];
    }
    return self;
}
-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUBusDataLoadingManager sharedInstance] fetchAllStopsForAgency:self.agency completion:^(NSArray *stops, NSError *error) {
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
