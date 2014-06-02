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
@end

@implementation text
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[text alloc] initWithChannel:channel];
}
-(id)initWithChannel:(NSDictionary *)channel{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.textView.text = channel[@"data"];
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        self.textView.editable = NO;
        self.textView.selectable = NO;
        self.textView.font = [UIFont systemFontOfSize:17];
        self.textView.textContainerInset = UIEdgeInsetsMake(15, 8, 15, 8);
     //   self.textView.dataDetectorTypes = UIDataDetectorTypePhoneNumber;
        [self.view addSubview:self.textView];
        [self.textView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
