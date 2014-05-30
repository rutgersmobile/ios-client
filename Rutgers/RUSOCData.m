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

@interface RUSOCData ()
@property AFHTTPSessionManager *socNetworkManager;
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

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.socNetworkManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://sis.rutgers.edu/soc/"]];
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
        [self setSemester:semester campus:@"NB" level:@"U"];
        dispatch_group_leave(self.semesterGroup);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

-(void)setSemester:(NSString *)semester campus:(NSString *)campus level:(NSString *)level{
    self.currentSemester = semester;
    self.campus = campus;
    self.level = level;
}

-(void)getSubjectsForCurrentSemesterWithCompletion:(void (^)(NSArray *subjects))completionBlock{
    dispatch_group_notify(self.semesterGroup, dispatch_get_main_queue(), ^{
        NSString *getString = [NSString stringWithFormat:@"subjects.json?semester=%@&campus=%@&level=%@",self.currentSemester,self.campus,self.level];
        [self.socNetworkManager GET:getString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            completionBlock(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    });
}

-(void)getCoursesForSubjectCode:(NSString *)subject inCurrentSemesterWithCompletion:(void (^)(NSArray *courses))completionBlock{
    NSString *getString = [NSString stringWithFormat:@"courses.json?subject=%@&semester=%@&campus=%@&level=%@",subject,self.currentSemester,self.campus,self.level];
    [self.socNetworkManager GET:getString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completionBlock(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}
@end
