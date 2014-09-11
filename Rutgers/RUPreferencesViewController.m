//
//  RUPreferencesViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPreferencesViewController.h"
#import "PreferencesDataSource.h"
#import "AlertDataSource.h"
#import "TableViewController_Private.h"

@interface RUPreferencesViewController ()

@end

@implementation RUPreferencesViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource = [[PreferencesDataSource alloc] init];
    self.title = @"Preferences";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DataSource *dataSource = [(ComposedDataSource *)self.dataSource dataSourceAtIndex:indexPath.section];
    
    if ([dataSource isKindOfClass:[AlertDataSource class]]) {
        AlertDataSource *alertDataSource = (AlertDataSource *)dataSource;
        [alertDataSource showAlert];
    }
}

@end
