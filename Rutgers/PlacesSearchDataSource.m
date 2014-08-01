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
        self.itemLimit = 25;
    }
    return self;
}

-(void)updateForSearchString:(NSString *)searchString{
    [[RUPlacesDataLoadingManager sharedInstance] queryPlacesWithString:searchString completion:^(NSArray *results) {
        self.items = results;
    }];
}
@end
