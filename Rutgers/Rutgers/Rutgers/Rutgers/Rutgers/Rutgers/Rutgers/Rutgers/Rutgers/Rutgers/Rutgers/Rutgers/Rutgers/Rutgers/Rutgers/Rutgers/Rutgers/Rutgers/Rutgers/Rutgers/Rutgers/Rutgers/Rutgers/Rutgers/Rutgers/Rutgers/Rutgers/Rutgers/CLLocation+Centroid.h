//
//  CLLocation+Centroid.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/13/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (Centroid)
+(CLLocation *)centroidOfLocations:(NSArray *)locations;
@end
