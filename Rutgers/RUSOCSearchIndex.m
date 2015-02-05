//
//  RUSOCSearchIndex.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCSearchIndex.h"
#import "RUSOCDataLoadingManager.h"
#import "NSString+WordsInString.h"
#import "NSDictionary+ObjectsForKeys.h"
#import "DataTuple.h"
#import "NSPredicate+SearchPredicate.h"
#import "NSArray+Sort.h"

@interface RUSOCSearchIndex()
@property (nonatomic) NSDictionary *ids;

@property (nonatomic) NSDictionary *subjects;
@property (nonatomic) NSDictionary *courses;

@property (nonatomic) NSDictionary *abbreviations;

@property dispatch_group_t indexGroup;

@property BOOL loading;
@property BOOL finishedLoading;
@property NSError *loadingError;

@end

@implementation RUSOCSearchIndex
-(id)init{
    self = [super init];
    if (self) {
        self.indexGroup = dispatch_group_create();
        [self loadIndex];
    }
    return self;
}

-(void)performWhenIndexLoaded:(void(^)(NSError *error))handler{
    if ([self indexNeedsLoad]) {
        [self loadIndex];
    }
    dispatch_group_notify(self.indexGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        handler(self.loadingError);
    });
}

-(BOOL)indexNeedsLoad{
    return !(self.loading || self.finishedLoading);
}

-(void)loadIndex{
    dispatch_group_enter(self.indexGroup);

    self.loading = YES;
    self.finishedLoading = NO;
    self.loadingError = nil;
    
    [[RUSOCDataLoadingManager sharedInstance] getSearchIndexWithCompletion:^(NSDictionary *index, NSError *error) {
        if (!error) {
            [self parseIndex:index];
            
            self.loading = NO;
            self.finishedLoading = YES;
            self.loadingError = nil;
            
        } else {
            
            self.loading = NO;
            self.finishedLoading = NO;
            self.loadingError = error;
            
        }
        dispatch_group_leave(self.indexGroup);
    }];
}

-(void)parseIndex:(NSDictionary *)index{
    NSMutableDictionary *ids = [NSMutableDictionary dictionary];
   
    [index[@"ids"] enumerateKeysAndObjectsUsingBlock:^(NSString *subjectID, NSDictionary *subjectDict, BOOL *stop) {
      
        NSMutableDictionary *parsedCourses = [NSMutableDictionary dictionary];
        NSString *subjectName = subjectDict[@"name"];

        [subjectDict[@"courses"] enumerateKeysAndObjectsUsingBlock:^(NSString *courseID, NSString *courseName, BOOL *stop) {
            parsedCourses[courseID] = [DataTuple tupleWithTitle:[NSString stringWithFormat:@"%@: %@ (%@:%@)",subjectName,courseName,subjectID,courseID] object:@{@"title" : courseName, @"subjectTitle" : subjectName, @"subjectCode" : subjectID, @"courseNumber" : courseID}];
        }];
        
        ids[subjectID] = [DataTuple tupleWithTitle:[NSString stringWithFormat:@"%@ (%@)",subjectName,subjectID] object:@{@"description" : subjectName, @"code" : subjectID, @"courses" : parsedCourses }];
        
    }];
    
    self.ids = ids;
    self.abbreviations = index[@"abbrevs"];
    self.courses = index[@"courses"];
    self.subjects = index[@"names"];
}

