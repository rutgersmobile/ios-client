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
#import "RUDataLoadingManager_Private.h"
#import "RUNetworkManager.h"
#import "NSURL+RUAdditions.h"

static NSString *const baseString = @"https://sis.rutgers.edu/soc/";

static NSString *const SOCDataCampusKey = @"SOCDataCampusKey";
static NSString *const SOCDataLevelKey = @"SOCDataLevelKey";
static NSString *const SOCDataSemesterKey = @"SOCDataSemesterKey";

@interface RUSOCSemesterIndexLoader : RUDataLoadingManager
@property (nonatomic) NSArray *semesters;
@property (nonatomic) NSInteger defaultSemesterIndex;
@end

@implementation RUSOCSemesterIndexLoader
+(RUSOCSemesterIndexLoader *)indexLoader{
    static RUSOCSemesterIndexLoader *indexLoader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        indexLoader = [[RUSOCSemesterIndexLoader alloc] init];
    });
    return indexLoader;
}

-(void)load{
    [self willBeginLoad];
    [[RUNetworkManager sessionManager] GET:@"soc_conf.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            self.semesters = [self parseSemesters:responseObject[@"semesters"]];
            self.defaultSemesterIndex = [responseObject[@"defaultSemester"] integerValue];
            [self didEndLoad:YES withError:nil];
        } else {
            [self didEndLoad:NO withError:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self didEndLoad:NO withError:error];
    }];
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
@end

NSDictionary *(^findItemWithMatchingTag)(NSArray<NSDictionary *>*, NSString *) = ^NSDictionary *(NSArray<NSDictionary *>* items, NSString *tagToFind) {
    for (NSDictionary *item in items) {
        NSString *tag = item[@"tag"];
        if ([[tag rutgersStringEscape] isEqualToString:tagToFind]) {
            return item;
        }
    }
    return nil;
};

@implementation RUSOCDataLoadingManager
+(instancetype)managerForSemesterTag:(NSString *)semesterTagToFind campusTag:(NSString *)campusTagToFind levelTag:(NSString *)levelTagToFind{

    NSDictionary *campus = findItemWithMatchingTag([self campuses], campusTagToFind);
    NSDictionary *level = findItemWithMatchingTag([self levels], levelTagToFind);
    NSDictionary *semester = findItemWithMatchingTag([self semesters], semesterTagToFind);
    
    if (!campus || !level) return nil;
    
    RUSOCDataLoadingManager *manager = [[RUSOCDataLoadingManager alloc] init];
   
    manager.campus = campus;
    manager.level = level;
    
    manager.semester = semester;
    manager.semesterTag = semesterTagToFind;
    
    return manager;
}

+(NSArray *)campuses{
    static NSArray *campuses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        campuses = @[
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
    });
    return campuses;
}

+(NSArray *)levels{
    static NSArray *levels = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        levels = @[
                   @{@"title": @"Undergraduate", @"tag": @"U"},
                   @{@"title": @"Graduate", @"tag": @"G"}
                   ];
    });
    return levels;
}

+(NSArray *)semesters{
    return [RUSOCSemesterIndexLoader indexLoader].semesters;
}

-(void)performWhenSemestersLoaded:(void (^)(NSError *))block{
    [[RUSOCSemesterIndexLoader indexLoader] performWhenLoaded:^(NSError *error) {
       dispatch_async(dispatch_get_main_queue(), ^{
           if (self.semester == nil) {
               self.semester = findItemWithMatchingTag([RUSOCDataLoadingManager semesters], self.semesterTag);
           }
           block(error);
       });
    }];
}

