//
//  RUBusTest.m
//  Rutgers
//
//  Created by Open Systems Solutions on 10/28/15.
//  Copyright © 2015 Rutgers. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RUBusDataLoadingManager.h"

@interface RUBusTest : XCTestCase

@end

@implementation RUBusTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAgencyConfig {
    for (NSString *agency in @[newBrunswickAgency, newarkAgency]) {
        XCTestExpectation *expectation = [self expectationWithDescription:@""];
        
    }
    //[[RUBusDataLoadingManager sharedInstance] ]
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
