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

/*
    What is the purpose of this class ?
 
 
 */


@interface RUFavoritesDynamicHandoffViewController ()
@property (nonatomic) NSString *handle;
@property (nonatomic) NSArray *pathComponents; /// <q> does this store the path ? eg rutgers://Kni.../Athe.. ????
@end

@implementation RUFavoritesDynamicHandoffViewController
-(instancetype)initWithHandle:(NSString *)handle pathComponents:(NSArray *)pathComponents title:(NSString *)title{
    self = [super initWithStyle:UITableViewStyleGrouped]; // Where is this being implmented on ? Within the slide view
    if (self) {
        self.title = title;
        self.handle = handle;
        self.pathComponents = pathComponents;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   // RUFav...OffDataSour... is a swift class
    self.dataSource = [[RUFavoritesDynamicHandoffDataSource alloc] initWithHandle:self.handle pathComponents:self.pathComponents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dataSource:(DataSource *)dataSource didLoadContentWithError:(NSError *)error {
    RUFavoritesDynamicHandoffDataSource *handoffDataSource = (RUFavoritesDynamicHandoffDataSource *)dataSource;
    NSDictionary *result = handoffDataSource.result; /// <q> What does this hold ?
    
    // <q> Is this the location where we move to the view controller spcified by the Favourite ?
    
    if (result)
    {
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


