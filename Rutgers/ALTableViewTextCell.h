//
//  ALTableViewTextCell.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/4/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ALTableViewAbstractCell.h"
#import "TTTAttributedLabel.h"
#import <Rutgers-Swift.h>

@interface ALTableViewTextCell: ALTableViewAbstractCell
-(TTTAttributedLabel *)label;
@end
