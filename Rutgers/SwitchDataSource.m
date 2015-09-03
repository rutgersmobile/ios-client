
//
//  SwitchDataSource.m
//  Rutgers
//
//  Created by OSS on 9/3/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import "SwitchDataSource.h"
#import "ALTableViewToggleCell.h"
#import "DataSource_Private.h"

@implementation SwitchDataSource
-(NSInteger)numberOfItems{
    return 1;
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[ALTableViewToggleCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewToggleCell class])];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([ALTableViewToggleCell class]);
}

-(void)configureCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    ALTableViewToggleCell *switchCell = cell;
    
    switchCell.textLabel.text = self.textLabelText;
    
    [switchCell.toggleSwitch removeTarget:nil action:nil forControlEvents:UIControlEventValueChanged];
    [switchCell.toggleSwitch addTarget:self action:@selector(toggleSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    switchCell.toggleSwitch.on = self.isOn;
}

-(void)toggleSwitchChanged:(UISwitch *)toggleSwitch{
    self.on = toggleSwitch.on;
}

-(void)resetContent{
    [super resetContent];
    self.on = NO;
    [self notifySectionsRefreshed:[NSIndexSet indexSetWithIndex:0]];
}

@end
