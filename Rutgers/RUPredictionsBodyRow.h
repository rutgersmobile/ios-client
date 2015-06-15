//
//  RUPredictionsExtraRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

@interface RUPredictionsBodyRow : NSObject
-(instancetype)initWithPredictionTimes:(NSArray *)predictionTimes NS_DESIGNATED_INITIALIZER;
@property (nonatomic, readonly) NSString *minutesString;
@property (nonatomic, readonly) NSString *descriptionString;
@property (nonatomic, readonly) NSString *timeString;
@end
