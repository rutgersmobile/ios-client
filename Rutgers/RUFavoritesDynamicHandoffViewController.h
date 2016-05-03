//
//  RUFavoritesDynamicHandoffViewController.h
//  Rutgers
//
//  Created by Open Systems Solutions on 2/24/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "TableViewController.h"

@interface RUFavoritesDynamicHandoffViewController : TableViewController
-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithHandle:(NSString *)handle pathComponents:(NSArray *)pathComponents title:(NSString *)title;
@end
