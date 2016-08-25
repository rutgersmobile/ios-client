//
//  NSDictionary+DiningHall.m
//  Rutgers
//
//  Created by Open Systems Solutions on 6/23/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import "NSDictionary+DiningHall.h"
#import "NSString+WordsInString.h"

@implementation NSDictionary (DiningHall)

-(BOOL)isDiningHallOpen{
    NSArray *meals = self[@"meals"];
    for (NSDictionary *meal in meals) {
        if ([meal[@"meal_avail"] boolValue]) return YES;
    }
    return NO;
}


-(NSString *)diningHallShortName{
    return [self[@"location_name"] wordsInString].firstObject;
}
@end
