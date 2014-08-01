//
//  RUPredictionsExtraRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewTextRow.h"

@interface RUPredictionsBodyRow : EZTableViewAbstractRow
-(instancetype)initWithPredictionTimes:(NSArray *)predictionTimes;
@property (nonatomic) NSArray *predictionTimes;
@end
