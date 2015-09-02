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
@property (nonatomic) AlertDataSource *subjectDataSource;
@property (nonatomic) AlertDataSource *channelDataSource;

@property (nonatomic) TextFieldDataSource *emailDataSource;
@property (nonatomic) TextViewDataSource *messageDataSource;

@property (nonatomic) NSArray *channels;

@property (nonatomic) BOOL channelSelectorStateEnabled;
@property (nonatomic) BOOL subjectSelected;
@property (nonatomic) BOOL channelSelected;
@end

@implementation RUFeedbackDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        //first selector
        __weak typeof(self) weakSelf = self;
        self.subjectDataSource = [[AlertDataSource alloc] initWithInitialText:@"Select a feedback subject..." alertButtonTitles:@[
                                @"General Questions",
                                @"Help Using Application",
                                @"App Feature Request",
                                @"Report a Bug",
                                @"App Channel Feedback"
                                ]];
        
        self.subjectDataSource.alertTitle = @"Please select a subject:";
        self.subjectDataSource.alertAction = ^(NSString *buttonTitle, NSInteger buttonIndex) {
            weakSelf.subjectSelected = YES;
            [weakSelf setChannelSelectorStateEnabled:[buttonTitle isEqualToString:@"App Channel Feedback"]];
            [weakSelf notifyUpdate];
        };
        [self addDataSource:self.subjectDataSource];

        //second selector
        self.channels = [RUChannelManager sharedInstance].allChannels;
        
        NSMutableArray *channelTitles = [NSMutableArray array];
        for (NSDictionary *channel in self.channels) {
            [channelTitles addObject:[channel channelTitle]];
        }
        
        self.channelDataSource = [[AlertDataSource alloc] initWithInitialText:@"Select a channel..." alertButtonTitles:channelTitles];
        
        self.channelDataSource.alertAction = ^(NSString *buttonTitle, NSInteger buttonIndex) {
            weakSelf.channelSelected = YES;
            [weakSelf notifyUpdate];
        };
        
        //email
        self.emailDataSource = [[TextFieldDataSource alloc] init];
        self.emailDataSource.textFieldLabel = @"Email:";
        self.emailDataSource.textFieldPlaceholder = @"optional";
        
        [self addDataSource:self.emailDataSource];
        
        //feedback message
        self.messageDataSource = [[TextViewDataSource alloc] init];
        self.messageDataSource.title = @"Your feedback";
        [self addDataSource:self.messageDataSource];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyUpdate) name:UITextViewTextDidChangeNotification object:nil];
        
    }
    return self;
}

-(void)resetContent{
    [super resetContent];
    self.channelSelectorStateEnabled = NO;
    [self.subjectDataSource resetContent];
    self.channelSelected = NO;
    self.subjectSelected = NO;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL)validateForm{
    if (!self.messageDataSource.textViewText.length) return NO;
    
    if (self.channelSelectorStateEnabled) return self.channelSelected;
    
    return self.subjectSelected;
    
}

-(void)notifyUpdate{
    [self.feedbackDelegate formDidChange];
}

-(void)setChannelSelectorStateEnabled:(BOOL)enabled{
    _channelSelectorStateEnabled = enabled;
    if (enabled && ![self.dataSources containsObject:self.channelDataSource]) {
        [self insertDataSource:self.channelDataSource atIndex:1];
    } else if (!enabled && [self.dataSources containsObject:self.channelDataSource]) {
        [self removeDataSource:self.channelDataSource];
    }
}

-(void)send{
    UIDevice *device = [UIDevice currentDevice];
    BOOL wantsResponse = self.emailDataSource.textFieldText.length;

    NSMutableDictionary *feedback = [@{@"message" : self.messageDataSource.textViewText,
                                       @"subject" : self.subjectDataSource.text,
                                       @"wants_response" : @(wantsResponse),
                                       @"osname" : device.systemName,
                                       @"id" : device.identifierForVendor.UUIDString,
                                       @"betamode" : betamode,
                                       @"version" : gittag
                                       } mutableCopy];
    
    
    if (wantsResponse) {
        feedback[@"email"] = self.emailDataSource.textFieldText;
    }
    
    if (self.channelSelected) {
        feedback[@"channel"] = self.channelDataSource.text;
    }
    
    NSString *url = @"feedback.php";

    
    [[RUNetworkManager sessionManager] POST:url parameters:feedback success:^(NSURLSessionDataTask *task, id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.feedbackDelegate formSendSucceeded];
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.feedbackDelegate formSendFailed];
        });
    }];
}
@end
