//
//  FAQSectionDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/31/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ExpandingTableViewSection.h"

/**
 This class models a single question and answer in the FAQDataSource
 */
@interface FAQSectionDataSource : ExpandingTableViewSection
-(instancetype)initWithItem:(NSDictionary *)item NS_DESIGNATED_INITIALIZER;
@end
