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
    XCTestExpectation *expectation = [self expectationWithDescription:@"loading"];
    [RUSOCDataLoadingManager performWhenSemestersLoaded:^(NSError *error) {
        RUSOCDataLoadingManager *manager = [RUSOCDataLoadingManager sharedInstance];
        XCTAssertNotNil(manager.campus);
        XCTAssertNotNil(manager.level);
        XCTAssertNotNil(manager.semester);
        
        XCTAssertNotNil([RUSOCDataLoadingManager campuses]);
        XCTAssertNotNil([RUSOCDataLoadingManager levels]);
        XCTAssertNotNil([RUSOCDataLoadingManager semesters]);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

-(void)testLoadingSubjectsForAllCombinations{
    XCTestExpectation *expectation = [self expectationWithDescription:@"loading"];
    
    [RUSOCDataLoadingManager performWhenSemestersLoaded:^(NSError *error) {
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];

    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    dispatch_queue_t queue = dispatch_queue_create("results mutation queue", DISPATCH_QUEUE_SERIAL);
    
    for (NSDictionary *campus in [RUSOCDataLoadingManager campuses]) {
        for (NSDictionary *level in [RUSOCDataLoadingManager levels]) {
            for (NSDictionary *semester in [RUSOCDataLoadingManager semesters]) {
                
                RUSOCDataLoadingManager *manager = [[RUSOCDataLoadingManager alloc] init];
                
                manager.semester = semester;
                manager.campus = campus;
                manager.level = level;
                
                NSString *title = [NSString stringWithFormat:@"%@ %@ %@",semester[@"title"],campus[@"title"],level[@"title"]];
                
                XCTestExpectation *expectation = [self expectationWithDescription:@"subjects"];
                
                //usleep(1000*50);
                [manager getSubjectsWithCompletion:^(NSArray *subjects, NSError *error) {
                    
                    NSMutableDictionary *result = [NSMutableDictionary dictionary];
                    if (error) result[@"error"] = error;
                    if (subjects) result[@"subjects"] = subjects;
                    
                    if (subjects.count > 0) {
                        NSDictionary *subject = subjects.firstObject;
                        NSString *code = subject[@"code"];
                        
                        //usleep(1000*50);
                        [manager getCoursesForSubjectCode:code completion:^(NSArray *courses, NSError *error) {
                            dispatch_async(queue, ^{
                                if (error) result[@"courseError"] = error;
                                if (courses) result[@"courses"] = courses;
                                results[title] = result;
                                [expectation fulfill];
                            });
                        }];
                        
                    } else {
                        dispatch_async(queue, ^{
                            results[title] = result;
                            [expectation fulfill];
                        });
                    }
                }];
            }
        }
    }
    
    [self waitForExpectationsWithTimeout:30 handler:nil];
    
    for (NSDictionary *campus in [RUSOCDataLoadingManager campuses]) {
        for (NSDictionary *level in [RUSOCDataLoadingManager levels]) {
            for (NSDictionary *semester in [RUSOCDataLoadingManager semesters]) {
                
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
                            NSAssert(!courseError, @"\t\tError Loading courses for %@", title);
                            if (courseError) NSLog(@"\t\tError %@", courseError.localizedDescription);
                        }
                    }
                } else {
                    if (![campus[@"tag"] isEqualToString:@"ONLINE"]) {
                        NSAssert(false, @"*\tError Loading subjects for %@", title);
                    } else {
                        NSLog(@"*\tError Loading subjects for %@", title);
                    }
                    if (error) NSLog(@"\t\tError %@", error.localizedDescription);
                }
                
            }
        }
    }
}

-(void)testLoadingSearchIndex{
    RUSOCSearchIndex *searchIndex = [[RUSOCSearchIndex alloc] init];
    [self waitForIndexLoad:searchIndex];
    
    assert(searchIndex.ids.count);
    assert(searchIndex.subjects.count);
    assert(searchIndex.courses.count);
    assert(searchIndex.abbreviations.count);
}

-(void)testQuery1{
    RUSOCSearchIndex *searchIndex = [[RUSOCSearchIndex alloc] init];
    
    [self waitForIndexLoad:searchIndex];
    [self measureBlock:^{
        [self performSearchQuery:@"comp sci" onIndex:searchIndex completion:^(RUSOCSearchOperation *operation) {
            assert(operation.subjects.count);
            assert(operation.courses.count);
        }];
    }];
}

-(void)testQuery2{
    RUSOCSearchIndex *searchIndex = [[RUSOCSearchIndex alloc] init];
    [self waitForIndexLoad:searchIndex];
    [self measureBlock:^{
        [self performSearchQuery:@"intro" onIndex:searchIndex completion:^(RUSOCSearchOperation *operation) {
            assert(operation.courses.count);
        }];
    }];
}

-(void)testQuery3{
    RUSOCSearchIndex *searchIndex = [[RUSOCSearchIndex alloc] init];
    [self waitForIndexLoad:searchIndex];
    [self measureBlock:^{
        [self performSearchQuery:@"101" onIndex:searchIndex completion:^(RUSOCSearchOperation *operation) {
            assert(operation.courses.count);
        }];
    }];
}

-(void)waitForIndexLoad:(RUSOCSearchIndex *)searchIndex{
    XCTestExpectation *indexExpectation = [self expectationWithDescription:@"searchIndexDidLoad"];
    [searchIndex performWhenLoaded:^(NSError *error) {
        [indexExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)performSearchQuery:(NSString *)query onIndex:(RUSOCSearchIndex *)searchIndex completion:(void(^)(RUSOCSearchOperation *))completionHandler{
    XCTestExpectation *searchExpectation = [self expectationWithDescription:@"searchOperationDidFinish"];
    RUSOCSearchOperation *operation = [[RUSOCSearchOperation alloc] initWithQuery:query searchIndex:searchIndex];
    __weak typeof(operation) weakOperation = operation;
    operation.completionBlock = ^{
        [searchExpectation fulfill];
        completionHandler(weakOperation);
    };
    [operation start];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}


@end
