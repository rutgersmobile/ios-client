//
//  RUMapsViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/8/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUComponentProtocol.h"

@interface RUMapsViewController : UIViewController <RUComponentProtocol>

+(instancetype)component;
@end
