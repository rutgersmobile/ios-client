//
//  RUPredictionsHeaderRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewRow.h"

@interface RUPredictionsHeaderRow : EZTableViewRow
-(instancetype)initWithPredictions:(NSDictionary *)predictions forItem:(id)item;
@property (nonatomic) NSDictionary *predictions;
-(BOOL)active;
@end