-(void)resultsForQuery:(NSString *)query completion:(void (^)(NSArray *, NSArray *, NSError *))handler{
    [self performWhenIndexLoaded:^(NSError *error) {
        if (error) {
            handler(nil,nil,error);
        } else {
            NSMutableArray *words = [[query wordsInString] mutableCopy];
            
            NSMutableOrderedSet *subjects = [NSMutableOrderedSet orderedSet];
            NSMutableOrderedSet *courses = [NSMutableOrderedSet orderedSet];
            
            if (words.count){
                /// setup
                //try to match first word to subject id
                if ([self stringIsNumericalCode:[words firstObject]]) {
                    DataTuple *subject = [self subjectWithSubjectID:[words firstObject]];
                    if (subject){
                        [words removeObjectAtIndex:0];
                        [subjects addObject:subject];
                    }
                }
                
                NSString *courseID;
                if ([self stringIsNumericalCode:[words lastObject]]) {
                    courseID = [words lastObject];
                    [words removeLastObject];
                } else if ([self stringIsNumericalCode:[words firstObject]]){
                    courseID = [words firstObject];
                    [words removeObjectAtIndex:0];
                }
                
                if (!courseID) {
                    //try to match first word to abbreviation
                    NSArray *subjectsForAbbreviation = [self subjectsWithAbbreviation:[words firstObject]];
                    if (subjectsForAbbreviation.count) {
                        [words removeObjectAtIndex:0];
                        [subjects addObjectsFromArray:subjectsForAbbreviation];
                    }
                }
                
                NSString *query = [words componentsJoinedByString:@" "];
                [subjects addObjectsFromArray:[self subjectsWithQuery:query]];

                /// main body
                if (subjects.count) {
                    if (courseID) {
                        [courses addObjectsFromArray:[self coursesWithCourseID:courseID inSubjects:subjects.array]];
                    } else if (query.length > 1) {
                        [courses addObjectsFromArray:[self coursesWithQuery:query inSubjects:subjects.array]];
                    } else if (subjects.count == 1) {
                        [courses addObjectsFromArray:[self coursesInSubjects:subjects.array]];
                    }
                } else {
                    if (courseID) {
                        if (query.length > 1) {
                            [courses addObjectsFromArray:[self coursesWithCourseID:courseID query:query]];
                        } else {
                            [courses addObjectsFromArray:[self coursesWithCourseID:courseID]];
                        }
                    } else {
                        if (query.length > 1) {
                            [courses addObjectsFromArray:[self coursesWithQuery:query]];
                        }
                    }
                }
            }
            
            handler([subjects.array copy],[courses.array copy],nil);
        }
    }];
}

#pragma mark - code parsing
-(NSNumberFormatter *)numberFormatter{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    return numberFormatter;
}

-(BOOL)stringIsNumericalCode:(NSString *)string{
    if (string.length > 3 || !string.length) return NO;
    
    NSNumber *number = [[self numberFormatter] numberFromString:string];
    if (!number) return NO;
    return YES;
}


-(BOOL)numericalCode:(NSString *)code matchesFullCode:(NSString *)fullCode{
    NSInteger location = [fullCode rangeOfString:code options:NSNumericSearch].location;
    if (location == NSNotFound) return false;
    
    NSInteger sizeDiff = fullCode.length-code.length;
    if (location == 0) return true;
    if (sizeDiff > 0 && [fullCode characterAtIndex:sizeDiff-1] == '0') return true;
    
    return false;
}

#pragma mark - accessors
-(DataTuple *)subjectWithSubjectID:(NSString *)subjectID{
    return self.ids[subjectID];
}

-(NSArray *)subjectsWithSubjectIDs:(NSArray *)subjectIDs{
    NSMutableArray *results = [NSMutableArray array];
    for (NSString *subjectID in subjectIDs) {
        DataTuple *subject = [self subjectWithSubjectID:subjectID];
        if (subject) [results addObject:subject];
    }
    return [results sortByKeyPath:@"description"];
}

-(NSArray *)subjectsWithAbbreviation:(NSString *)abbreviation{
    abbreviation = [abbreviation uppercaseString];
    NSArray *subjectIDs = self.abbreviations[abbreviation];
    return [self subjectsWithSubjectIDs:subjectIDs];
}

#pragma mark - courses
-(NSArray *)coursesInSubjects:(NSArray *)subjects{
    NSMutableArray *courses = [NSMutableArray array];
    for (DataTuple *subject in subjects) {
        [courses addObjectsFromArray:[[subject.object[@"courses"] allValues] sortedArrayUsingComparator:^NSComparisonResult(DataTuple *courseOne, DataTuple *courseTwo) {
            return [courseOne.object[@"courseNumber"] compare:courseTwo.object[@"courseNumber"] options:NSNumericSearch];
        }]];
    }
    return courses;
}

-(NSArray *)coursesWithCourseID:(NSString *)courseID{
    NSMutableArray *results = [NSMutableArray array];
    [self.courses enumerateKeysAndObjectsUsingBlock:^(NSString *courseName, NSDictionary *courseDict, BOOL *stop) {
        if ([self numericalCode:courseID matchesFullCode:courseDict[@"course"]] ) {
            DataTuple *subject = [self subjectWithSubjectID:courseDict[@"subj"]];
            DataTuple *course = subject.object[@"courses"][courseDict[@"course"]];
            if (course) [results addObject:course];
        }
    }];
    return [results sortedArrayUsingComparator:^NSComparisonResult(DataTuple *courseOne, DataTuple *courseTwo) {
        NSComparisonResult result = [courseOne[@"subjectTitle"] compare:courseTwo[@"subjectTitle"] options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch|NSNumericSearch];
        if (result != NSOrderedSame) return result;
        return [courseOne.object[@"courseNumber"] compare:courseTwo.object[@"courseNumber"] options:NSNumericSearch];
    }];
}

