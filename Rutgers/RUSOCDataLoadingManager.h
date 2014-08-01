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
-(void)getCoursesForSubjectCode:(NSString *)subject withSuccess:(void (^)(NSArray *courses))successBlock failure:(void (^)(void))failureBlock;

@property (nonatomic) NSDictionary *campus;
@property (nonatomic) NSDictionary *level;
@property (nonatomic) NSDictionary *semester;

@property (nonatomic) NSArray *semesters;
@property (nonatomic) NSArray *campuses;
@property (nonatomic) NSArray *levels;

-(void)onSemestersLoaded:(void (^)(void))completion;

-(NSString *)titleForCurrentConfiguration;

@end

