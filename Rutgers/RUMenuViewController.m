//
//  RUMenuViewController.m
//  Rutgers
//
//  Created by Russell Frank on 1/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//


#import "RUMenuViewController.h"
#import "RUChannelManager.h"
#import <JASidePanelController.h>

@interface RUMenuViewController ()
@property RUChannelManager *componentManager;
@property NSArray *channels;
@end

@implementation RUMenuViewController
-(id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        
        self.title = @"Channels";
        self.componentManager = [RUChannelManager sharedInstance];
        [self.componentManager loadChannelsWithUpdateBlock:^(NSArray *channels) {
            [self.tableView beginUpdates];
            self.channels = channels;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }];
    }
    return self;
}
-(NSDictionary *)channelForIndexPath:(NSIndexPath *)indexPath{
    return self.channels[indexPath.row];
}
- (void)tableView:(UITableView *)tableview didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *channel = [self channelForIndexPath:indexPath];
    [self.delegate menu:self didSelectChannel:channel];
    
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [[self channelForIndexPath:indexPath] titleForChannel];
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.channels.count;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

@end
