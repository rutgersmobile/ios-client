//
//  TableViewController.m
//  RUThereYet?
//
//  Created by Kyle Bailey on 7/1/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import "TableViewController_Private.h"
#import "DataSource.h"

@implementation TableViewController 

-(void)setDataSource:(DataSource *)dataSource{
    if ([_dataSource isEqual:dataSource]) return;
    
    _dataSource.delegate = nil;
    _dataSource = dataSource;
    dataSource.delegate = self;
    
    self.tableView.dataSource = dataSource;
    [self.tableView reloadData];
}

-(UITableViewRowAnimation)rowAnimationForSectionOperationDirection:(DataSourceSectionOperationDirection)direction{
    switch (direction) {
        case DataSourceSectionOperationDirectionNone:
            return UITableViewRowAnimationAutomatic;
            break;
        case DataSourceSectionOperationDirectionLeft:
            return UITableViewRowAnimationLeft;
            break;
        case DataSourceSectionOperationDirectionRight:
            return UITableViewRowAnimationRight;
            break;
    }
}

-(void)dataSource:(DataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)insertedIndexPaths{
    [self.tableView insertRowsAtIndexPaths:insertedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
}

-(void)dataSource:(DataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)removedIndexPaths{
    [self.tableView deleteRowsAtIndexPaths:removedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
}

-(void)dataSource:(DataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)refreshedIndexPaths{
    [self.tableView reloadRowsAtIndexPaths:refreshedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
}

-(void)dataSource:(DataSource *)dataSource didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath{
    [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}


-(void)dataSource:(DataSource *)dataSource didRefreshSections:(NSIndexSet *)sections direction:(DataSourceSectionOperationDirection)direction{
    [self.tableView reloadSections:sections withRowAnimation:[self rowAnimationForSectionOperationDirection:direction]];
}

-(void)dataSource:(DataSource *)dataSource didInsertSections:(NSIndexSet *)sections direction:(DataSourceSectionOperationDirection)direction{
    [self.tableView insertSections:sections withRowAnimation:[self rowAnimationForSectionOperationDirection:direction]];
}

-(void)dataSource:(DataSource *)dataSource didRemoveSections:(NSIndexSet *)sections direction:(DataSourceSectionOperationDirection)direction{
    [self.tableView deleteSections:sections withRowAnimation:[self rowAnimationForSectionOperationDirection:direction]];
}


-(void)dataSourceDidReloadData:(DataSource *)dataSource{
    [self.tableView reloadData];
}

-(void)dataSource:(DataSource *)dataSource performBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete{
    [self.tableView beginUpdates];
    if (update) {
        update();
    }
    [self.tableView endUpdates];
    
    if (complete) {
        complete();
    }
}

-(void)dataSourceWillLoadContent:(DataSource *)dataSource{
    
}

-(void)dataSource:(DataSource *)dataSource contentLoadedWithError:(NSError *)error{
    
}

@end
