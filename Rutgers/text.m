//
//  text.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "text.h"

@interface text ()
@property (nonatomic) UITextView *textView;
@property (nonatomic) NSString *data;
@end

@implementation text
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[text alloc] initWithChannel:channel];
}

-(id)initWithChannel:(NSDictionary *)channel{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.data = channel[@"data"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.editable = NO;
    self.textView.selectable = NO;
    self.textView.font = [UIFont systemFontOfSize:17];
    self.textView.textContainerInset = UIEdgeInsetsMake(15, 8, 15, 8);
    self.textView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.view addSubview:self.textView];
    [self.textView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    self.textView.text = self.data;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
