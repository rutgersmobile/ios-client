//
//  RUReaderController.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RUReaderController : UITableViewController
-(id)initWithStyle:(UITableViewStyle)style child:(NSDictionary *)child;
@property (nonatomic) NSDictionary *child;
@end
