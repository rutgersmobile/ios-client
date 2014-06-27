//
//  RUEmergencyViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ColoredTileCollectionViewController.h"

@interface RUEmergencyViewController : ColoredTileCollectionViewController
+(instancetype)componentForChannel:(NSDictionary *)channel;
@end
