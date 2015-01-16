//
//  RUSOCData.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCDataLoadingManager.h"
#import <AFNetworking.h>
#import "RUUserInfoManager.h"
#import "RUSOCCourseRow.h"

static NSString *const baseString = @"http://sis.rutgers.edu/soc/";

static NSString *const SOCDataCampusKey = @"SOCDataCampusKey";
static NSString *const SOCDataLevelKey = @"SOCDataLevelKey";
static NSString *const SOCDataSemesterKey = @"SOCDataSemesterKey";

@interface RUSOCDataLoadingManager ()
@property (nonatomic) NSArray *semesters;
@property (nonatomic) NSArray *campuses;
@property (nonatomic) NSArray *levels;
@property (nonatomic) NSInteger defaultSemesterIndex;

@property dispatch_group_t semesterGroup;

@property BOOL loading;
@property BOOL finishedLoading;
@property NSError *loadingError;
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
    }
    return self;
}

-(BOOL)semesterIndexNeedsLoad{
    return !(self.loading || self.finishedLoading);
}

-(void)performOnSemestersLoaded:(void (^)(NSError *error))block{
    if ([self semesterIndexNeedsLoad]) {
        [self loadSemesterIndex];
    }
    dispatch_group_notify(self.semesterGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        block(self.loadingError);
    });
}

-(void)loadSemesterIndex{
    dispatch_group_enter(self.semesterGroup);
    
    self.loading = YES;
    self.finishedLoading = NO;
    self.loadingError = nil;
    
    [[RUNetworkManager sessionManager] GET:@"soc_conf.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.semesters = [self parseSemesters:responseObject[@"semesters"]];
        self.defaultSemesterIndex = [responseObject[@"defaultSemester"] integerValue];
        
        self.loading = NO;
        self.finishedLoading = YES;
        self.loadingError = nil;
        
        dispatch_group_leave(self.semesterGroup);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        self.loading = NO;
        self.finishedLoading = NO;
        self.loadingError = error;
        
        dispatch_group_leave(self.semesterGroup);
    }];
}

-(BOOL)onlineCampusSelected{
    return [self.campus[@"tag"] isEqualToString:@"ONLINE"];
}

-(NSString *)subjectsURL{
    return [baseString stringByAppendingString:([self onlineCampusSelected] ? @"onlineSubjects.json" : @"subjects.json")];
}

-(NSString *)coursesURL{
    return [baseString stringByAppendingString:([self onlineCampusSelected] ? @"onlineCourses.json" : @"courses.json")];
}

-(NSString *)courseURL{
    return [baseString stringByAppendingString:([self onlineCampusSelected] ? @"onlineCourse.json" : @"course.json")];
}

-(NSDictionary *)parametersWithOtherParameters:(NSDictionary *)parameters{
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    
    NSString *semesterTag = self.semester[@"tag"];
    if ([self onlineCampusSelected]) {
        [mutableParameters addEntriesFromDictionary:@{@"term" : [semesterTag substringToIndex:1],
                                                      @"year" : [semesterTag substringFromIndex:1],
                                                      @"level" : self.level[@"tag"]
                                                    }];
    } else {
        [mutableParameters addEntriesFromDictionary:@{
                                                      @"semester" : semesterTag,
                                                      @"campus" : self.campus[@"tag"],
                                                      @"level" : self.level[@"tag"]
                                                      }];
    }
    return mutableParameters;
}

-(void)getSubjectsWithCompletion:(void (^)(NSArray *, NSError *))handler{
    [self performOnSemestersLoaded:^(NSError *error) {
        if (error) {
            handler(nil,error);
        } else {
            [[RUNetworkManager sessionManager] GET:[self subjectsURL] parameters:[self parametersWithOtherParameters:nil] success:^(NSURLSessionDataTask *task, id responseObject) {
                handler(responseObject,nil);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                handler(nil,error);
            }];
        }
    }];
}

-(void)getCoursesForSubjectCode:(NSString *)subjectCode completion:(void (^)(NSArray *, NSError *))handler{
    [self performOnSemestersLoaded:^(NSError *error) {
        if (error) {
            handler(nil,error);
        } else {
            [[RUNetworkManager sessionManager] GET:[self coursesURL] parameters:[self parametersWithOtherParameters:@{@"subject" : subjectCode}] success:^(NSURLSessionDataTask *task, id responseObject) {
                NSMutableArray *parsedItems = [NSMutableArray array];
                for (NSDictionary *course in responseObject) {
                    RUSOCCourseRow *row = [[RUSOCCourseRow alloc] initWithCourse:course];
                    [parsedItems addObject:row];
                }
                handler(parsedItems,nil);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                handler(nil,error);
            }];
        }
    }];
}

-(void)getCourseForSubjectCode:(NSString *)subjectCode courseCode:(NSString *)courseCode completion:(void (^)(NSDictionary *, NSError *))handler{
    [self performOnSemestersLoaded:^(NSError *error) {
        if (error) {
            handler(nil,error);
        } else {
            [[RUNetworkManager sessionManager] GET:[self courseURL] parameters:[self parametersWithOtherParameters:@{@"subject" : subjectCode, @"courseNumber" : courseCode}] success:^(NSURLSessionDataTask *task, id responseObject) {
                handler(responseObject,nil);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                handler(nil,error);
            }];
        }
    }];
}

-(void)getSearchIndexWithCompletion:(void (^)(NSDictionary *, NSError *))handler{
    [self performOnSemestersLoaded:^(NSError *error) {
        if (error) {
            handler(nil,error);
        } else {
            NSString *indexString = [NSString stringWithFormat:@"indexes/%@_%@_%@.json",self.semester[@"tag"], self.campus[@"tag"], self.level[@"tag"]];
            [[RUNetworkManager sessionManager] GET:indexString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                handler(responseObject,nil);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                handler(nil,error);
            }];
        }
    }];
}

-(NSDictionary *)campus{
    NSDictionary *campus = [[NSUserDefaults standardUserDefaults] dictionaryForKey:SOCDataCampusKey];
    if (campus) return campus;

    campus = [RUUserInfoManager currentCampus];
    
    if ([[self.campuses valueForKeyPath:@"tag"] containsObject:campus[@"tag"]]) return campus;
    
    return [self.campuses firstObject];
}

-(void)setCampus:(NSDictionary *)campus{
    [[NSUserDefaults standardUserDefaults] setObject:campus forKey:SOCDataCampusKey];
}

-(NSDictionary *)level{
    NSDictionary *level = [[NSUserDefaults standardUserDefaults] dictionaryForKey:SOCDataLevelKey];
    if (level) return level;
    
    level = [RUUserInfoManager currentUserRole];
    
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
