//
//  ExpandingTableViewDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ComposedDataSource.h"

@interface ExpandingTableViewDataSource : ComposedDataSource
@property (nonatomic) NSArray *sections;
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end
