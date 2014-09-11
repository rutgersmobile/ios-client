//
//  UITableView+ClearSelection.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (Selection)
-(void)clearSelectionAnimated:(BOOL)animated;
-(void)selectRowsAtIndexPaths:(NSArray *)indexPaths animated:(BOOL)animated;
@end
