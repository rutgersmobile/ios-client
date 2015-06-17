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
#import "RUDataLoadingManager_Private.h"

@implementation RUSOCSearchIndex
-(instancetype)init{
    self = [super init];
    if (self) {
        [self load];
    }
    return self;
}

-(void)load{
    [self willBeginLoad];
    [[RUSOCDataLoadingManager sharedInstance] getSearchIndexWithCompletion:^(NSDictionary *index, NSError *error) {
        if (index) {
            [self parseIndex:index];
            [self didEndLoad:YES withError:nil];
        } else {
            [self didEndLoad:NO withError:error];
        }
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
