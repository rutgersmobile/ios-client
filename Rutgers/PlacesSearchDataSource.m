//
//  PlacesSearchDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "PlacesSearchDataSource.h"
#import "RUPlacesDataLoadingManager.h"

@implementation PlacesSearchDataSource
-(id)init{
    self = [super init];
    if (self) {
        self.itemLimit = 35;
    }
    return self;
}

-(void)updateForQuery:(NSString *)query{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUPlacesDataLoadingManager sharedInstance] queryPlacesWithString:query completion:^(NSArray *results) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            
            [loading updateWithContent:^(typeof(self) me) {
                me.items = results;
            }];
        }];
    }];
}
@end
