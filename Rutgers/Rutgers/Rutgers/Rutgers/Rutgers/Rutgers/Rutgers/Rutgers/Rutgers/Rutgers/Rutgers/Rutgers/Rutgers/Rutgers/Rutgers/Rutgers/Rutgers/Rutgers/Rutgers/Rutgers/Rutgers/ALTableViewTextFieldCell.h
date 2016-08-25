//
//  ALTableViewTextViewCell.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ALTableViewAbstractCell.h"

@interface ALTableViewTextFieldCell : ALTableViewAbstractCell
@property (nonatomic) UITextField *textField;
-(UILabel *)textLabel;
@end
