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

@interface RUMenuViewController ()

@end

@implementation RUMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITableView * table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        table.delegate = self;
        table.dataSource = self;
        [self.view addSubview:table];
    }
    return self;
}

- (void) tableView:(UITableView *) tableview didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1 || indexPath.row == 2) {
        NSString * url = @"http://google.com";
        if (indexPath.row == 1) url = @"http://my.rutgers.edu";
        else if (indexPath.row == 2) url = @"http://sakai.rutgers.edu";
        
        [tableview deselectRowAtIndexPath:indexPath animated:NO];
        TSMiniWebBrowser *webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:[NSURL URLWithString:url]];
        [self.sidepanel showCenterPanelAnimated:YES];
        [self.sidepanel setCenterPanel:webBrowser];
    } else {
        RUInfoComponent * info = [[RUInfoComponent alloc] initWithDelegate:self];
        info.view.backgroundColor = [UIColor whiteColor];
        [self.sidepanel showCenterPanelAnimated:YES];
        [self.sidepanel setCenterPanel:info];
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
    NSString * title;
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    title = @[@"RU-info", @"myRutgers", @"Sakai"][indexPath.row];
    
    cell.textLabel.text = title;
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Channels";
}

@end
