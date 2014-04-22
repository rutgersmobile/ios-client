//
//  RUBusViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUBusViewController.h"
#import "RUBusData.h"
@interface RUBusViewController ()
@property (nonatomic) RUBusData *busData;
@end

@implementation RUBusViewController

- (id)initWithDelegate:(id <RUBusDelegate>)delegate {
    self = [super init];
    if (self) {
        self.navigationItem.title = @"Bus";
        self.busData = [[RUBusData alloc] init];
        // Custom initialization
        self.delegate = delegate;
        if ([self.delegate respondsToSelector:@selector(onMenuButtonTapped)]) {
            // delegate expects menu button notification, so let's create and add a menu button
            UIBarButtonItem * btn = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self.delegate action:@selector(onMenuButtonTapped)];
            self.navigationItem.leftBarButtonItem = btn;
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self.busData getAgencyConfigWithCompletion:^{
        
    }];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}/*
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.children.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = nil;
    id child = self.children[indexPath.row];
    if ([child isKindOfClass:[NSDictionary class]]) {
        cell.textLabel.text = [self titleForChild:child];
    }
    if (child[@"channel"]) {
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    } else if (child[@"children"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
-(NSString *)titleForChild:(NSDictionary *)child{
    id title = child[@"title"];
    if ([title isKindOfClass:[NSString class]]) {
        return title = title;
    } else if ([title isKindOfClass:[NSDictionary class]]) {
        id subtitle = title[@"homeTitle"];
        if ([subtitle isKindOfClass:[NSString class]]) {
            return subtitle;
        }
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *child = self.children[indexPath.row];
    if (child[@"channel"]) {
        RUReaderController *rvc = [[RUReaderController alloc] initWithStyle:UITableViewStylePlain child:child];
        [self.navigationController pushViewController:rvc animated:YES];
    } else if (child[@"children"]) {
        DynamicTableViewController *dtvc = [[DynamicTableViewController alloc] initWithStyle:UITableViewStylePlain children:child[@"children"]];
        dtvc.title = [self titleForChild:child];
        [self.navigationController pushViewController:dtvc animated:YES];
    }
}
*/
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
