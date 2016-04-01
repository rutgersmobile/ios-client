//
//  RUSOCData.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "RUDataLoadingManager.h"

@interface RUSOCDataLoadingManager : NSObject
+(instancetype)managerForSemesterTag:(NSString *)semesterTag campusTag:(NSString *)campusTag levelTag:(NSString *)levelTag;

-(void)getSubjectsWithCompletion:(void (^)(NSArray *subjects, NSError *error))handler;

-(void)getCoursesForSubjectCode:(NSString *)subjectCode completion:(void (^)(NSArray *courses, NSError *error))handler;
-(void)getCourseForSubjectCode:(NSString *)subjectCode courseCode:(NSString *)courseCode completion:(void (^)(NSDictionary *course, NSError *error))handler;

-(void)getSearchIndexWithCompletion:(void (^)(NSDictionary *index, NSError *error))handler;

@property (nonatomic) NSDictionary *campus;
@property (nonatomic) NSDictionary *level;
@property (nonatomic) NSDictionary *semester;

+(NSArray *)campuses;
+(NSArray *)levels;
+(NSArray *)semesters;
+(void)performWhenSemestersLoaded:(void (^)(NSError *error))block;

@property (nonatomic, readonly, copy) NSString *titleForCurrentConfiguration;
@end

@interface RUSOCDataLoadingManager (SharedInstance)
+(RUSOCDataLoadingManager *)sharedInstance;
@end
