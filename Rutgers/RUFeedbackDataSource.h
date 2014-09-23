//
//  RUFeedbackDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ComposedDataSource.h"
#import "FeedbackDataSourceDelegate.h"

@interface RUFeedbackDataSource : ComposedDataSource
@property (weak) id<FeedbackDataSourceDelegate> feedbackDelegate;
-(BOOL)validateForm;
-(void)send;
@end
