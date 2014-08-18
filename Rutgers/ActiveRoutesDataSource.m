//
//  ActiveRoutesDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ActiveRoutesDataSource.h"
#import "RUBusDataLoadingManager.h"

@interface ActiveRoutesDataSource ()
@property NSString *agency;
@end

@implementation ActiveRoutesDataSource
- (instancetype)initWithAgency:(NSString *)agency
{
    self = [super init];
    if (self) {
        self.agency = agency;
        self.title = [NSString stringWithFormat:@"%@ Active Routes",TITLES[agency]];
    }
    return self;
}

-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUBusDataLoadingManager sharedInstance] fetchActiveRoutesForAgency:self.agency completion:^(NSArray *routes, NSError *error) {
            if (!error) {
                [loading updateWithContent:^(ActiveRoutesDataSource *me) {
                    self.items = routes;
                }];
            } else {
                [loading doneWithError:^(ActiveRoutesDataSource *me) {
                    
                }];
            }
        }];
    }];
}
@end
