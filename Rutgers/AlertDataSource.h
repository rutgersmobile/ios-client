//
//  AlertDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/18/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "StringDataSource.h"


@interface AlertDataSource : StringDataSource
-(instancetype)initWithInitialText:(NSString *)initialText alertButtonTitles:(NSArray *)alertButtonTitles;
@property (nonatomic) NSString *alertTitle;
@property (nonatomic) NSString *text;
@property (nonatomic) BOOL updatesInitialText;
-(void)showAlertInView:(UIView *)view;
@property (nonatomic, copy) void(^alertAction)(NSString *buttonTitle, NSInteger buttonIndex);
@end