-(NSArray *)coursesWithCourseID:(NSString *)numericalCode inSubject:(DataTuple *)subject{
    NSMutableArray *results = [NSMutableArray array];
    [subject.object[@"courses"] enumerateKeysAndObjectsUsingBlock:^(NSString *courseID, DataTuple *course, BOOL *stop) {
        if ([self numericalCode:numericalCode matchesFullCode:courseID]) {
            [results addObject:course];
        }
    }];
    
    return [results sortedArrayUsingComparator:^NSComparisonResult(DataTuple *courseOne, DataTuple *courseTwo) {
        return [courseOne.object[@"courseNumber"] compare:courseTwo.object[@"courseNumber"] options:NSNumericSearch];
    }];
}

-(NSArray *)coursesWithCourseID:(NSString *)numericalCode inSubjects:(NSArray *)subjects{
    NSMutableArray *results = [NSMutableArray array];
    for (DataTuple *subject in subjects) {
        [results addObjectsFromArray:[self coursesWithCourseID:numericalCode inSubject:subject]];
    }
    return results;
}

#pragma mark - searches
-(NSArray *)coursesWithQuery:(NSString *)query{
    NSPredicate *predicate = [NSPredicate predicateForQuery:query keyPath:@"self"];
    NSMutableArray *results = [NSMutableArray array];
    [self.courses enumerateKeysAndObjectsUsingBlock:^(NSString *courseName, NSDictionary *courseDict, BOOL *stop) {
        DataTuple *subject = [self subjectWithSubjectID:courseDict[@"subj"]];
        DataTuple *course = subject.object[@"courses"][courseDict[@"course"]];
        if ([predicate evaluateWithObject:course.title]) {
            [results addObject:course];
        }
    }];
    return [results sortByKeyPath:@"title"];
}

-(NSArray *)coursesWithCourseID:(NSString *)numericalCode query:(NSString *)query{
    NSPredicate *predicate = [NSPredicate predicateForQuery:query keyPath:@"self"];
    NSMutableArray *results = [NSMutableArray array];
    [self.courses enumerateKeysAndObjectsUsingBlock:^(NSString *courseName, NSDictionary *courseDict, BOOL *stop) {
        DataTuple *subject = [self subjectWithSubjectID:courseDict[@"subj"]];
        DataTuple *course = subject.object[@"courses"][courseDict[@"course"]];
        if ([predicate evaluateWithObject:course.title] && [self numericalCode:numericalCode matchesFullCode:courseDict[@"course"]]) {
            [results addObject:course];
        }
    }];
    return [results sortByKeyPath:@"title"];
}

-(NSArray *)coursesWithQuery:(NSString *)query inSubject:(DataTuple *)subject{
    NSPredicate *predicate = [NSPredicate predicateForQuery:query keyPath:@"self"];
    NSMutableArray *results = [NSMutableArray array];
    [subject.object[@"courses"] enumerateKeysAndObjectsUsingBlock:^(NSString *courseID, DataTuple *course, BOOL *stop) {
        if ([predicate evaluateWithObject:course[@"title"]]) {
            [results addObject:course];
        }
    }];
    
    return [results sortedArrayUsingComparator:^NSComparisonResult(DataTuple *courseOne, DataTuple *courseTwo) {
        NSComparisonResult result = [courseOne.object[@"courseNumber"] compare:courseTwo.object[@"courseNumber"] options:NSNumericSearch];
        return result;
    }];
}

-(NSArray *)coursesWithQuery:(NSString *)query inSubjects:(NSArray *)subjects{
    NSMutableArray *results = [NSMutableArray array];
    for (DataTuple *subject in subjects) {
        [results addObjectsFromArray:[self coursesWithQuery:query inSubject:subject]];
    }
    return results;
}

-(NSArray *)subjectsWithQuery:(NSString *)query{
    NSPredicate *predicate = [NSPredicate predicateForQuery:query keyPath:@"self"];
    NSMutableArray *results = [NSMutableArray array];
    [self.subjects enumerateKeysAndObjectsUsingBlock:^(NSString *subjectName, NSString *subjectID, BOOL *stop) {
        if ([predicate evaluateWithObject:subjectName]) {
            DataTuple *subject = [self subjectWithSubjectID:subjectID];
            if (subject) [results addObject:subject];
        }
    }];
    return [results sortByKeyPath:@"description"];
}

@end
