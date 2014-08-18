//
//  AllRoutesDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "AllRoutesDataSource.h"
#import "RUBusDataLoadingManager.h"

@interface AllRoutesDataSource ()
@property NSString *agency;
@end

@implementation AllRoutesDataSource
- (instancetype)initWithAgency:(NSString *)agency
{
    self = [super init];
    if (self) {
        self.agency = agency;
        self.title = [NSString stringWithFormat:@"All %@ Routes",TITLES[agency]];
    }
    return self;
}
-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUBusDataLoadingManager sharedInstance] fetchAllRoutesForAgency:self.agency completion:^(NSArray *routes, NSError *error) {
            if (!error) {
                [loading updateWithContent:^(AllRoutesDataSource *me) {
                    self.items = routes;
                }];
            } else {
                [loading doneWithError:^(AllRoutesDataSource *me) {
                    
                }];
            }
        }];
    }];
}
@end
