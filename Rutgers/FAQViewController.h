//
//  FAQViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/20/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ExpandingTableViewController.h"

/**
 This view controller shows faq style question answer information
 */
@interface FAQViewController : ExpandingTableViewController <RUChannelProtocol>
-(instancetype)initWithChannel:(NSDictionary *)channel;
@end
