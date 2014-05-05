//
//  RUNewsViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUNewsViewController.h"
#import "RUNewsData.h"
#import <AFNetworking.h>

@interface RUNewsViewController ()
@property (nonatomic) RUNewsData *newsData;
@property (nonatomic) NSDictionary *news;
@end

@implementation RUNewsViewController

 
- (id)initWithDelegate: (id <RUComponentDelegate>) delegate {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.navigationItem.title = @"News";
    
        // Custom initialization
        self.delegate = delegate;
        if ([self.delegate respondsToSelector:@selector(onMenuButtonTapped)]) {
            // delegate expects menu button notification, so let's create and add a menu button
            UIBarButtonItem * btn = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self.delegate action:@selector(onMenuButtonTapped)];
            self.navigationItem.leftBarButtonItem = btn;
        }
        self.newsData = [RUNewsData sharedData];
        [self.newsData getNewsWithCompletion:^(NSDictionary *response) {
            self.news = response;
        }];
    }
    return self;
}

-(void)setNews:(NSDictionary *)news{
    _news = news;
    self.children = news[@"children"];
}

@end
