//
//  RUSOCOptionsViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/10/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCOptionsViewController.h"
#import "RUSOCDataLoadingManager.h"
#import "AlertDataSource.h"
#import "ComposedDataSource.h"

@interface RUSOCOptionsViewController ()
@property id<RUSOCOptionsDelegate> delegate;
@end

@implementation RUSOCOptionsViewController

- (instancetype)initWithDelegate:(id<RUSOCOptionsDelegate>)delegate
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Options";
        self.delegate = delegate;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    RUSOCDataLoadingManager *dataManager = [RUSOCDataLoadingManager sharedInstance];
    
    __weak typeof(self) weakSelf = self;
    
    NSArray *semesters = [RUSOCDataLoadingManager semesters];
    AlertDataSource *semesterDataSource = [[AlertDataSource alloc] initWithInitialText:dataManager.semester[@"title"] alertButtonTitles:[semesters valueForKey:@"title"]];
    semesterDataSource.title = @"Semester";
    semesterDataSource.alertAction = ^(NSString *buttonTitle, NSInteger buttonIndex){
        dataManager.semester = semesters[buttonIndex];
        [weakSelf notifyOptionsDidChange];
    };
    
    NSArray *campuses = [RUSOCDataLoadingManager campuses];
    AlertDataSource *campusDataSource = [[AlertDataSource alloc] initWithInitialText:dataManager.campus[@"title"] alertButtonTitles:[campuses valueForKey:@"title"]];
    campusDataSource.title = @"Campus";
    campusDataSource.alertAction = ^(NSString *buttonTitle, NSInteger buttonIndex){
        dataManager.campus = campuses[buttonIndex];
        [weakSelf notifyOptionsDidChange];
    };
    
    NSArray *levels = [RUSOCDataLoadingManager levels];
    AlertDataSource *levelDataSource = [[AlertDataSource alloc] initWithInitialText:dataManager.level[@"title"] alertButtonTitles:[levels valueForKey:@"title"]];
    levelDataSource.title = @"Level";
    levelDataSource.alertAction = ^(NSString *buttonTitle, NSInteger buttonIndex){
        dataManager.level = levels[buttonIndex];
        [weakSelf notifyOptionsDidChange];
    };
    
    ComposedDataSource *dataSource = [[ComposedDataSource alloc] init];
    [dataSource addDataSource:semesterDataSource];
    [dataSource addDataSource:campusDataSource];
    [dataSource addDataSource:levelDataSource];
    
    self.dataSource = dataSource;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ComposedDataSource *dataSouce = (ComposedDataSource *)self.dataSource;
    AlertDataSource *alertDataSource = (AlertDataSource *)[dataSouce dataSourceAtIndex:indexPath.section];
    [alertDataSource showAlertInView:tableView];
}

-(void)notifyOptionsDidChange{
    [self.delegate optionsViewControllerDidChangeOptions:self];
}


@end
