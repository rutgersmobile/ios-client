//
//  FAQViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/20/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "FAQViewController.h"
#import "ExpandingTableViewSection.h"
#import "EZTableViewTextRow.h"
#import "FAQDataSource.h"

@interface FAQViewController ()
@property NSArray *children;
@end

@implementation FAQViewController

-(instancetype)initWithChildren:(NSArray *)children{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.children = children;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = [[FAQDataSource alloc] initWithItems:self.children];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    id item = [self.dataSource itemAtIndexPath:indexPath];
    if ([item isKindOfClass:[NSDictionary class]]) {
        NSDictionary *child = item;
        FAQViewController *faqViewController = [[FAQViewController alloc] initWithChildren:child[@"children"]];
        faqViewController.title = [child titleForChannel];
        [self.navigationController pushViewController:faqViewController animated:YES];
    }
}

@end
