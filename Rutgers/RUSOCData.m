//
//  RUSOCData.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCData.h"
#import <AFNetworking.h>
#import "RUNetworkManager.h"

static NSString *const baseString = @"http://sis.rutgers.edu/soc/";

@interface RUSOCData ()
@property NSArray *semesters;
@property NSString *currentSemester;
@property NSString *campus;
@property NSString *level;
@property dispatch_group_t semesterGroup;

@end

@implementation RUSOCData
+(RUSOCData *)sharedInstance{
    static RUSOCData *socData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socData = [[RUSOCData alloc] init];
    });
    return socData;
}
-(NSString *)stringWithStringRelativeToBase:(NSString *)string{
    return [NSString stringWithFormat:@"%@%@",baseString,string];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.semesterGroup = dispatch_group_create();
        [self getSemesters];
    }
    return self;
}

-(void)getSemesters{
    dispatch_group_enter(self.semesterGroup);
    [[RUNetworkManager jsonSessionManager] GET:@"soc_conf.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *semesters = responseObject[@"semesters"];
        self.semesters = semesters;
        NSString *semester = semesters[[responseObject[@"defaultSemester"] integerValue]];
        [self setConfigWithSemester:semester campus:@"NB" level:@"U"];
        dispatch_group_leave(self.semesterGroup);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self getSemesters];
    }];
}

-(void)setConfigWithSemester:(NSString *)semester campus:(NSString *)campus level:(NSString *)level{
    self.currentSemester = semester;
    self.campus = campus;
    self.level = level;
}

-(void)getSubjectsForCurrentConfigurationWithSuccess:(void (^)(NSArray *subjects))successBlock failure:(void (^)(void))failureBlock{
    dispatch_group_notify(self.semesterGroup, dispatch_get_main_queue(), ^{
        [[RUNetworkManager jsonSessionManager] GET:[self stringWithStringRelativeToBase:@"subjects.json"] parameters:@{@"semester" : self.currentSemester, @"campus" : self.campus, @"level" : self.level} success:^(NSURLSessionDataTask *task, id responseObject) {
            successBlock(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            failureBlock();
        }];
    });
}

-(void)getCoursesForSubjectCode:(NSString *)subject forCurrentConfigurationWithSuccess:(void (^)(NSArray *))successBlock failure:(void (^)(void))failureBlock{
    dispatch_group_notify(self.semesterGroup, dispatch_get_main_queue(), ^{
        //NSString *getString = [NSString stringWithFormat:@"courses.json?subject=%@&semester=%@&campus=%@&level=%@",subject,self.currentSemester,self.campus,self.level];
        [[RUNetworkManager jsonSessionManager] GET:[self stringWithStringRelativeToBase:@"courses.json"] parameters:@{@"subject" : subject, @"semester" : self.currentSemester, @"campus" : self.campus, @"level" : self.level} success:^(NSURLSessionDataTask *task, id responseObject) {
            successBlock(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            failureBlock();
        }];
    });
}
@end
