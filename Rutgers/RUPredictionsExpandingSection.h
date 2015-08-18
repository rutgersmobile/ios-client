//
//  RUPredictionsExpandingRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ExpandingTableViewSection.h"

@class RUBusPrediction;

@interface RUPredictionsExpandingSection : ExpandingTableViewSection
-(instancetype)initWithPredictions:(RUBusPrediction *)predictions forItem:(id)item NS_DESIGNATED_INITIALIZER;
@property (nonatomic) NSString *identifier;
@end
