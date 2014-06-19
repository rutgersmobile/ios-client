//
//  RUSportsPlayer.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/13/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSportsPlayer.h"

@implementation RUSportsPlayer

-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [self init];
    if (self) {
        self.name = [[dictionary[@"fullName"] firstObject] stringByReplacingOccurrencesOfString:@"  " withString:@" "];
        self.initials = [self initialsFromName:self.name];
        NSString *imageURLString = [dictionary[@"image"] firstObject];
        if ([imageURLString rangeOfString:@"blockr.jpg"].location == NSNotFound) {
            self.imageUrl = [NSURL URLWithString:imageURLString];
        }
        self.jerseyNumber = [dictionary[@"jerseyNumber"] firstObject];
        self.physique = [dictionary[@"physique"] firstObject];
        self.position = [dictionary[@"position"] firstObject];
        self.hometown = [dictionary[@"fullName"] firstObject];
        
    }
    return self;
}

-(NSString *)initialsFromName:(NSString *)name{
    NSArray *nameComponents = [name componentsSeparatedByString:@" "];
    
    NSString *firstName = [nameComponents firstObject];
    NSString *lastName = [nameComponents lastObject];
    
    NSString *firstInitial = [firstName substringToIndex:1];
    NSString *lastInitial = [lastName substringToIndex:1];
    
    return [NSString stringWithFormat:@"%@%@",firstInitial,lastInitial];
}

@end
