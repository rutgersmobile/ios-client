//
//  RUPlacesComponent.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUComponentDelegate.h"

@interface RUPlacesComponent : UINavigationController
- (id) initWithDelegate: (id <RUComponentDelegate>) delegate;

@end
