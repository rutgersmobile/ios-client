//
//  RUEditChannelsViewController.h
//  Rutgers
//
//  Created by scm on 5/26/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChannelsDataSource.h"
#import "TableViewController.h"
#import "RUMenuMultipleDataSource.h"

/*
    This class will function as the data source and delegate of the table view
    
    Create a simpler solution  , so for now ignoring Kyle 's Apple Example concept
  
 */

#warning  TO DO : Implement using the TableViewController Super Class

@interface RUEditChannelsViewController : UITableViewController <UITableViewDataSource>


@property (weak) id dataSource; // pointer to the Menu Multiple Data Source
/*
    We do not use this data souce directly , we 
 
 */

@end
