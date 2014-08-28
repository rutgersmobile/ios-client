//
//  RUFeedbackSecondViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUFeedbackSecondViewController.h"

@interface RUFeedbackSecondViewController ()

@end

@implementation RUFeedbackSecondViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.textView.editable = YES;
    self.textView.selectable = YES;
    
    self.title = @"Enter your Message";
    self.textView.text = @"Enter your feedback";
    self.textView.selectedRange = NSMakeRange(0, self.textView.text.length);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(sendFeedBack)];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.textView resignFirstResponder];
}

-(void)sendFeedBack{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Feedback Sent" message:@"Your feedback has been hand delivered to Aaron" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
}

@end
