//
//  ResponseDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ResponseDataSource.h"
#import "ALTableViewTextFieldCell.h"
#import "ALTableViewToggleCell.h"
#import "DataSource_Private.h"
#import "NSIndexPath+RowExtensions.h"

@interface ResponseDataSource()

@end

@implementation ResponseDataSource
-(NSInteger)numberOfItems{
    return self.on ? 2 : 1;
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[ALTableViewToggleCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewToggleCell class])];
    [tableView registerClass:[ALTableViewTextFieldCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextFieldCell class])];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (indexPath.row == 0) ? NSStringFromClass([ALTableViewToggleCell class]) : NSStringFromClass([ALTableViewTextFieldCell class]);
}

-(void)configureCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        ALTableViewToggleCell *toggleCell = cell;
        toggleCell.textLabel.text = self.toggleLabel;
        [toggleCell.toggleSwitch removeTarget:nil action:nil forControlEvents:UIControlEventValueChanged];
        [toggleCell.toggleSwitch addTarget:self action:@selector(toggleSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    } else {
        ALTableViewTextFieldCell *textFieldCell = cell;
        textFieldCell.textLabel.text = self.textFieldLabel;
        textFieldCell.textField.placeholder = self.textFieldPlaceholder;
    }
}

-(void)toggleSwitchChanged:(UISwitch *)toggleSwitch{
    NSInteger numberOfItems = self.numberOfItems;
    self.on = toggleSwitch.on;
    NSInteger newNumberOfItems = self.numberOfItems;
    
    if (newNumberOfItems > numberOfItems) {
        [self notifyItemsInsertedAtIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(numberOfItems, newNumberOfItems-numberOfItems) inSection:0]];
    } else if (newNumberOfItems < numberOfItems) {
        [self notifyItemsRemovedAtIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(newNumberOfItems, numberOfItems-newNumberOfItems) inSection:0]];
    }
}
@end
