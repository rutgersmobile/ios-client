//
//  RUWebViewContainerViewController.m
//  Rutgers
//
//  Created by Open Systems Solutions on 7/29/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import "RUWebViewContainerViewController.h"
#import "RUWebViewController.h"

@interface RUWebViewContainerViewController ()
@property (nonatomic) NSDictionary *channel;
@end

@implementation RUWebViewContainerViewController
+(instancetype)newWithChannel:(NSDictionary *)channel{
    return [[self alloc] initWithChannel:channel];
}

-(instancetype)initWithChannel:(NSDictionary *)channel{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.channel = channel;
    }
    return self;
}

-(void)loadView{
    [super loadView];
    UIViewController *webViewController = [RUWebViewController newWithChannel:self.channel];
    [self.view addSubview:webViewController.view];
    [webViewController.view autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    [self addChildViewController:webViewController];
}

@end
