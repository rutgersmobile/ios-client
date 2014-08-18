//
//  RUSOCData.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUSOCDataLoadingManager : NSObject
+(RUSOCDataLoadingManager *)sharedInstance;

-(void)getSubjectsWithSuccess:(void (^)(NSArray *subjects))successBlock failure:(void (^)(void))failureBlock;
-(void)getCoursesForSubjectCode:(NSString *)subjectCode withSuccess:(void (^)(NSArray *courses))successBlock failure:(void (^)(void))failureBlock;
-(void)getCourseForSubjectCode:(NSString *)subjectCode courseCode:(NSString *)courseCode withSuccess:(void (^)(NSDictionary *course))successBlock failure:(void (^)(void))failureBlock;

-(void)getSearchIndexWithSuccess:(void (^)(NSDictionary *index))successBlock failure:(void (^)(NSError *error))failureBlock;


@property (nonatomic) NSDictionary *campus;
@property (nonatomic) NSDictionary *level;
@property (nonatomic) NSDictionary *semester;

@property (nonatomic) NSArray *semesters;
@property (nonatomic) NSArray *campuses;
@property (nonatomic) NSArray *levels;

-(void)performOnSemestersLoaded:(dispatch_block_t)block;

-(NSString *)titleForCurrentConfiguration;

@end

