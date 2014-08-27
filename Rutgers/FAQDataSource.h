//
//  FAQDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/31/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ExpandingTableViewDataSource.h"

@interface FAQDataSource : ExpandingTableViewDataSource
-(instancetype)initWithChannel:(NSDictionary *)channel;
@end