+(NSInteger)defaultSemesterIndex{
    return [RUSOCSemesterIndexLoader indexLoader].defaultSemesterIndex;
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
    [self performWhenSemestersLoaded:^(NSError *error) {
        if (error) {
            handler(nil,error);
        } else {
            [[RUNetworkManager sessionManager] GET:[self subjectsURL] parameters:[self parametersWithOtherParameters:nil] success:^(NSURLSessionDataTask *task, id responseObject) {
                if ([responseObject isKindOfClass:[NSArray class]]) {
                    handler(responseObject,nil);
                } else {
                    handler(nil,nil);
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                handler(nil,error);
            }];
        }
    }];
}

-(void)getCoursesForSubjectCode:(NSString *)subjectCode completion:(void (^)(NSArray *, NSError *))handler{
    [self performWhenSemestersLoaded:^(NSError *error) {
        if (error) {
            handler(nil,error);
        } else {
            [[RUNetworkManager sessionManager] GET:[self coursesURL] parameters:[self parametersWithOtherParameters:@{@"subject" : subjectCode}] success:^(NSURLSessionDataTask *task, id responseObject) {
                if ([responseObject isKindOfClass:[NSArray class]]) {
                    handler(responseObject,nil);
                } else {
                    handler(nil,nil);
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                handler(nil,error);
            }];
        }
    }];
}

-(void)getCourseForSubjectCode:(NSString *)subjectCode courseCode:(NSString *)courseCode completion:(void (^)(NSDictionary *, NSError *))handler{
    [self performWhenSemestersLoaded:^(NSError *error) {
        if (error) {
            handler(nil,error);
        } else {
            [[RUNetworkManager sessionManager] GET:[self courseURL] parameters:[self parametersWithOtherParameters:@{@"subject" : subjectCode, @"courseNumber" : courseCode}] success:^(NSURLSessionDataTask *task, id responseObject) {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    handler(responseObject,nil);
                } else {
                    handler(nil,nil);
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                handler(nil,error);
            }];
        }
    }];
}

-(void)getSearchIndexWithCompletion:(void (^)(NSDictionary *, NSError *))handler{
    [self performWhenSemestersLoaded:^(NSError *error) {
        if (error) {
            handler(nil,error);
        } else {
            NSString *indexString = [NSString stringWithFormat:@"indexes/%@_%@_%@.json",self.semester[@"tag"], self.campus[@"tag"], self.level[@"tag"]];
            [[RUNetworkManager sessionManager] GET:indexString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    handler(responseObject,nil);
                } else {
                    handler(nil,nil);
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                handler(nil,error);
            }];
        }
    }];
}

-(NSString *)titleForCurrentConfiguration{
    return [NSString stringWithFormat:@"%@ %@ %@",self.semester[@"title"],self.campus[@"tag"],self.level[@"tag"]];
}

@end

@interface RUSOCSingletonDataLoadingManager : RUSOCDataLoadingManager

@end

@implementation RUSOCSingletonDataLoadingManager
-(NSDictionary *)campus{
    //First we check if the user has set a specific campus for the SOC channel
    NSDictionary *campus = [[NSUserDefaults standardUserDefaults] dictionaryForKey:SOCDataCampusKey];
    if (campus) return campus;
    
    //Otherwise if they havent, we default to the app wide campus setting
    campus = [RUUserInfoManager currentCampus];
    
    //However the set of app wide campuses are different than the set of campuses for SOC
    //So we check the app wide setting campus corresponds to a SOC campus
    NSArray *campuses = [RUSOCDataLoadingManager campuses];
    if ([[campuses valueForKeyPath:@"tag"] containsObject:campus[@"tag"]]) return campus;
    
    //Otherwise return the SOC default
    return [campuses firstObject];
}

-(void)setCampus:(NSDictionary *)campus{
    [[NSUserDefaults standardUserDefaults] setObject:campus forKey:SOCDataCampusKey];
}

-(NSDictionary *)level{
    NSDictionary *level = [[NSUserDefaults standardUserDefaults] dictionaryForKey:SOCDataLevelKey];
    if (level) return level;
    
    level = [RUUserInfoManager currentUserRole];
    
    NSArray *levels = [RUSOCDataLoadingManager levels];
    
    if ([[levels valueForKeyPath:@"tag"] containsObject:level[@"tag"]]) return level;
    
    return [levels firstObject];
}
-(void)setLevel:(NSDictionary *)level{
    [[NSUserDefaults standardUserDefaults] setObject:level forKey:SOCDataLevelKey];
}

-(NSDictionary *)semester{
    NSDictionary *semester = [[NSUserDefaults standardUserDefaults] dictionaryForKey:SOCDataSemesterKey];
    
    NSArray *semesters = [RUSOCDataLoadingManager semesters];
    if ([semesters containsObject:semester] || (!semesters && semester)) return semester;
    return semesters[[RUSOCDataLoadingManager defaultSemesterIndex]];
}

-(void)setSemester:(NSDictionary *)semester{
    [[NSUserDefaults standardUserDefaults] setObject:semester forKey:SOCDataSemesterKey];
}

-(NSString *)semesterTag {
    return self.semester[@"tag"];
}
@end

@implementation RUSOCDataLoadingManager (SharedInstance)
+(RUSOCDataLoadingManager *)sharedInstance{
    static RUSOCDataLoadingManager *socData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socData = [[RUSOCSingletonDataLoadingManager alloc] init];
    });
    return socData;
}
@end
