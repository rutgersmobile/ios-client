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
#import "RUSOCSearchOperation.h"

@interface RUSOCSearchDataSource()
@property RUSOCSearchIndex *index;
@property TupleDataSource *subjectsDataSource;
@property TupleDataSource *coursesDataSource;
@property RUSOCSearchOperation *currentOperation;
@property NSOperationQueue *operationQueue;
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
        self.coursesDataSource.itemLimit = 75;
        
        self.operationQueue = [[NSOperationQueue alloc] init];
        
        [self addDataSource:self.subjectsDataSource];
        [self addDataSource:self.coursesDataSource];
    }
    return self;
}

-(void)setNeedsLoadIndex{
    self.index = [[RUSOCSearchIndex alloc] init];
}

-(void)updateForQuery:(NSString *)query{
    [self.currentOperation cancel];

    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [self.index performWhenLoaded:^(NSError *error) {
            if (error) {
                [loading doneWithError:error];
            } else {
                RUSOCSearchOperation *operation = [[RUSOCSearchOperation alloc] initWithQuery:query searchIndex:self.index];
                __weak typeof(operation) weakOperation = operation;
                self.currentOperation = operation;
                operation.completionBlock = ^{
                    typeof (operation) operation = weakOperation;
                    if (operation.cancelled) {
                        [loading ignore];
                    } else {
                        [loading updateWithContent:^(typeof(self) me) {
                            [me.subjectsDataSource loadContentWithBlock:^(AAPLLoading *loading) {
                                [loading updateWithContent:^(typeof(self.subjectsDataSource) subjectsDataSource) {
                                    subjectsDataSource.items = operation.subjects;
                                }];
                            }];
                            
                            [me.coursesDataSource loadContentWithBlock:^(AAPLLoading *loading) {
                                [loading updateWithContent:^(typeof(self.coursesDataSource) coursesDataSource) {
                                    coursesDataSource.items = operation.courses;
                                }];
                            }];
                        }];
                    }
                };
                [self.operationQueue addOperation:operation];
            }
        }];
    }];
}

@end
