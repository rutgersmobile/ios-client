//
//  UITableView+ClearSelection.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "UITableView+Selection.h"

@implementation UITableView (Selection)
-(void)clearSelectionAnimated:(BOOL)animated{
    NSArray *indexPaths = [self indexPathsForSelectedRows];
    for (NSIndexPath *indexPath in indexPaths) {
        [self deselectRowAtIndexPath:indexPath animated:animated];
    }
}
-(void)selectRowsAtIndexPaths:(NSArray *)indexPaths animated:(BOOL)animated{
    for (NSIndexPath *indexPath in indexPaths) {
        [self selectRowAtIndexPath:indexPath animated:animated scrollPosition:UITableViewScrollPositionNone];
    }
}
@end
