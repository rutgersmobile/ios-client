//
//  RUPredictionsExtraRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

@interface RUPredictionsBodyRow : NSObject
-(instancetype)initWithPredictionTimes:(NSArray *)predictionTimes;
-(NSString *)minutesString;
-(NSString *)descriptionString;
-(NSString *)timeString;
@end
