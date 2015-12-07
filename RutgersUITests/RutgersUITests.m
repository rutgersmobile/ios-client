//
//  RutgersUITests.m
//  RutgersUITests
//
//  Created by Open Systems Solutions on 10/28/15.
//  Copyright © 2015 Rutgers. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RURootController.h"

@interface RutgersUITests : XCTestCase

@end

@implementation RutgersUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBus {
    
    //Open app to bus channel
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElementQuery *tablesQuery = app.tables;
    
    [tablesQuery.staticTexts[@"Bus"] tap];
    
    //Change to routes tab
    XCUIElementQuery *toolbarsQuery = app.toolbars;
    [toolbarsQuery.buttons[@"Routes"] tap];
    
    //Tap on a
    [tablesQuery.staticTexts[@"A"] tap];
    
    //Double tap on scott hall
    XCUIElement *scottHallStaticText = tablesQuery.staticTexts[@"Scott Hall"];
    [scottHallStaticText tap];
    [scottHallStaticText tap];
    
    //Go back to root
    [app.navigationBars[@"A"].buttons[@"Bus"] tap];
    
    //Change to stops tab
    [toolbarsQuery.buttons[@"Stops"] tap];
    
    //Tap on arc
    [tablesQuery.staticTexts[@"Allison Road Classrooms"] tap];
    
    //Double tap on c
    XCUIElement *cStaticText = tablesQuery.staticTexts[@"C"];
    [cStaticText tap];
    [cStaticText tap];
    
    //Go back
    [app.navigationBars[@"Allison Road Classrooms"].buttons[@"Bus"] tap];
    
    //Change to all tab
    [toolbarsQuery.buttons[@"All"] tap];
    
    //Tap on all campuses
    [tablesQuery.staticTexts[@"All Campuses"] tap];
    
    //Double tap on scott hall
    [scottHallStaticText tap];
    [scottHallStaticText tap];
    
    //Go back
    [app.navigationBars[@"All Campuses"].buttons[@"Bus"] tap];
    
    [toolbarsQuery.buttons[@"Routes"] tap];
    
    //Search for red oak lane
    [tablesQuery.searchFields[@"Search All Routes and Stops"] tap];
    [app.searchFields[@"Search All Routes and Stops"] typeText:@"red"];
    
    //tap on results
    [app.tables[@"Search results"].staticTexts[@"Red Oak Lane"] tap];
    
    //Go back and cancel the search
    [app.navigationBars[@"Red Oak Lane"].buttons[@"Bus"] tap];
    [app.buttons[@"Cancel"] tap];
    
}

-(void)testPlaces{
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElementQuery *tablesQuery = app.tables;
    
    [tablesQuery.staticTexts[@"Places"] tap];
    
    [tablesQuery.searchFields[@"Search All Places"] tap];
    [app.searchFields[@"Search All Places"] typeText:@"hill"];
    
    [app.tables[@"Search results"].staticTexts[@"Hill Center Bldg for the Mathematical Sciences"] tap];
    
    [[tablesQuery.cells elementBoundByIndex:0] pressForDuration:0.9];
    [app.menuItems[@"Copy"] tap];
    
    [app.navigationBars[@"Hill Center Bldg for the Mathematical Sciences"].buttons[@"Back"] tap];
    [app.buttons[@"Cancel"] tap];
}

