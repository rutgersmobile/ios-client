//
//  RUSOCOptionsViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/10/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "TableViewController.h"

@class RUSOCOptionsViewController;

@protocol RUSOCOptionsDelegate <NSObject>

-(void)optionsViewControllerDidChangeOptions:(RUSOCOptionsViewController *)optionsViewController;

@end


@interface RUSOCOptionsViewController : TableViewController
-(instancetype)initWithDelegate:(id<RUSOCOptionsDelegate>)delegate;
@end
