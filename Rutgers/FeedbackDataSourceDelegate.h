//
//  FeedbackDataSourceDelegate.h
//  Rutgers
//
//  Created by Kyle Bailey on 9/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FeedbackDataSourceDelegate <NSObject>
-(void)formDidChange;
-(void)formSendFailed;
-(void)formSendSucceeded;
-(void)showRUInfo;
@end
