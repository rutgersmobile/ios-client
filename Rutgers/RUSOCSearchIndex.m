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

@property dispatch_group_t loadingGroup;
@end

@implementation RUSOCSearchIndex
-(id)init{
    self = [super init];
    if (self) {
        self.loadingGroup = dispatch_group_create();
        
        dispatch_group_enter(self.loadingGroup);
        [[RUSOCDataLoadingManager sharedInstance] getSearchIndexWithSuccess:^(NSDictionary *index) {
            [self parseIndex:index];
            dispatch_group_leave(self.loadingGroup);
        } failure:^(NSError *error) {
            dispatch_group_leave(self.loadingGroup);
        }];
    }
    return self;
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

-(void)resultsForQuery:(NSString *)query completion:(void (^)(NSArray *, NSArray *))handler{
    dispatch_group_notify(self.loadingGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *words = [[query wordsInString] mutableCopy];
        
        NSMutableOrderedSet *subjects = [NSMutableOrderedSet orderedSet];
        NSMutableOrderedSet *courses = [NSMutableOrderedSet orderedSet];

        if (words.count){
            
            //try to match first word to subject id
            NSString *subjectID;
            if ([self stringIsNumericalCode:[words firstObject]]) {
                DataTuple *subject = [self subjectWithSubjectID:[words firstObject]];
                if (subject){
                    subjectID = [words firstObject];
                    [words removeObjectAtIndex:0];
                    [subjects addObject:subject];
                }
            } else {
                //try to match first word to abbreviation
                [subjects addObjectsFromArray:[self subjectsWithAbbreviation:[words firstObject]]];
            }
            
            NSString *courseID;
            if ([self stringIsNumericalCode:[words lastObject]]) {
                courseID = [words lastObject];
                [words removeLastObject];
            }
            
            NSString *newQuery = [words componentsJoinedByString:@" "];
          
            if (!subjectID && newQuery.length > 1) [subjects addObjectsFromArray:[self subjectsWithQuery:newQuery]];
            
            if (courseID) {
                
                [courses addObjectsFromArray:[self coursesInSubjects:subjects.array withCourseID:courseID]];
                
                if (subjectID) {
                    //[courses addObjectsFromArray:[self coursesInSubjects:newQuery withQuery:courseID]];
                } else {
                    [courses addObjectsFromArray:[self coursesWithQuery:newQuery courseID:courseID]];
                }
                //[subjects removeAllObjects];
            } else {
                if (!subjectID) [courses addObjectsFromArray:[self coursesWithQuery:newQuery]];
            }
        }

        handler([subjects.array copy],[courses.array copy]);
    });
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
    NSNumberFormatter *numberFormatter = [self numberFormatter];
    
    NSNumber *fullNumber = [numberFormatter numberFromString:fullCode];
    NSNumber *number = [numberFormatter numberFromString:code];
    
    return ([[numberFormatter stringFromNumber:fullNumber] rangeOfString:[numberFormatter stringFromNumber:number]].location == 0);
}

#pragma mark - primitives
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

#pragma mark - numerical course codes
-(NSArray *)coursesInSubject:(DataTuple *)subject withCourseID:(NSString *)numericalCode{
    NSMutableArray *results = [NSMutableArray array];
    [subject.object[@"courses"] enumerateKeysAndObjectsUsingBlock:^(NSString *courseID, DataTuple *course, BOOL *stop) {
        if ([self numericalCode:numericalCode matchesFullCode:courseID]) {
            [results addObject:course];
        }
    }];
    
    return [results sortedArrayUsingComparator:^NSComparisonResult(DataTuple *courseOne, DataTuple *courseTwo) {
        NSComparisonResult result = [courseOne.object[@"courseNumber"] compare:courseTwo.object[@"courseNumber"] options:NSNumericSearch];
        return result;
    }];
}

-(NSArray *)coursesInSubjects:(NSArray *)subjects withCourseID:(NSString *)numericalCode{
    NSMutableArray *results = [NSMutableArray array];
    for (DataTuple *subject in subjects) {
        [results addObjectsFromArray:[self coursesInSubject:subject withCourseID:numericalCode]];
    }
    return results;
}

#pragma mark - abbreviation
-(NSArray *)subjectsWithAbbreviation:(NSString *)abbreviation{
    abbreviation = [abbreviation uppercaseString];
    NSArray *subjectIDs = self.abbreviations[abbreviation];
    return [self subjectsWithSubjectIDs:subjectIDs];
}

#pragma mark - searches
-(NSArray *)coursesWithQuery:(NSString *)query{
    NSPredicate *predicate = [NSPredicate predicateForQuery:query keyPath:@"self"];
    NSMutableArray *results = [NSMutableArray array];
    [self.courses enumerateKeysAndObjectsUsingBlock:^(NSString *courseName, NSDictionary *courseDict, BOOL *stop) {
        if ([predicate evaluateWithObject:courseName]) {
            DataTuple *subject = [self subjectWithSubjectID:courseDict[@"subj"]];
            DataTuple *course = subject.object[@"courses"][courseDict[@"course"]];
            if (course) [results addObject:course];
        }
    }];
    return [results sortByKeyPath:@"title"];
}
-(NSArray *)coursesWithQuery:(NSString *)query courseID:(NSString *)courseID{
    NSPredicate *predicate = [NSPredicate predicateForQuery:query keyPath:@"self"];
    NSMutableArray *results = [NSMutableArray array];
    [self.courses enumerateKeysAndObjectsUsingBlock:^(NSString *courseName, NSDictionary *courseDict, BOOL *stop) {
        if ([predicate evaluateWithObject:courseName] && [self numericalCode:courseID matchesFullCode:courseDict[@"course"]] ) {
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
    return [results sortByKeyPath:@"title"];
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
