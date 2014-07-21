//
//  RUFeedbackViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUFeedbackViewController.h"
#import "EZDataSource.h"
#import "EZTableViewRightDetailRow.h"

@interface RUFeedbackViewController () <UIActionSheetDelegate>
@property EZTableViewRightDetailRow *feedbackRow;
@property NSArray *feedbackSubjects;
@end

@implementation RUFeedbackViewController

+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[[self class] alloc] initWithStyle:UITableViewStyleGrouped];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *view = self.view;
    
    self.feedbackSubjects = @[
                             @"General Questions",
                             @"Help Using Application",
                             @"App Feature Request",
                             @"Report a Bug",
                             @"App Channel Feedback"
                             ];
    
    UIActionSheet *feedbackActionSheet = [[UIActionSheet alloc] initWithTitle:@"Please select a subject:" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    for (NSString *string in self.feedbackSubjects) {
        [feedbackActionSheet addButtonWithTitle:string];
    }
    
    self.feedbackRow = [[EZTableViewRightDetailRow alloc] initWithText:@"Select a feedback subject..."];
    self.feedbackRow.didSelectRowBlock = ^{
        [feedbackActionSheet showInView:view];
    };
    
    [self.dataSource addSection:[[EZDataSourceSection alloc] initWithItems:@[self.feedbackRow]]];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    self.feedbackRow.text = self.feedbackSubjects[buttonIndex];
    [self.dataSource reloadSectionAtIndex:0];
}
                                                  
                                                  
@end
