//
//  RUSOCSearchDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCSearchDataSource.h"
#import "RUSOCSearchIndex.h"

@interface RUSOCSearchDataSource()
@property RUSOCSearchIndex *index;
@end

@implementation RUSOCSearchDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.itemLimit = 35;
    }
    return self;
}

-(void)setNeedsLoadIndex{
    self.index = [[RUSOCSearchIndex alloc] init];
}

-(void)updateForQuery:(NSString *)query{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [self.index resultsForQuery:query completion:^(NSArray *results) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            
            [loading updateWithContent:^(typeof(self) me) {
                self.items = results;
            }];
        }];
    }];
}

@end
