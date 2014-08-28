//
//  RUSOCSearchDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCSearchDataSource.h"
#import "RUSOCSearchIndex.h"
#import "TupleDataSource.h"

@interface RUSOCSearchDataSource()
@property RUSOCSearchIndex *index;
@property TupleDataSource *subjects;
@property TupleDataSource *courses;
@end

@implementation RUSOCSearchDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.subjects = [[TupleDataSource alloc] init];
        self.subjects.title = @"Subjects";
        self.subjects.itemLimit = 25;
        
        self.courses = [[TupleDataSource alloc] init];
        self.courses.title = @"Courses";
        self.courses.itemLimit = 50;
        
        [self addDataSource:self.subjects];
        [self addDataSource:self.courses];
    }
    return self;
}

-(void)setNeedsLoadIndex{
    self.index = [[RUSOCSearchIndex alloc] init];
}

-(void)updateForQuery:(NSString *)query{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [self.index resultsForQuery:query completion:^(NSArray *subjects, NSArray *courses) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            
            [loading updateWithContent:^(typeof(self) me) {
                me.subjects.items = subjects;
                me.courses.items = courses;
            }];
        }];
    }];
}

@end
