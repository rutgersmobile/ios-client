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
@property (nonatomic) NSArray *pathComponents;
@end

@implementation RUFavoritesDynamicHandoffViewController
-(instancetype)initWithPathComponents:(NSArray *)pathComponents title:(NSString *)title{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = title;
        self.pathComponents = pathComponents;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource = [[RUFavoritesDynamicHandoffDataSource alloc] initWithPathComponents:self.pathComponents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


