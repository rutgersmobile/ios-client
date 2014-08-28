//
//  RUPredictionsHeaderRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewTextRow.h"

@interface RUPredictionsHeaderRow : EZTableViewAbstractRow
-(instancetype)initWithPredictions:(NSDictionary *)predictions forItem:(id)item;
-(BOOL)active;
@end
