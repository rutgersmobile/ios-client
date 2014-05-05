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
#import "RUFoodComponent.h"
#import "RUWebChannelManager.h"

#define CHANNEL_TITLES @[@"RU-Info", @"News", @"Bus", @"Places", @"Food", ]
#define WEB_TITLES @[@"myRutgers", @"Sakai"]
#define WEB_URLS @[@"http://my.rutgers.edu", @"http://sakai.rutgers.edu"]

@interface RUMenuViewController ()
@property (nonatomic) NSIndexPath *currentChannel;
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
    [self.sidepanel showCenterPanelAnimated:YES];
    if ([self.currentChannel isEqual:indexPath]) {
        return;
    }
    self.currentChannel = indexPath;
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                {
                    RUInfoComponent * info = [[RUInfoComponent alloc] initWithDelegate:self];
                    info.view.backgroundColor = [UIColor whiteColor];
                    [self.sidepanel setCenterPanel:info];
                }
                    break;
                case 1:
                {
                    RUNewsComponent *news = [[RUNewsComponent alloc] initWithDelegate:self];
                    news.view.backgroundColor = [UIColor whiteColor];
                    [self.sidepanel setCenterPanel:news];
                }
                    break;
                case 2:
                {
                    RUBusComponent *bus = [[RUBusComponent alloc] initWithDelegate:self];
                    bus.view.backgroundColor = [UIColor whiteColor];
                    [self.sidepanel setCenterPanel:bus];
                }
                    break;
                case 3:
                {
                    RUPlacesComponent *places = [[RUPlacesComponent alloc] initWithDelegate:self];
                    places.view.backgroundColor = [UIColor whiteColor];
                    [self.sidepanel setCenterPanel:places];
                }
                    break;
                case 4:
                {
                    RUFoodComponent *food = [[RUFoodComponent alloc] initWithDelegate:self];
                    food.view.backgroundColor = [UIColor whiteColor];
                    [self.sidepanel setCenterPanel:food];
                }
                    break;
                default:
                    break;
            }
            break;
        case 1:
        {
            RUWebComponent *webComponent = [[RUWebChannelManager sharedInstance] webComponentWithURL:[NSURL URLWithString:WEB_URLS[indexPath.row]] title:WEB_TITLES[indexPath.row] delegate:self];
            [self.sidepanel setCenterPanel:webComponent];
        }
            break;
            
        default:
            break;
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
    
    switch (indexPath.section) {
        case 0:
        {
            NSString *title = CHANNEL_TITLES[indexPath.row];
            cell.textLabel.text = title;
        }
            break;
        case 1:
        {
            NSString *title = WEB_TITLES[indexPath.row];
            cell.textLabel.text = title;
        }
            break;
            
        default:
            break;
    }
   
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [CHANNEL_TITLES count];
            break;
        case 1:
            return [WEB_TITLES count];
            break;
        default:
            return 0;
            break;
    }
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Channels";
            break;
        case 1:
            return @"Web Links";
            break;
            
        default:
            return nil;
            break;
    }
}

@end
