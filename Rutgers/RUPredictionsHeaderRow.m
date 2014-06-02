//
//  RUPredictionsHeaderRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPredictionsHeaderRow.h"
#import "RUPredictionsTableViewCell.h"
#import "RUBusRoute.h"
#import "NSString+TimeColor.h"
#import "NSArray+RUBusStop.h"

@interface RUPredictionsHeaderRow ()
@property (nonatomic) id item;
@end

@implementation RUPredictionsHeaderRow
-(instancetype)initWithPredictions:(NSDictionary *)predictions forItem:(id)item{
    self = [super initWithIdentifier:@"RUPredictionsTableViewCell"];
    if (self) {
        self.item = item;
        self.predictions = predictions;
    }
    return self;
}

-(void)setupCell:(RUPredictionsTableViewCell *)cell{
    [cell setTitle:[self title]];
    
    if ([self.item isKindOfClass:[RUBusRoute class]]) {
        [cell setDirection:nil];
    } else {
        [cell setDirection:[self directionTitle]];
    }
    [cell setTime:[self arrivalTimeDescription]];
    [cell setTimeColor:[self timeLabelColor]];
}

-(BOOL)active{
    return [self.predictions[@"direction"] firstObject] ? YES : NO;
}
-(NSString *)title{
    if ([self.item isKindOfClass:[RUBusRoute class]]) {
        return self.predictions[@"_stopTitle"];
    } else {
        return self.predictions[@"_routeTitle"];
    }
}

-(NSString *)directionTitle{
    if ([self.item isKindOfClass:[RUBusRoute class]]) return nil;
    NSString *title = [self.predictions[@"direction"] firstObject][@"_title"];
    if (title) return title;
    return self.predictions[@"_dirTitleBecauseNoPredictions"];
}

-(NSString *)arrivalTimeDescription{
    NSArray *predictions = [self.predictions[@"direction"] firstObject][@"prediction"];
    if (!predictions) return @"No predictions available.";
    NSMutableString *string = [[NSMutableString alloc] init];
    [predictions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *prediction = obj;
        NSString *minutes = prediction[@"_minutes"];
        if ([string isEqualToString:@""]) {
            [string appendString:minutes];
        } else {
            [string appendFormat:@", %@",minutes,nil];
        }
        if (idx == 2) *stop = YES;
    }];
    [string appendString:@" minutes"];
    return string;
}

-(UIColor *)timeLabelColor{
    return [[[self.predictions[@"direction"] firstObject][@"prediction"] firstObject][@"_minutes"] colorForMinutesString];
}
@end
