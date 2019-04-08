//
//  FAQDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/31/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ExpandingTableViewDataSource.h"
#import "TTTAttributedLabel.h"

@interface FAQDataSource : ExpandingTableViewDataSource
-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithChannel:(NSDictionary *)channel NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithChannel:(NSDictionary *)channel linkDelegate: TTTAttributedLabelDelegate;
@end
