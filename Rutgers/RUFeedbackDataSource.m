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
#import "SwitchDataSource.h"
#import "RUNetworkManager.h"
#import "NSDictionary+Channel.h"

@interface RUFeedbackDataSource ()
@property (nonatomic) AlertDataSource *subjectDataSource;
@property (nonatomic) AlertDataSource *channelDataSource;

@property (nonatomic) TextFieldDataSource *emailDataSource;

@property (nonatomic) SwitchDataSource *switchDataSource;

@property (nonatomic) TextViewDataSource *messageDataSource;

@property (nonatomic) NSArray *channels;
@property (nonatomic) NSDictionary *selectedChannel;

@property (nonatomic) BOOL switchEnabled;

@property (nonatomic) BOOL channelSelectorStateEnabled;

@property (nonatomic) BOOL subjectSelected;
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
            if ([buttonTitle isEqualToString:@"General Questions"]) {
                [weakSelf.subjectDataSource resetContent];
                weakSelf.subjectSelected = NO;
                [weakSelf.feedbackDelegate showRUInfo];
            } else {
                weakSelf.subjectSelected = YES;
            }
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
            weakSelf.selectedChannel = weakSelf.channels[buttonIndex];
            [weakSelf notifyUpdate];
        };
        
        //email
        self.emailDataSource = [[TextFieldDataSource alloc] init];
        self.emailDataSource.textFieldLabel = @"Email:";
        self.emailDataSource.textFieldPlaceholder = @"optional";
        
        [self addDataSource:self.emailDataSource];
        
        
        //needs feedback switch
        self.switchDataSource = [[SwitchDataSource alloc] init];
        self.switchDataSource.textLabelText = @"Would you like a response?";
        
        
        //feedback message
        self.messageDataSource = [[TextViewDataSource alloc] init];
        self.messageDataSource.title = @"Your feedback";
        [self addDataSource:self.messageDataSource];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailTextChanged) name:UITextFieldTextDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedbackTextChanged) name:UITextViewTextDidChangeNotification object:nil];
        
    }
    return self;
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [self.switchDataSource registerReusableViewsWithTableView:tableView];
}

-(void)resetContent{
    [super resetContent];
    [self.channelDataSource resetContent];
    [self.switchDataSource resetContent];

    self.switchEnabled = NO;
    self.channelSelectorStateEnabled = NO;
    self.selectedChannel = nil;
    self.subjectSelected = NO;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL)validateForm{
    if (!self.messageDataSource.textViewText.length) return NO;
    
    if (self.channelSelectorStateEnabled && !self.selectedChannel) return NO;
    
    NSString *emailText = self.emailDataSource.textFieldText;
    if (emailText.length) {
        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" options:0 error:nil];
        NSInteger numberOfMatches = [expression numberOfMatchesInString:emailText options:0 range:NSMakeRange(0, emailText.length)];
        if (!numberOfMatches) return NO;
    }
    
    return self.subjectSelected;
}

-(void)emailTextChanged{
    self.switchEnabled = self.emailDataSource.textFieldText.length;
    [self notifyUpdate];
}

-(void)feedbackTextChanged{
    [self notifyUpdate];
}

-(void)notifyUpdate{
    [self.feedbackDelegate formDidChange];
}

-(void)setSwitchEnabled:(BOOL)switchEnabled{
    _switchEnabled = switchEnabled;
    if (switchEnabled && ![self.dataSources containsObject:self.switchDataSource]) {
        NSInteger index = [self.dataSources indexOfObject:self.emailDataSource] + 1;
        [self insertDataSource:self.switchDataSource atIndex:index];
    } else if (!switchEnabled && [self.dataSources containsObject:self.switchDataSource]) {
        [self removeDataSource:self.switchDataSource];
    }
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
    
    BOOL wantsResponse = self.switchDataSource.isOn;
    
    NSMutableDictionary *feedback = [@{@"message" : self.messageDataSource.textViewText,
                                       @"subject" : self.subjectDataSource.text,
                                       @"wants_response" : @(wantsResponse),
                                       @"osname" : device.systemName,
                                       @"id" : device.identifierForVendor.UUIDString,
                                       @"betamode" : betaModeString(),
                                       @"version" : gittag
                                       } mutableCopy];
    
    if (self.emailDataSource.textFieldText.length) {
        feedback[@"email"] = self.emailDataSource.textFieldText;
    }
    
    if (self.selectedChannel) {
        feedback[@"channel"] = [self.selectedChannel channelHandle];
    }
    
    NSString *url = @"feedback.php";

    /*
    if (betaMode) {
        url = @"https://doxa.rutgers.edu/mobile/1/feedback.php";
    }*/
    
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
