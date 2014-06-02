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
-(void)getSubjectsForCurrentConfigurationWithCompletion:(void (^)(NSArray *subjects))completionBlock;
-(void)getCoursesForSubjectCode:(NSString *)subject forCurrentConfigurationWithCompletion:(void (^)(NSArray *courses))completionBlock;
-(NSArray *)semesters;
@end
