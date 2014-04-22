//
//  RUNewsViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUNewsViewController.h"

#import <AFNetworking.h>

@interface RUNewsViewController ()
@property (nonatomic) NSDictionary *news;
@property (nonatomic) AFHTTPSessionManager *sessionManager;
@end 

@implementation RUNewsViewController

 
- (id)initWithDelegate: (id <RUNewsDelegate>) delegate {
    self = [super init];
    if (self) {
        self.navigationItem.title = @"RU-info";
    
        // Custom initialization
        self.delegate = delegate;
        if ([self.delegate respondsToSelector:@selector(onMenuButtonTapped)]) {
            // delegate expects menu button notification, so let's create and add a menu button
            UIBarButtonItem * btn = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self.delegate action:@selector(onMenuButtonTapped)];
            self.navigationItem.leftBarButtonItem = btn;
        }
        
        
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://rumobile.rutgers.edu/1/"]];
        self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        [self.sessionManager GET:@"news.txt" parameters:0 success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                self.news = responseObject;
            } else {
                [self requestFailed];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [self requestFailed];
        }];
        
    }
    return self;
}
-(void)requestFailed{
    
}


-(void)setNews:(NSDictionary *)news{
    _news = news;
    self.children = news[@"children"];
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
