//
//  RUFeedbackDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUFeedbackDataSource.h"
#import "AlertDataSource.h"
#import "TextFieldDataSource.h"
#import "ComposedDataSource_Private.h"
#import "RUChannelManager.h"
#import "TextViewDataSource.h"

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
        AlertDataSource *feedbackDataSource = [[AlertDataSource alloc] initWithInitialText:@"Select a feedback subject..." alertButtonTitles:@[
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
        
        AlertDataSource *channelSelectionDataSource = [[AlertDataSource alloc] initWithInitialText:@"Select a channel..." alertButtonTitles:channelTitles];
        
        feedbackDataSource.alertTitle = @"Please select a subject:";
        feedbackDataSource.alertAction = ^(NSString *buttonTitle, NSInteger buttonIndex) {
            self.channel = buttonTitle;
            [self setChannelSelectorStateEnabled:[buttonTitle isEqualToString:@"App Channel Feedback"]];
        };
        
        self.channelSelectionDataSource = channelSelectionDataSource;
        
        TextFieldDataSource *toggleDataSource = [[TextFieldDataSource alloc] init];
        toggleDataSource.textFieldLabel = @"Email:";
        toggleDataSource.textFieldPlaceholder = @"optional";
        
        [self addDataSource:toggleDataSource];
        
        TextViewDataSource *messageDataSource = [[TextViewDataSource alloc] init];
        messageDataSource.title = @"Enter your feedback message below:";
        [self addDataSource:messageDataSource];
        
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
