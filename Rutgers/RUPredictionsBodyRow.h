//
//  RUPredictionsExtraRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RUBusPrediction;

/**
 The predictions body row models how 
 */
@interface RUPredictionsBodyRow : NSObject
-(instancetype)initWithPredictions:(RUBusPrediction *)predictions;
@property (nonatomic) RUBusPrediction* predictionsSaved;
@property (nonatomic) NSString *stop;
@property (nonatomic) NSArray *predictionTimes;
@property (nonatomic) NSString *busTimeString;
@property (nonatomic) NSString *minutesString;
@property (nonatomic) NSString *descriptionString;
@property (nonatomic) NSString *timeString;
@property (nonatomic) NSArray *vehicleArray;
@end
