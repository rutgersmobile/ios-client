//
//  NSUserDefaults+MKMapRect.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSUserDefaults+MKMapRect.h"

@implementation NSUserDefaults (MKMapRect)

-(void)setMapRect:(MKMapRect)mapRect forKey:(NSString*)key{
    [self setObject:@{
                      @"x" : @(mapRect.origin.x),
                      @"y" : @(mapRect.origin.y),
                      @"width" : @(mapRect.size.width),
                      @"height" : @(mapRect.size.height)
                      } forKey:key];
}

-(MKMapRect)mapRectForKey:(NSString*)key{
    NSDictionary *d = [self dictionaryForKey:key];
    if(!d){
        return MKMapRectWorld;
    }
    return MKMapRectMake([d[@"x"] doubleValue],
                         [d[@"y"] doubleValue],
                         [d[@"width"] doubleValue],
                         [d[@"height"] doubleValue]);
}

@end