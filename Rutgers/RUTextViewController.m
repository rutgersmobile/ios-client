//
//  text.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUTextViewController.h"

@interface RUTextViewController ()
@property (nonatomic) UITextView *textView;
@property (nonatomic) NSString *data;
@end

@implementation RUTextViewController
+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[RUTextViewController alloc] initWithChannel:channel];
}

-(id)initWithChannel:(NSDictionary *)channel{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.data = channel[@"data"];
    }
    return self;
}

-(void)loadView{
    [super loadView];
    self.textView = [UITextView newAutoLayoutView];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.editable = NO;
    self.textView.selectable = NO;
    self.textView.font = [UIFont systemFontOfSize:17];
    self.textView.textContainerInset = UIEdgeInsetsMake(11, 8, 11, 8);
    self.textView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.textView.alwaysBounceVertical = YES;
    
    [self.view addSubview:self.textView];
    [self.textView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.textView.text = self.data;
}

@end
