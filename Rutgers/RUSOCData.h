//
//  RUSOCData.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUSOCData : NSObject
+(RUSOCData *)sharedInstance;
-(void)setConfigWithSemester:(NSString *)semester campus:(NSString *)campus level:(NSString *)level;
-(void)getSubjectsForCurrentConfigurationWithSuccess:(void (^)(NSArray *subjects))successBlock failure:(void (^)(void))failureBlock;
-(void)getCoursesForSubjectCode:(NSString *)subject forCurrentConfigurationWithSuccess:(void (^)(NSArray *courses))successBlock failure:(void (^)(void))failureBlock;
-(NSArray *)semesters;
@end

