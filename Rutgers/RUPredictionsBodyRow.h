//
//  RUPredictionsExtraRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RUBusPrediction;

@interface RUPredictionsBodyRow : NSObject
-(instancetype)initWithPredictions:(RUBusPrediction *)predictions;
@property (nonatomic, readonly) NSString *minutesString;
@property (nonatomic, readonly) NSString *descriptionString;
@property (nonatomic, readonly) NSString *timeString;
@end
