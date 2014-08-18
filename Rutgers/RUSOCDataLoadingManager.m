//
//  RUSOCData.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCDataLoadingManager.h"
#import <AFNetworking.h>
#import "RUNetworkManager.h"
#import "RUUserInfoManager.h"

static NSString *const baseString = @"http://sis.rutgers.edu/soc/";

static NSString *const SOCDataCampusKey = @"SOCDataCampusKey";
static NSString *const SOCDataLevelKey = @"SOCDataLevelKey";
static NSString *const SOCDataSemesterKey = @"SOCDataSemesterKey";

@interface RUSOCDataLoadingManager ()

@property (nonatomic) NSInteger defaultSemesterIndex;

@property dispatch_group_t semesterGroup;

@end

@implementation RUSOCDataLoadingManager
+(RUSOCDataLoadingManager *)sharedInstance{
    static RUSOCDataLoadingManager *socData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socData = [[RUSOCDataLoadingManager alloc] init];
    });
    return socData;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.campuses = @[
                         @{@"title": @"New Brunswick", @"tag": @"NB"},
                         @{@"title": @"Newark", @"tag": @"NK"},
                         @{@"title": @"Camden", @"tag": @"CM"},
                         @{@"title": @"Online Courses", @"tag": @"ONLINE"},
                         @{@"title": @"Freehold WMHEC: RU-BCC", @"tag": @"WM"},
                         @{@"title": @"Mays Landing: RU-ACCC", @"tag": @"AC"},
                         @{@"title": @"Denville: RU-Morris", @"tag": @"MC"},
                         @{@"title": @"McGuire-Dix-Lakehurst: RU-JBMDL", @"tag": @"J"},
                         @{@"title": @"North Branch: RU-RVCC", @"tag": @"RV"},
                         @{@"title": @"Camden County College", @"tag": @"CC"},
                         @{@"title": @"Cumberland County College", @"tag": @"CU"}
                         ];
        
        self.levels = @[
                      @{@"title": @"Undergraduate", @"tag": @"U"},
                      @{@"title": @"Graduate", @"tag": @"G"}
                      ];
            
        self.semesterGroup = dispatch_group_create();
        dispatch_group_enter(self.semesterGroup);
        [self getSemesters];
    }
    return self;
}
-(void)performOnSemestersLoaded:(void (^)(void))block{
    dispatch_group_notify(self.semesterGroup, dispatch_get_main_queue(), block);
}

-(void)getSemesters{
    [[RUNetworkManager jsonSessionManager] GET:@"soc_conf.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.semesters = [self parseSemesters:responseObject[@"semesters"]];
        self.defaultSemesterIndex = [responseObject[@"defaultSemester"] integerValue];
        dispatch_group_leave(self.semesterGroup);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getSemesters];
        });
    }];
}

-(BOOL)isOnline{
    return [self.campus[@"tag"] isEqualToString:@"ONLINE"];
}

-(NSString *)subjectsURL{
    return [baseString stringByAppendingString:([self isOnline] ? @"onlineSubjects.json" : @"subjects.json")];
}

-(NSString *)coursesURL{
    return [baseString stringByAppendingString:([self isOnline] ? @"onlineCourses.json" : @"courses.json")];
}

-(NSString *)courseURL{
    return [baseString stringByAppendingString:([self isOnline] ? @"onlineCourse.json" : @"course.json")];
}

