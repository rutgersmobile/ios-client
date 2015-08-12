//
//  RUPredictionsHeaderRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

@class RUPrediction;

@interface RUPredictionsHeaderRow : NSObject
-(instancetype)initWithPredictions:(RUPrediction *)predictions forItem:(id)item NS_DESIGNATED_INITIALIZER;
@property (nonatomic, readonly) id item;
@property (nonatomic, readonly) BOOL active;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *directionTitle;
@property (nonatomic, readonly, copy) NSString *arrivalTimeDescription;
@property (nonatomic, readonly, copy) UIColor *timeLabelColor;
@end
