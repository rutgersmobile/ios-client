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
@property TupleDataSource *subjectsDataSource;
@property TupleDataSource *coursesDataSource;
@end

@implementation RUSOCSearchDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.subjectsDataSource = [[TupleDataSource alloc] init];
        self.subjectsDataSource.title = @"Subjects";
        self.subjectsDataSource.noContentTitle = @"No matching subjects";
        self.subjectsDataSource.itemLimit = 25;
        
        self.coursesDataSource = [[TupleDataSource alloc] init];
        self.coursesDataSource.title = @"Courses";
        self.coursesDataSource.noContentTitle = @"No matching courses";
        self.coursesDataSource.itemLimit = 50;
        
        [self addDataSource:self.subjectsDataSource];
        [self addDataSource:self.coursesDataSource];
    }
    return self;
}

-(void)setNeedsLoadIndex{
    self.index = [[RUSOCSearchIndex alloc] init];
}

-(void)updateForQuery:(NSString *)query{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [self.index resultsForQuery:query completion:^(NSArray *subjects, NSArray *courses, NSError *error) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            
            if (!error) {
                [loading updateWithContent:^(typeof(self) me) {
                    [me.subjectsDataSource loadContentWithBlock:^(AAPLLoading *loading) {
                        [loading updateWithContent:^(typeof(self.subjectsDataSource) subjectsDataSource) {
                            subjectsDataSource.items = subjects;
                        }];
                    }];
                    
                    [me.coursesDataSource loadContentWithBlock:^(AAPLLoading *loading) {
                        [loading updateWithContent:^(typeof(self.coursesDataSource) coursesDataSource) {
                            coursesDataSource.items = courses;
                        }];
                    }];
                }];
            } else {
                [loading doneWithError:error];
            }
        }];
    }];
}

@end
