//
//  RUSOCSearchIndexOperation.m
//  Rutgers
//
//  Created by Open Systems Solutions on 6/9/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import "RUSOCSearchOperation.h"
#import "DataTuple.h"
#import "NSString+WordsInString.h"
#import "NSDictionary+ObjectsForKeys.h"
#import "NSPredicate+SearchPredicate.h"
#import "NSArray+Sort.h"

@interface RUSOCSearchOperation ()
@property (nonatomic) NSString *query;
@property (nonatomic) RUSOCSearchIndex *searchIndex;
@end

@implementation RUSOCSearchOperation
-(instancetype)initWithQuery:(NSString *)query searchIndex:(RUSOCSearchIndex *)searchIndex{
    self = [super init];
    if (self) {
        self.query = query;
        self.searchIndex = searchIndex;
    }
    return self;
}

-(void)main{
    
    NSMutableArray *words = [[self.query wordsInString] mutableCopy];
    
    NSMutableOrderedSet *subjects = [NSMutableOrderedSet orderedSet];
    NSMutableOrderedSet *courses = [NSMutableOrderedSet orderedSet];
    
    if (words.count){
        
        NSArray *subjectsForAbbreviation = [self subjectsWithAbbreviation:[words firstObject]];
        if (subjectsForAbbreviation.count) {
            [words removeObjectAtIndex:0];
            [subjects addObjectsFromArray:subjectsForAbbreviation];
        }
        
        for (NSString *word in [words copy]) {
            if ([self stringIsNumericalCode:word]) {
                DataTuple *subject = [self subjectWithSubjectID:word];
                if (subject){
                    [words removeObject:word];
                    [subjects addObject:subject];
                }
            }
        }
        
        NSString *courseID;
        for (NSString *word in [words copy]) {
            if ([self stringIsNumericalCode:word]) {
                courseID = word;
                [words removeObject:word];
                break;
            }
        }
        
        if (self.cancelled) return;
        
        /// main body
        NSString *query = [words componentsJoinedByString:@" "];
        [subjects addObjectsFromArray:[self subjectsWithQuery:query]];
        
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
    
    _subjects = subjects.array;
    _courses = courses.array;
}

#pragma mark - code parsing
-(NSNumberFormatter *)numberFormatter{
    static NSNumberFormatter *numberFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        numberFormatter = [[NSNumberFormatter alloc] init];
    });
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
    return self.searchIndex.ids[subjectID];
}

-(NSArray *)subjectsWithSubjectIDs:(NSArray *)subjectIDs{
    NSMutableArray *results = [NSMutableArray array];
    for (NSString *subjectID in subjectIDs) {
        if (self.cancelled) return nil;
        DataTuple *subject = [self subjectWithSubjectID:subjectID];
        if (subject) [results addObject:subject];
    }
    return [results sortByKeyPath:@"description"];
}

-(NSArray *)subjectsWithAbbreviation:(NSString *)abbreviation{
    abbreviation = [abbreviation uppercaseString];
    NSArray *subjectIDs = self.searchIndex.abbreviations[abbreviation];
    return [self subjectsWithSubjectIDs:subjectIDs];
}

#pragma mark - courses
-(NSArray *)coursesInSubjects:(NSArray *)subjects{
    NSMutableArray *courses = [NSMutableArray array];
    for (DataTuple *subject in subjects) {
        if (self.cancelled) return nil;
        [courses addObjectsFromArray:[[subject.object[@"courses"] allValues] sortedArrayUsingComparator:^NSComparisonResult(DataTuple *courseOne, DataTuple *courseTwo) {
            return [courseOne.object[@"courseNumber"] compare:courseTwo.object[@"courseNumber"] options:NSNumericSearch];
        }]];
    }
    return courses;
}

-(NSArray *)coursesWithCourseID:(NSString *)courseID{
    NSMutableArray *results = [NSMutableArray array];
    [self.searchIndex.courses enumerateKeysAndObjectsUsingBlock:^(NSString *courseName, NSDictionary *courseDict, BOOL *stop) {
        if (self.cancelled) *stop = YES;
        if ([self numericalCode:courseID matchesFullCode:courseDict[@"course"]] ) {
            DataTuple *subject = [self subjectWithSubjectID:courseDict[@"subj"]];
            DataTuple *course = subject.object[@"courses"][courseDict[@"course"]];
            if (course) [results addObject:course];
        }
    }];
    if (self.cancelled) return nil;
    return [results sortedArrayUsingComparator:^NSComparisonResult(DataTuple *courseOne, DataTuple *courseTwo) {
        NSComparisonResult result = [courseOne[@"subjectTitle"] compare:courseTwo[@"subjectTitle"] options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch|NSNumericSearch];
        if (result != NSOrderedSame) return result;
        return [courseOne.object[@"courseNumber"] compare:courseTwo.object[@"courseNumber"] options:NSNumericSearch];
    }];
}

