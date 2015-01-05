//
//  RUPlaceDetailDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ComposedDataSource.h"

@class RUPlace;

@interface RUPlaceDetailDataSource : ComposedDataSource
-(id)initWithPlace:(RUPlace *)place;
-(void)startUpdates;
-(void)stopUpdates;
@end