-(void)testScarletKnights{
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElementQuery *tablesQuery = app.tables;
    
    [tablesQuery.staticTexts[@"Scarlet Knights"] tap];
    [tablesQuery.staticTexts[@"Athletics Schedules"] tap];
    
    [tablesQuery.staticTexts[@"Basketball - Men"] tap];
    
    [[[[app.navigationBars[@"Basketball - Men"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
    [app.navigationBars[@"Athletics Schedules"].buttons[@"Scarlet Knights"] tap];
    [tablesQuery.staticTexts[@"Directions"] tap];
    
    XCUIElement *stadiumAddressStaticText = tablesQuery.staticTexts[@"Stadium Address"];
    [stadiumAddressStaticText tap];
    [stadiumAddressStaticText tap];
    
    XCUIElement *gardenStateParkwaySouthboundStaticText = tablesQuery.staticTexts[@"Garden State Parkway Southbound"];
    [gardenStateParkwaySouthboundStaticText tap];
    [gardenStateParkwaySouthboundStaticText tap];
    
    [app.navigationBars[@"Directions"].buttons[@"Scarlet Knights"] tap];
    [[[[[app.windows containingType:XCUIElementTypeImage identifier:@"bg"] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element.tables.staticTexts[@"News"] tap];
    [tablesQuery.staticTexts[@"Baseball"] tap];
    
    [app.navigationBars[@"Baseball"].buttons[@"News"] tap];
    [app.navigationBars[@"News"].buttons[@"Scarlet Knights"] tap];
    
    [tablesQuery.staticTexts[@"Rutgers Bag Policy"] tap];
    [app.navigationBars[@"Rutgers Bag Policy"].buttons[@"Scarlet Knights"] tap];
    
    [tablesQuery.staticTexts[@"Stadium Parking Lots"] tap];
    XCUIElement *stadiumLotsStaticText = tablesQuery.staticTexts[@"Stadium Lots"];
    [stadiumLotsStaticText tap];
    [stadiumLotsStaticText tap];
    
    XCUIElement *gameDayCashParkingLotsStaticText = tablesQuery.staticTexts[@"Game Day Cash Parking Lots"];
    [gameDayCashParkingLotsStaticText tap];
    [gameDayCashParkingLotsStaticText tap];
    
    [[[[app.navigationBars[@"Stadium Parking Lots"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
    [tablesQuery.staticTexts[@"Parking FAQ"] tap];
    
    XCUIElement *iHaveAParkingPassWhatDoINeedToKnowStaticText = tablesQuery.staticTexts[@"I have a parking pass, what do I need to know?"];
    [iHaveAParkingPassWhatDoINeedToKnowStaticText tap];
    [iHaveAParkingPassWhatDoINeedToKnowStaticText tap];
    
    XCUIElement *iDoNotHaveAParkingPassWhereCanIParkStaticText = tablesQuery.staticTexts[@"I do not have a parking pass. Where can I park?"];
    [iDoNotHaveAParkingPassWhereCanIParkStaticText tap];
    [iDoNotHaveAParkingPassWhereCanIParkStaticText tap];
    [app.navigationBars[@"Parking FAQ"].buttons[@"Scarlet Knights"] tap];

}

-(void)testScheduleOfClasses{
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElementQuery *tablesQuery = app.tables;
    [tablesQuery.staticTexts[@"Schedule of Classes"] tap];
    [tablesQuery.staticTexts[@"Accounting (010)"] tap];
    [tablesQuery.staticTexts[@"272: Intro Financial Acct"] tap];
    [app.navigationBars[@"Intro Financial Acct"].buttons[@"010: Accounting"] tap];
    [app.navigationBars[@"010: Accounting"].buttons[@"Fall 2015 NB U"] tap];
    
    XCUIElement *searchSubjectsAndCoursesSearchField = app.searchFields[@"Search Subjects and Courses"];
    [searchSubjectsAndCoursesSearchField tap];
    [searchSubjectsAndCoursesSearchField typeText:@"compu"];
    [app.tables[@"Search results"].staticTexts[@"Computer Science (198)"] tap];
    [[[[app.navigationBars[@"198: Computer Science"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
    [app.tables[@"Search results"].staticTexts[@"Electrical and Compu. (332)"] tap];
    [[[[app.navigationBars[@"332: Electrical And Compu."] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
    [app.tables[@"Search results"].staticTexts[@"Computer Science: Intro Computer Sci (198:111)"] tap];
    [[[[app.navigationBars[@"Intro Computer Sci"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];

}

@end