-(NSArray *)coursesWithCourseID:(NSString *)numericalCode inSubject:(DataTuple *)subject{
    NSMutableArray *results = [NSMutableArray array];
    [subject.object[@"courses"] enumerateKeysAndObjectsUsingBlock:^(NSString *courseID, DataTuple *course, BOOL *stop) {
        if (self.cancelled) *stop = YES;
        if ([self numericalCode:numericalCode matchesFullCode:courseID]) {
            [results addObject:course];
        }
    }];
    if (self.cancelled) return nil;
    return [results sortedArrayUsingComparator:^NSComparisonResult(DataTuple *courseOne, DataTuple *courseTwo) {
        return [courseOne.object[@"courseNumber"] compare:courseTwo.object[@"courseNumber"] options:NSNumericSearch];
    }];
}

-(NSArray *)coursesWithCourseID:(NSString *)numericalCode inSubjects:(NSArray *)subjects{
    NSMutableArray *results = [NSMutableArray array];
    for (DataTuple *subject in subjects) {
        if (self.cancelled) return nil;
        [results addObjectsFromArray:[self coursesWithCourseID:numericalCode inSubject:subject]];
    }
    return results;
}

#pragma mark - searches
-(NSArray *)coursesWithQuery:(NSString *)query{
    NSPredicate *predicate = [NSPredicate predicateForQuery:query keyPath:@"self"];
    NSMutableArray *results = [NSMutableArray array];
    [self.searchIndex.courses enumerateKeysAndObjectsUsingBlock:^(NSString *courseName, NSDictionary *courseDict, BOOL *stop) {
        if (self.cancelled) *stop = YES;
        DataTuple *subject = [self subjectWithSubjectID:courseDict[@"subj"]];
        DataTuple *course = subject.object[@"courses"][courseDict[@"course"]];
        if ([predicate evaluateWithObject:course.title]) {
            [results addObject:course];
        }
    }];
    if (self.cancelled) return nil;
    return [results sortByKeyPath:@"title"];
}

-(NSArray *)coursesWithCourseID:(NSString *)numericalCode query:(NSString *)query{
    NSPredicate *predicate = [NSPredicate predicateForQuery:query keyPath:@"self"];
    NSMutableArray *results = [NSMutableArray array];
    [self.searchIndex.courses enumerateKeysAndObjectsUsingBlock:^(NSString *courseName, NSDictionary *courseDict, BOOL *stop) {
        if (self.cancelled) *stop = YES;
        DataTuple *subject = [self subjectWithSubjectID:courseDict[@"subj"]];
        DataTuple *course = subject.object[@"courses"][courseDict[@"course"]];
        if ([predicate evaluateWithObject:course.title] && [self numericalCode:numericalCode matchesFullCode:courseDict[@"course"]]) {
            [results addObject:course];
        }
    }];
    if (self.cancelled) return nil;
    return [results sortByKeyPath:@"title"];
}

-(NSArray *)coursesWithQuery:(NSString *)query inSubject:(DataTuple *)subject{
    NSPredicate *predicate = [NSPredicate predicateForQuery:query keyPath:@"self"];
    NSMutableArray *results = [NSMutableArray array];
    [subject.object[@"courses"] enumerateKeysAndObjectsUsingBlock:^(NSString *courseID, DataTuple *course, BOOL *stop) {
        if (self.cancelled) *stop = YES;
        if ([predicate evaluateWithObject:course[@"title"]]) {
            [results addObject:course];
        }
    }];
    if (self.cancelled) return nil;
    return [results sortedArrayUsingComparator:^NSComparisonResult(DataTuple *courseOne, DataTuple *courseTwo) {
        NSComparisonResult result = [courseOne.object[@"courseNumber"] compare:courseTwo.object[@"courseNumber"] options:NSNumericSearch];
        return result;
    }];
}

-(NSArray *)coursesWithQuery:(NSString *)query inSubjects:(NSArray *)subjects{
    NSMutableArray *results = [NSMutableArray array];
    for (DataTuple *subject in subjects) {
        if (self.cancelled) return nil;
        [results addObjectsFromArray:[self coursesWithQuery:query inSubject:subject]];
    }
    return results;
}

-(NSArray *)subjectsWithQuery:(NSString *)query{
    NSPredicate *predicate = [NSPredicate predicateForQuery:query keyPath:@"self"];
    NSMutableArray *results = [NSMutableArray array];
    [self.searchIndex.subjects enumerateKeysAndObjectsUsingBlock:^(NSString *subjectName, NSString *subjectID, BOOL *stop) {
        if (self.cancelled) *stop = YES;
        if ([predicate evaluateWithObject:subjectName]) {
            DataTuple *subject = [self subjectWithSubjectID:subjectID];
            if (subject) [results addObject:subject];
        }
    }];
    if (self.cancelled) return nil;
    return [results sortByKeyPath:@"description"];
}

@end
