//
//  RUFavoritesDynamicHandoffViewController.h
//  Rutgers
//
//  Created by Open Systems Solutions on 2/24/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "TableViewController.h"

@interface RUFavoritesDynamicHandoffViewController : TableViewController // Is it a TVC , but what is being displayed ? Is this TVC being added as a section in the slide
-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithHandle:(NSString *)handle pathComponents:(NSArray *)pathComponents title:(NSString *)title;
@end
