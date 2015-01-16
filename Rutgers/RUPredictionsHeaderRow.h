//
//  RUPredictionsHeaderRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

@interface RUPredictionsHeaderRow : NSObject
-(instancetype)initWithPredictions:(NSDictionary *)predictions forItem:(id)item;
-(id)item;
-(BOOL)active;
-(NSString *)title;
-(NSString *)directionTitle;
-(NSString *)arrivalTimeDescription;
-(UIColor *)timeLabelColor;
@end
