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
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    [d setObject:[NSNumber numberWithDouble:mapRect.origin.x] forKey:@"x"];
    [d setObject:[NSNumber numberWithDouble:mapRect.origin.y] forKey:@"y"];
    [d setObject:[NSNumber numberWithDouble:mapRect.size.width] forKey:@"width"];
    [d setObject:[NSNumber numberWithDouble:mapRect.size.height] forKey:@"height"];
    
    [self setObject:d forKey:key];
}

-(MKMapRect)mapRectForKey:(NSString*)key{
    NSDictionary *d = [self dictionaryForKey:key];
    if(!d){
        return MKMapRectWorld;
    }
    return MKMapRectMake([[d objectForKey:@"x"] doubleValue],
                         [[d objectForKey:@"y"] doubleValue],
                         [[d objectForKey:@"width"] doubleValue],
                         [[d objectForKey:@"height"] doubleValue]);
}

@end