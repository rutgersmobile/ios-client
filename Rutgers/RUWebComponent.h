//
//  RUWebComponent.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUComponentDelegate.h"

@interface RUWebComponent : UINavigationController
- (id) initWithURL:(NSURL *)url title:(NSString *)title delegate: (id <RUComponentDelegate>) delegate;

@end
