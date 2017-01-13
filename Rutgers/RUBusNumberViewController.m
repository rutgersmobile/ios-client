//
//  RUBusNumberViewController.m
//  Rutgers
//
//  Created by cfw37 on 1/12/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

#import "RUBusNumberViewController.h"
#import "RUBusPredictionsAndMessageDataSource.h"

@interface RUBusNumberViewController ()

@property (nonatomic) id item;

@end

@implementation RUBusNumberViewController

-(instancetype)initWithItem:(id)item
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.item = item; // RUBusRoute or RUBusStop
        self.title = [self.item title];
    }
    return self;
}

-(instancetype)initWithSerializedItem:(id)item title:(NSString *)title{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.item = item;
        self.title = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = [[RUBusPredictionsAndMessageDataSource alloc] initWithItem:self.item];
    
    [self.dataSource whenLoaded:^{
        if (self.dataSource != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               NSAssert([NSThread isMainThread], @"Method called using a thread other than main!");
                               RUBusPredictionsAndMessageDataSource* dataSource = (RUBusPredictionsAndMessageDataSource*)self.dataSource;
                               
                               if (dataSource.responseTitle == nil) {
                                   self.title = @"Bus";
                               } else {
                                   self.title = dataSource.responseTitle;
                               }
                           });
        }
    }];
    
    NSLog(@"%@", self.item);
    
    self.pullsToRefresh = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
