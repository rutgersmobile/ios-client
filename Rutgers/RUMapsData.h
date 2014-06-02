//
//  RUMapsData.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/8/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface RUMapsData : NSObject
+(RUMapsData *)sharedInstance;
@property NSCache *cache;
@end
