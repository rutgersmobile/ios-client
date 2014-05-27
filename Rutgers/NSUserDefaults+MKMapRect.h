//
//  NSUserDefaults+MKMapRect.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface NSUserDefaults (MKMapRect)

//stores a map rect in user defaults
-(void)setMapRect:(MKMapRect)mapRect forKey:(NSString*)key;
//retrieves the stored map rect or returns the world rect if one wasn't previously set.
-(MKMapRect)mapRectForKey:(NSString*)key;

@end
