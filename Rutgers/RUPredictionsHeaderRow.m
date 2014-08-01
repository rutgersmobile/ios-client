//
//  RUPredictionsHeaderRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPredictionsHeaderRow.h"
#import "RUBusRoute.h"
#import "NSArray+RUBusStop.h"
#import <HexColor.h>
#import "RUPredictionsHeaderTableViewCell.h"

@interface RUPredictionsHeaderRow ()
@property id item;
@end

@implementation RUPredictionsHeaderRow
-(instancetype)initWithPredictions:(NSDictionary *)predictions forItem:(id)item{
    self = [super initWithIdentifier:@"RUPredictionsHeaderTableViewCell"];
    if (self) {
        self.item = item;
        self.predictions = predictions;
    }
    return self;
}

-(void)setupCell:(RUPredictionsHeaderTableViewCell *)cell{
    cell.titleLabel.text = [self title];
    cell.directionLabel.text = [self.item isKindOfClass:[NSArray class]] ? [self directionTitle] : nil;
    cell.timeLabel.text = [self arrivalTimeDescription];
    if ([self active]) {
        cell.titleLabel.textColor = [UIColor blackColor];
        cell.directionLabel.textColor = [UIColor blackColor];
        cell.timeLabel.textColor = [self timeLabelColor];
    } else {
        cell.titleLabel.textColor = [UIColor grayColor];
        cell.directionLabel.textColor = [UIColor lightGrayColor];
        cell.timeLabel.textColor = [UIColor lightGrayColor];
    }
}

-(BOOL)active{
    return [self.predictions[@"direction"] firstObject] ? YES : NO;
}

-(BOOL)shouldHighlight{
    return self.active;
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
    if (![self active]) return @"No predictions available.";
    NSArray *predictions = [self.predictions[@"direction"] firstObject][@"prediction"];
    NSMutableString *string = [[NSMutableString alloc] init];
    __block NSString *lastMinutes = nil;
    
    [predictions enumerateObjectsUsingBlock:^(NSDictionary *prediction, NSUInteger idx, BOOL *stop) {
        NSString *minutes = prediction[@"_minutes"];
        if ([minutes isEqualToString:@"0"]) minutes = @"<1";
        if ([string isEqualToString:@""]) {
            [string appendFormat:@"Arriving in %@",minutes];
        } else {
            [string appendFormat:@", %@",minutes,nil];
        }
        lastMinutes = minutes;
        if (idx == 2) *stop = YES;
    }];
    
    if ([lastMinutes integerValue] > 1) {
        [string appendString:@" minutes."];
    } else {
        [string appendString:@" minute."];
    }
    return string;
}

-(UIColor *)timeLabelColor{
    NSString *string = [[self.predictions[@"direction"] firstObject][@"prediction"] firstObject][@"_minutes"];
    NSInteger minutes = [string integerValue];
    if (minutes < 2) {
        return [UIColor colorWithHexString:@"#CC0000"];
    } else if (minutes < 6) {
        return [UIColor colorWithHexString:@"#FF6600"];
    } else {
        return [UIColor colorWithHexString:@"#000099"];
    }
}

@end
