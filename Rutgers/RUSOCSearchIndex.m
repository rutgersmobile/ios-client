//
//  RUSOCSearchIndex.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCSearchIndex.h"
#import "RUSOCDataLoadingManager.h"
#import "DataTuple.h"
#import "RUSOCSearchOperation.h"

@interface RUSOCSearchIndex()
@property dispatch_group_t indexGroup;

@property BOOL loading;
@property BOOL finishedLoading;
@property NSError *loadingError;

@end

@implementation RUSOCSearchIndex
-(id)init{
    self = [super init];
    if (self) {
        self.indexGroup = dispatch_group_create();
        [self loadIndex];
    }
    return self;
}

-(void)performWhenIndexLoaded:(void(^)(NSError *error))handler{
    if ([self indexNeedsLoad]) {
        [self loadIndex];
    }
    dispatch_group_notify(self.indexGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        handler(self.loadingError);
    });
}

-(BOOL)indexNeedsLoad{
    return !(self.loading || self.finishedLoading);
}

-(void)loadIndex{
    dispatch_group_enter(self.indexGroup);

    self.loading = YES;
    self.finishedLoading = NO;
    self.loadingError = nil;
    
    [[RUSOCDataLoadingManager sharedInstance] getSearchIndexWithCompletion:^(NSDictionary *index, NSError *error) {
        if (!error) {
            [self parseIndex:index];
            
            self.loading = NO;
            self.finishedLoading = YES;
            self.loadingError = nil;
            
        } else {
            
            self.loading = NO;
            self.finishedLoading = NO;
            self.loadingError = error;
            
        }
        dispatch_group_leave(self.indexGroup);
    }];
}

-(void)parseIndex:(NSDictionary *)index{
    NSMutableDictionary *ids = [NSMutableDictionary dictionary];
   
    [index[@"ids"] enumerateKeysAndObjectsUsingBlock:^(NSString *subjectID, NSDictionary *subjectDict, BOOL *stop) {
      
        NSMutableDictionary *parsedCourses = [NSMutableDictionary dictionary];
        NSString *subjectName = subjectDict[@"name"];

        [subjectDict[@"courses"] enumerateKeysAndObjectsUsingBlock:^(NSString *courseID, NSString *courseName, BOOL *stop) {
            parsedCourses[courseID] = [DataTuple tupleWithTitle:[NSString stringWithFormat:@"%@: %@ (%@:%@)",subjectName,courseName,subjectID,courseID] object:@{@"title" : courseName, @"subjectTitle" : subjectName, @"subjectCode" : subjectID, @"courseNumber" : courseID}];
        }];
        
        ids[subjectID] = [DataTuple tupleWithTitle:[NSString stringWithFormat:@"%@ (%@)",subjectName,subjectID] object:@{@"description" : subjectName, @"code" : subjectID, @"courses" : parsedCourses }];
        
    }];
    
    self.ids = ids;
    self.abbreviations = index[@"abbrevs"];
    self.courses = index[@"courses"];
    self.subjects = index[@"names"];
}

@end
