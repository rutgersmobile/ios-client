//
//  RUDrillDownTest.m
//  Rutgers
//
//  Created by Open Systems Solutions on 7/7/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUTestCase.h"

#import "RUChannelManager.h"
#import "TableViewController.h"

@interface RUDrillDownTest : RUTestCase <UINavigationControllerDelegate>
@property XCTestExpectation *navigationExpectation;
@end

@implementation RUDrillDownTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testChannelManager{
    RUChannelManager *channelManager = [RUChannelManager sharedInstance];
    NSArray *channels = channelManager.allChannels;
    XCTAssertGreaterThan(channels.count, 0);
    for (NSDictionary *channel in channels) {
        XCTAssertNoThrow([channelManager viewControllerForChannel:channel]);
    }
}

- (void)testChannels{
    RUChannelManager *channelManager = [RUChannelManager sharedInstance];
    NSArray *channels = channelManager.allChannels;
    for (NSDictionary *channel in channels) {
        UIViewController *vc = [channelManager viewControllerForChannel:channel];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
        navController.delegate = self;
        [self visitChildren:vc];
    }
}

-(void)visitChildren:(UIViewController *)viewController{
    XCTAssert(viewController.navigationController);
    if ([viewController isKindOfClass:[TableViewController class]]) {
        [self visitChildrenOfTableView:(TableViewController *)viewController];
    } else {
        
    }
}

-(void)visitChildrenOfTableView:(TableViewController *)tableViewController{
    [self waitForTableViewLoad:tableViewController];
    DataSource *dataSource = tableViewController.dataSource;
    NSInteger stackPos = [tableViewController.navigationController.viewControllers indexOfObject:tableViewController];
    for (NSInteger section = 0; section < dataSource.numberOfSections; section++) {
        for (NSInteger row = 0; row < [dataSource numberOfItemsInSection:section]; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [tableViewController tableView:tableViewController.tableView didSelectRowAtIndexPath:indexPath];
            [self visitChildren:tableViewController.navigationController.viewControllers[stackPos+1]];
        }
    }
}

-(void)waitForTableViewLoad:(TableViewController *)tableViewController{
    XCTestExpectation *expectation = [self expectationWithDescription:tableViewController.title];
    tableViewController.view;
    [tableViewController.dataSource setNeedsLoadContent];
    [tableViewController.dataSource whenLoaded:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:0.8 handler:nil];
}

-(void)waitForNavigation{
    self.navigationExpectation = [self expectationWithDescription:@"Navigation"];
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [self.navigationExpectation fulfill];
}


@end
