//
//  RUWebComponent.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUWebDelegate.h"

@interface RUWebComponent : UINavigationController
- (id) initWithURL:(NSURL *)url delegate: (id <RUWebDelegate>) delegate;

@end
