//
//  RUSOCTest.m
//  Rutgers
//
//  Created by Open Systems Solutions on 7/6/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RUSOCDataLoadingManager.h"
#import "RUSOCSearchIndex.h"
#import "RUSOCSearchOperation.h"

@interface RUSOCTest : XCTestCase

@end

@implementation RUSOCTest

-(void)testPreferences{
    RUSOCDataLoadingManager *manager = [RUSOCDataLoadingManager sharedInstance];
    XCTAssertNotNil(manager.campus);
    XCTAssertNotNil(manager.level);
    
    XCTAssertNotNil(manager.campuses);
    XCTAssertNotNil(manager.levels);
}

-(void)testLoadingSemesterIndex{
    RUSOCDataLoadingManager *manager = [RUSOCDataLoadingManager sharedInstance];
    XCTestExpectation *expectation = [self expectationWithDescription:@"semesterIndex"];
    [manager performWhenLoaded:^(NSError *error) {
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
    XCTAssertNotNil(manager.semester);
    XCTAssertNotNil(manager.semesters);
}

-(void)applyForEachCombination:(void(^)(NSDictionary *campus, NSDictionary *level, NSDictionary *semester))function{
    RUSOCDataLoadingManager *manager = [RUSOCDataLoadingManager sharedInstance];

    for (NSDictionary *campus in manager.campuses) {
        for (NSDictionary *level in manager.levels) {
            for (NSDictionary *semester in manager.semesters) {
                
                manager.semester = semester;
                manager.campus = campus;
                manager.level = level;
                
                function(campus,level,semester);
                
                usleep(1000*40);
            }
        }
    }
}

-(void)testLoadingSubjectsForAllCombinations{
    RUSOCDataLoadingManager *manager = [RUSOCDataLoadingManager sharedInstance];

    XCTestExpectation *expectation = [self expectationWithDescription:@"semesterIndexLoad"];
    [manager performWhenLoaded:^(NSError *error) {
        XCTAssertNil(error, @"Error loading semester index file");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    dispatch_queue_t queue = dispatch_queue_create("results mutation queue", DISPATCH_QUEUE_SERIAL);
    
    [self applyForEachCombination:^(NSDictionary *campus, NSDictionary *level, NSDictionary *semester) {
        XCTestExpectation *expectation = [self expectationWithDescription:@"subjects"];
        
        NSString *title = [NSString stringWithFormat:@"%@ %@ %@",semester[@"title"],campus[@"title"],level[@"title"]];
        
        [manager getSubjectsWithCompletion:^(NSArray *subjects, NSError *error) {
            dispatch_async(queue, ^{
                NSMutableDictionary *result = [NSMutableDictionary dictionary];
                if (error) result[@"error"] = error;
                if (subjects) result[@"subjects"] = subjects;
                results[title] = result;
                [expectation fulfill];
            });
        }];
        
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:nil];
    
    
    [self applyForEachCombination:^(NSDictionary *campus, NSDictionary *level, NSDictionary *semester) {
        NSString *title = [NSString stringWithFormat:@"%@ %@ %@",semester[@"title"],campus[@"title"],level[@"title"]];
        
        NSMutableDictionary *result = results[title];
        
        NSArray *subjects = result[@"subjects"];
        
        if (subjects.count > 0) {
            NSDictionary *subject = subjects.firstObject;
            NSString *code = subject[@"code"];
            
            XCTestExpectation *expectation = [self expectationWithDescription:@"subjects"];

            [manager getCoursesForSubjectCode:code completion:^(NSArray *courses, NSError *error) {
                dispatch_async(queue, ^{
                    if (error) result[@"courseError"] = error;
                    if (courses) result[@"courses"] = subjects;
                    [expectation fulfill];
                });
            }];
            
            usleep(1000*30);
        }
        
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:nil];

    [self applyForEachCombination:^(NSDictionary *campus, NSDictionary *level, NSDictionary *semester) {
        NSString *title = [NSString stringWithFormat:@"%@ %@ %@",semester[@"title"],campus[@"title"],level[@"title"]];
        
        NSDictionary *result = results[title];
        
        NSArray *subjects = result[@"subjects"];
        NSError *error = result[@"error"];
        
        if (subjects) {
            if (subjects.count == 0) {
                NSLog(@"*\tNo subjects for %@", title);
            } else {
                NSLog(@"*\tSuccessful loading subjects for %@", title);
                
                NSArray *courses = result[@"courses"];
                NSError *courseError = result[@"courseError"];
                
                if (courses) {
                    if (subjects.count == 0) {
                        NSLog(@"\t\tNo courses for %@", title);
                    } else {
                        NSLog(@"\t\tSuccessful loading courses for %@", title);
                    }
                } else {
                    NSLog(@"\t\tError Loading courses for %@", title);
                    assert(!courseError && ![campus[@"tag"] isEqualToString:@"ONLINE"]);
                    if (courseError) NSLog(@"\t\tError %@", courseError.localizedDescription);
                }
            }
        } else {
            NSLog(@"*\tError Loading subjects for %@", title);
            if (error) NSLog(@"\t\tError %@", error.localizedDescription);
        }
    }];

}

/*
-(void)testLoadingSubjects{
    RUSOCDataLoadingManager *manager = [RUSOCDataLoadingManager sharedInstance];
    XCTestExpectation *expectation = [self expectationWithDescription:@"subjects"];
    [manager getSubjectsWithCompletion:^(NSArray *subjects, NSError *error) {
        XCTAssertNotNil(subjects);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:0.5 handler:nil];
}*/

-(void)testLoadingSearchIndex{
    RUSOCSearchIndex *searchIndex = [[RUSOCSearchIndex alloc] init];
    [self waitForIndexLoad:searchIndex];
}

-(void)testQuery1{
    RUSOCSearchIndex *searchIndex = [[RUSOCSearchIndex alloc] init];
    
    [self waitForIndexLoad:searchIndex];
    [self measureBlock:^{
        [self performSearchQuery:@"comp sci" onIndex:searchIndex];
    }];
}

-(void)testQuery2{
    RUSOCSearchIndex *searchIndex = [[RUSOCSearchIndex alloc] init];
    [self waitForIndexLoad:searchIndex];
    [self measureBlock:^{
        [self performSearchQuery:@"intro" onIndex:searchIndex];
    }];
}

-(void)testQuery3{
    RUSOCSearchIndex *searchIndex = [[RUSOCSearchIndex alloc] init];
    [self waitForIndexLoad:searchIndex];
    [self measureBlock:^{
        [self performSearchQuery:@"intro" onIndex:searchIndex];
    }];
}

-(void)waitForIndexLoad:(RUSOCSearchIndex *)searchIndex{
    XCTestExpectation *indexExpectation = [self expectationWithDescription:@"searchIndexDidLoad"];
    [searchIndex performWhenLoaded:^(NSError *error) {
        [indexExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)performSearchQuery:(NSString *)query onIndex:(RUSOCSearchIndex *)searchIndex{
    XCTestExpectation *searchExpectation = [self expectationWithDescription:@"searchOperationDidFinish"];
    RUSOCSearchOperation *operation = [[RUSOCSearchOperation alloc] initWithQuery:query searchIndex:searchIndex];
    operation.completionBlock = ^{
        [searchExpectation fulfill];
    };
    [operation start];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}


@end
