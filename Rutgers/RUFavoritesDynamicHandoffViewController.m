//
//  RUFavoritesDynamicHandoffViewController.m
//  Rutgers
//
//  Created by Open Systems Solutions on 2/24/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "RUFavoritesDynamicHandoffViewController.h"
#import "RUNetworkManager.h"
#import "Rutgers-Swift.h"

@interface RUFavoritesDynamicHandoffViewController ()
@property (nonatomic) NSString *handle;
@property (nonatomic) NSArray *pathComponents;
@end

@implementation RUFavoritesDynamicHandoffViewController
-(instancetype)initWithHandle:(NSString *)handle pathComponents:(NSArray *)pathComponents title:(NSString *)title{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = title;
        self.handle = handle;
        self.pathComponents = pathComponents;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [[RUFavoritesDynamicHandoffDataSource alloc] initWithHandle:self.handle pathComponents:self.pathComponents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dataSource:(DataSource *)dataSource didLoadContentWithError:(NSError *)error {
    RUFavoritesDynamicHandoffDataSource *handoffDataSource = (RUFavoritesDynamicHandoffDataSource *)dataSource;
    NSDictionary *result = handoffDataSource.result;
    if (result) {
        UIViewController *vc = [[RUChannelManager sharedInstance] viewControllerForChannel:result];
        vc.navigationItem.leftBarButtonItem = self.navigationItem.leftBarButtonItem;
        
        [self.navigationController setViewControllers:@[vc]];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end


