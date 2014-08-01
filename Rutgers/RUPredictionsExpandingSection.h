//
//  RUPredictionsExpandingRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ExpandingTableViewSection.h"

@interface RUPredictionsExpandingSection : ExpandingTableViewSection
-(instancetype)initWithPredictions:(NSDictionary *)predictions forItem:(id)item;
@property (nonatomic) NSString *identifier;
@end
