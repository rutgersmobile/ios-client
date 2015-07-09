//
//  RUSOCTest.m
//  Rutgers
//
//  Created by Open Systems Solutions on 7/6/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import "RUTestCase.h"
#import "RUSOCDataLoadingManager.h"
#import "RUSOCSearchIndex.h"
#import "RUSOCSearchOperation.h"

@interface RUSOCTest : RUTestCase

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
    [self waitForExpectationsWithTimeout:0.5 handler:nil];
    XCTAssertNotNil(manager.semester);
    XCTAssertNotNil(manager.semesters);
}

-(void)testLoadingSubjects{
    RUSOCDataLoadingManager *manager = [RUSOCDataLoadingManager sharedInstance];
    XCTestExpectation *expectation = [self expectationWithDescription:@"subjects"];
    [manager getSubjectsWithCompletion:^(NSArray *subjects, NSError *error) {
        XCTAssertNotNil(subjects);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:0.5 handler:nil];
}

-(void)testLoadingSearchIndex{
    RUSOCSearchIndex *searchIndex = [[RUSOCSearchIndex alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"searchIndexDidLoad"];
    [searchIndex performWhenLoaded:^(NSError *error) {
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:0.5 handler:nil];
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
    [self waitForExpectationsWithTimeout:0.5 handler:nil];
}

-(void)performSearchQuery:(NSString *)query onIndex:(RUSOCSearchIndex *)searchIndex{
    XCTestExpectation *searchExpectation = [self expectationWithDescription:@"searchOperationDidFinish"];
    RUSOCSearchOperation *operation = [[RUSOCSearchOperation alloc] initWithQuery:query searchIndex:searchIndex];
    operation.completionBlock = ^{
        [searchExpectation fulfill];
    };
    [operation start];
    [self waitForExpectationsWithTimeout:0.5 handler:nil];
}


@end
