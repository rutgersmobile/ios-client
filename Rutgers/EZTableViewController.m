//
//  EZTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewController.h"
#import "EZDataSource.h"
#import "EZDataSourceSection.h"
#import "DataSource_Private.h"

@interface EZTableViewController () <DataSourceDelegate>
@property (nonatomic) NSMutableArray *searchResultSections;
@property (nonatomic) BOOL searchEnabled;
@end

@implementation EZTableViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.searchResultSections = [NSMutableArray array];
        self.dataSource = [[EZDataSource alloc] init];
        self.dataSource.delegate = self;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
}

@end
