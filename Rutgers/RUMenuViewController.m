//
//  RUMenuViewController.m
//  Rutgers
//
//  Created by Russell Frank on 1/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//


#import "RUMenuViewController.h"
#import "RUChannelManager.h"

@interface RUMenuViewController ()
@property RUChannelManager *componentManager;
@property NSIndexPath *currentChannel;
@property NSArray *channels;
@end

@implementation RUMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITableView * table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        table.delegate = self;
        table.dataSource = self;
        [self.view addSubview:table];
        
        self.componentManager = [RUChannelManager sharedInstance];
        
        [self.componentManager loadChannelsWithUpdateBlock:^(NSArray *channels) {
            self.channels = channels;
            [table reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    }
    return self;
}
-(NSDictionary *)channelForIndexPath:(NSIndexPath *)indexPath{
    return self.channels[indexPath.row];
}
- (void)tableView:(UITableView *)tableview didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.currentChannel isEqual:indexPath]) {
        [self.sidepanel showCenterPanelAnimated:YES];
        return;
    }
    self.currentChannel = indexPath;
    UIViewController * channel = [[UINavigationController alloc] initWithRootViewController:[self.componentManager viewControllerForChannel:[self channelForIndexPath:indexPath] delegate:self]];
    
    [self.sidepanel showCenterPanelAnimated:YES];
    [self.sidepanel setCenterPanel:channel];
}
- (void) onMenuButtonTapped {
    [self.sidepanel showLeftPanelAnimated:YES];
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


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.textLabel.text = [self.componentManager titleForChannel:[self channelForIndexPath:indexPath]];
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.channels.count;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Channels";
}

@end
