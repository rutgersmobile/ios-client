//
//  RUWebComponent.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUWebComponent.h"
#import <TSMiniWebBrowser.h>

@interface RUWebComponent ()
@property id<RUComponentDelegate> delegate;
@end

@implementation RUWebComponent

- (id) initWithURL:(NSURL *)url title:(NSString *)title delegate:(id <RUComponentDelegate>) delegate{
    self = [super init];
    if (self) {
        // Custom initialization
        self.delegate = delegate;
        TSMiniWebBrowser *webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:url];
        webBrowser.title = title;
        if ([self.delegate respondsToSelector:@selector(onMenuButtonTapped)]) {
            // delegate expects menu button notification, so let's create and add a menu button
            UIBarButtonItem * btn = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self.delegate action:@selector(onMenuButtonTapped)];
            webBrowser.navigationItem.leftBarButtonItem = btn;
        }
        
        [self pushViewController:webBrowser animated:NO];
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
