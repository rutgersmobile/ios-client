//
//  RUFoodComponent.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RUComponentDelegate.h"

@interface RUFoodComponent : UINavigationController
- (id)initWithDelegate:(id <RUComponentDelegate>)delegate;
@end
