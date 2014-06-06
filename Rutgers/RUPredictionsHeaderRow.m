//
//  RUPredictionsHeaderRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPredictionsHeaderRow.h"
#import "RUBusRoute.h"
#import "NSString+TimeColor.h"
#import "NSArray+RUBusStop.h"

@interface RUPredictionsHeaderRow ()
@property (nonatomic) id item;
@end

@implementation RUPredictionsHeaderRow
-(instancetype)initWithPredictions:(NSDictionary *)predictions forItem:(id)item{
    self = [super init];
    if (self) {
        self.item = item;
        self.predictions = predictions;
    }
    return self;
}
-(void)setPredictions:(NSDictionary *)predictions{
    _predictions = predictions;
    NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:@"\n"];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    
    [string appendAttributedString:[self attributedTitle]];
    [string appendAttributedString:newLine];
    
    
    if ([self.item isKindOfClass:[NSArray class]]) {
        [string appendAttributedString:[self attributedDirectionTitle]];
        [string appendAttributedString:newLine];
    }
    
    [string appendAttributedString:[self attributedArrivalTimeDescription]];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineSpacing:1.0];
    
    [string addAttributes:@{NSParagraphStyleAttributeName : paragraphStyle} range:NSMakeRange(0, string.length)];
    
    self.attributedText = string;
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
-(NSAttributedString *)attributedTitle{
    return [[NSAttributedString alloc] initWithString:[self title] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:19]}];
}
-(NSString *)directionTitle{
    if ([self.item isKindOfClass:[RUBusRoute class]]) return nil;
    NSString *title = [self.predictions[@"direction"] firstObject][@"_title"];
    if (title) return title;
    return self.predictions[@"_dirTitleBecauseNoPredictions"];
}
-(NSAttributedString *)attributedDirectionTitle{
    return [[NSAttributedString alloc] initWithString:[self directionTitle] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}];
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
-(NSAttributedString *)attributedArrivalTimeDescription{
    return [[NSAttributedString alloc] initWithString:[self arrivalTimeDescription] attributes:@{NSForegroundColorAttributeName: [self timeLabelColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}];
}
-(UIColor *)timeLabelColor{
    return [[[self.predictions[@"direction"] firstObject][@"prediction"] firstObject][@"_minutes"] colorForMinutesString];
}
@end
