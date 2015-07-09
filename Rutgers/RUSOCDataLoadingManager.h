//
//  RUSOCData.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RUDataLoadingManager.h"

@interface RUSOCDataLoadingManager : RUDataLoadingManager
+(RUSOCDataLoadingManager *)sharedInstance;

-(void)getSubjectsWithCompletion:(void (^)(NSArray *subjects, NSError *error))handler;

-(void)getCoursesForSubjectCode:(NSString *)subjectCode completion:(void (^)(NSArray *courses, NSError *error))handler;
-(void)getCourseForSubjectCode:(NSString *)subjectCode courseCode:(NSString *)courseCode completion:(void (^)(NSDictionary *course, NSError *error))handler;

-(void)getSearchIndexWithCompletion:(void (^)(NSDictionary *index, NSError *error))handler;

@property (nonatomic) NSDictionary *campus;
@property (nonatomic) NSDictionary *level;
@property (nonatomic) NSDictionary *semester;

@property (nonatomic, readonly) NSArray *campuses;
@property (nonatomic, readonly) NSArray *levels;
@property (nonatomic, readonly) NSArray *semesters;

@property (nonatomic, readonly, copy) NSString *titleForCurrentConfiguration;

@end

