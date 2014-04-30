//
//  RUMenuViewController.m
//  Rutgers
//
//  Created by Russell Frank on 1/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//


#import "RUMenuViewController.h"
#import "TSMiniWebBrowser.h"

#import "RUInfoComponent.h"
#import "RUNewsComponent.h"
#import "RUBusComponent.h"
#import "RUPlacesComponent.h"
#import "RUWebComponent.h"

#define TITLES @[@"RU-info", @"myRutgers", @"Sakai", @"News", @"Bus", @"Places"]


@interface RUMenuViewController ()

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
    }
    return self;
}

- (void) tableView:(UITableView *) tableview didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        RUInfoComponent * info = [[RUInfoComponent alloc] initWithDelegate:self];
        info.view.backgroundColor = [UIColor whiteColor];
        [self.sidepanel showCenterPanelAnimated:YES];
        [self.sidepanel setCenterPanel:info];
    } else if (indexPath.row == 1 || indexPath.row == 2) {
        NSString * url = @"http://google.com";
        if (indexPath.row == 1) url = @"http://my.rutgers.edu";
        else if (indexPath.row == 2) url = @"http://sakai.rutgers.edu";
        [tableview deselectRowAtIndexPath:indexPath animated:NO];
        RUWebComponent *webComponent = [[RUWebComponent alloc] initWithURL:[NSURL URLWithString:url] delegate:self];
        webComponent.title = TITLES[indexPath.row];
        [self.sidepanel showCenterPanelAnimated:YES];
        [self.sidepanel setCenterPanel:webComponent];
    } else if (indexPath.row == 3) {
        RUNewsComponent *news = [[RUNewsComponent alloc] initWithDelegate:self];
        news.view.backgroundColor = [UIColor whiteColor];
        [self.sidepanel showCenterPanelAnimated:YES];
        [self.sidepanel setCenterPanel:news];
    } else if (indexPath.row == 4) {
        RUBusComponent *bus = [[RUBusComponent alloc] initWithDelegate:self];
        bus.view.backgroundColor = [UIColor whiteColor];
        [self.sidepanel showCenterPanelAnimated:YES];
        [self.sidepanel setCenterPanel:bus];
    } else if (indexPath.row == 5) {
        RUPlacesComponent *places = [[RUPlacesComponent alloc] initWithDelegate:self];
        places.view.backgroundColor = [UIColor whiteColor];
        [self.sidepanel showCenterPanelAnimated:YES];
        [self.sidepanel setCenterPanel:places];
    }
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
    
    NSString *title = TITLES[indexPath.row];
    
    cell.textLabel.text = title;
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return TITLES.count;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Channels";
}

@end