-(void)getSubjectsWithSuccess:(void (^)(NSArray *subjects))successBlock failure:(void (^)(void))failureBlock{
    [self performOnSemestersLoaded:^{
        [[RUNetworkManager jsonSessionManager] GET:[self subjectsURL] parameters:@{@"semester" : self.semester[@"tag"], @"campus" : self.campus[@"tag"], @"level" : self.level[@"tag"]} success:^(NSURLSessionDataTask *task, id responseObject) {
            successBlock(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            failureBlock();
        }];
    }];
}

-(void)getCoursesForSubjectCode:(NSString *)subjectCode withSuccess:(void (^)(NSArray *))successBlock failure:(void (^)(void))failureBlock{
    [self performOnSemestersLoaded:^{
        [[RUNetworkManager jsonSessionManager] GET:[self coursesURL] parameters:@{@"subject" : subjectCode, @"semester" : self.semester[@"tag"], @"campus" : self.campus[@"tag"], @"level" : self.level[@"tag"]} success:^(NSURLSessionDataTask *task, id responseObject) {
            successBlock(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            failureBlock();
        }];
    }];
}

-(void)getCourseForSubjectCode:(NSString *)subjectCode courseCode:(NSString *)courseCode withSuccess:(void (^)(NSDictionary *))successBlock failure:(void (^)(void))failureBlock{
    [self performOnSemestersLoaded:^{
        [[RUNetworkManager jsonSessionManager] GET:[self courseURL] parameters:@{@"subject" : subjectCode, @"courseNumber" : courseCode, @"semester" : self.semester[@"tag"], @"campus" : self.campus[@"tag"], @"level" : self.level[@"tag"]} success:^(NSURLSessionDataTask *task, id responseObject) {
            successBlock(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            failureBlock();
        }];
    }];
}

-(void)getSearchIndexWithSuccess:(void (^)(NSDictionary *))successBlock failure:(void (^)(NSError *))failureBlock{
    [self performOnSemestersLoaded:^{
        NSString *indexString = [NSString stringWithFormat:@"indexes/%@_%@_%@.json",self.semester[@"tag"], self.campus[@"tag"], self.level[@"tag"]];
        [[RUNetworkManager jsonSessionManager] GET:indexString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            successBlock(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            failureBlock(error);
        }];
    }];
}

-(NSDictionary *)campus{
    NSDictionary *campus = [[NSUserDefaults standardUserDefaults] dictionaryForKey:SOCDataCampusKey];
    if (campus) return campus;

    campus = [RUUserInfoManager sharedInstance].campus;
    
    if ([[self.campuses valueForKeyPath:@"tag"] containsObject:campus[@"tag"]]) return campus;
    
    return [self.campuses firstObject];
}
-(void)setCampus:(NSDictionary *)campus{
    [[NSUserDefaults standardUserDefaults] setObject:campus forKey:SOCDataCampusKey];
}

-(NSDictionary *)level{
    NSDictionary *level = [[NSUserDefaults standardUserDefaults] dictionaryForKey:SOCDataLevelKey];
    if (level) return level;
    
    level = [RUUserInfoManager sharedInstance].userRole;
    
    if ([[self.levels valueForKeyPath:@"tag"] containsObject:level[@"tag"]]) return level;
    
    return [self.levels firstObject];
}
-(void)setLevel:(NSDictionary *)level{
    [[NSUserDefaults standardUserDefaults] setObject:level forKey:SOCDataLevelKey];
}

-(NSDictionary *)semester{
    NSDictionary *semester = [[NSUserDefaults standardUserDefaults] dictionaryForKey:SOCDataSemesterKey];
    if ([self.semesters containsObject:semester]) return semester;
    
    return self.semesters[self.defaultSemesterIndex];
}
-(void)setSemester:(NSDictionary *)semester{
    [[NSUserDefaults standardUserDefaults] setObject:semester forKey:SOCDataSemesterKey];
}

-(NSArray *)parseSemesters:(NSArray *)semesters{
    NSMutableArray *parsedSemesters = [NSMutableArray array];
    for (NSString *semesterTag in semesters) {
        [parsedSemesters addObject:@{@"title": [self descriptionForSemesterTag:semesterTag], @"tag": semesterTag}];
    }
    return parsedSemesters;
}

-(NSString *)descriptionForSemesterTag:(NSString *)semesterTag{
    NSDictionary *monthMap = @{@"0": @"Winter", @"1": @"Spring", @"7": @"Summer", @"9": @"Fall"};
    NSString *startMonth = [semesterTag substringToIndex:1];
    NSString *year = [semesterTag substringFromIndex:1];
    
    return [NSString stringWithFormat:@"%@ %@",monthMap[startMonth],year];
}

-(NSString *)titleForCurrentConfiguration{
    return [NSString stringWithFormat:@"%@ %@ %@",self.semester[@"title"],self.campus[@"tag"],self.level[@"tag"]];
}

@end