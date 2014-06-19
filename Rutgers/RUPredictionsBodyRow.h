//
//  RUPredictionsExtraRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewTextRow.h"

@interface RUPredictionsBodyRow : EZTableViewTextRow
-(instancetype)initWithPredictionTimes:(NSArray *)predictionTimes;
@property NSArray *predictionTimes;
@end
