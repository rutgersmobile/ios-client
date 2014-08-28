//
//  RUFeedbackDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUFeedbackDataSource.h"
#import "AlertDataSource.h"
#import "ResponseDataSource.h"
#import "ComposedDataSource_Private.h"
#import "RUChannelManager.h"
#import "ButtonDataSource.h"

@interface RUFeedbackDataSource ()
@property (nonatomic) AlertDataSource *channelSelectionDataSource;
@property (nonatomic) NSArray *channels;

@property (nonatomic) NSString *feedbackCategory;
@property (nonatomic) NSString *channel;
@property (nonatomic) NSString *email;
@property (nonatomic) BOOL wantsResponse;

@end

@implementation RUFeedbackDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        AlertDataSource *feedbackDataSource = [[AlertDataSource alloc] initWithPlaceholderText:@"Select a feedback subject..." alertButtonTitles:@[
                                                                                                                                                   @"General Questions",
                                                                                                                                                   @"Help Using Application",
                                                                                                                                                   @"App Feature Request",
                                                                                                                                                   @"Report a Bug",
                                                                                                                                                   @"App Channel Feedback"
                                                                                                                                                   ]];
        
        feedbackDataSource.alertTitle = @"Please select a subject:";
        feedbackDataSource.alertAction = ^(NSString *buttonTitle, NSInteger buttonIndex) {
            self.feedbackCategory = buttonTitle;
            [self setChannelSelectorStateEnabled:[buttonTitle isEqualToString:@"App Channel Feedback"]];
        };
        [self addDataSource:feedbackDataSource];

        self.channels = [RUChannelManager sharedInstance].allChannels;
        
        NSMutableArray *channelTitles = [NSMutableArray array];
        for (NSDictionary *channel in self.channels) {
            [channelTitles addObject:[channel channelTitle]];
        }
        
        AlertDataSource *channelSelectionDataSource = [[AlertDataSource alloc] initWithPlaceholderText:@"Select a channel..." alertButtonTitles:channelTitles];
        
        feedbackDataSource.alertTitle = @"Please select a subject:";
        feedbackDataSource.alertAction = ^(NSString *buttonTitle, NSInteger buttonIndex) {
            self.channel = buttonTitle;
            [self setChannelSelectorStateEnabled:[buttonTitle isEqualToString:@"App Channel Feedback"]];
        };
        
        self.channelSelectionDataSource = channelSelectionDataSource;
        
        ResponseDataSource *toggleDataSource = [[ResponseDataSource alloc] init];
        toggleDataSource.toggleLabel = @"Want a response?";
        toggleDataSource.textFieldLabel = @"Email:";
        toggleDataSource.textFieldPlaceholder = @"netID@rutgers.edu";
        
        [self addDataSource:toggleDataSource];
        
        
        ButtonDataSource *nextButtonDataSource = [[ButtonDataSource alloc] initWithTitle:@"Next"];
        [self addDataSource:nextButtonDataSource];
    }
    return self;
}

-(void)validateForm{
    
}

-(void)setChannelSelectorStateEnabled:(BOOL)enabled{
    if (enabled && ![self.dataSources containsObject:self.channelSelectionDataSource]) {
        [self insertDataSource:self.channelSelectionDataSource atIndex:1];
    } else if (!enabled && [self.dataSources containsObject:self.channelSelectionDataSource]) {
        [self removeDataSource:self.channelSelectionDataSource];
    }
}
@end
