//
//  RUNewsComponent.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUNewsDelegate.h"

@interface RUNewsComponent : UINavigationController
- (id) initWithDelegate: (id <RUNewsDelegate>) delegate;

@end
