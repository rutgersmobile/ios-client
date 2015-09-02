//
//  text.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUChannelProtocol.h"

@interface RUTextViewController : UIViewController <RUChannelProtocol>
@property (nonatomic) UITextView *textView;
@end
