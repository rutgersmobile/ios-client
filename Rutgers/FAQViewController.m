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
#import "EZDataSource.h"

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
    
    NSDictionary *titleAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    NSDictionary *bodyAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:16]};
    
    for (NSDictionary *child in self.children) {
        id children = child[@"children"];
        if (![children isKindOfClass:[NSArray class]]) {
            EZTableViewTextRow *headerRow = [[EZTableViewTextRow alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:child[@"title"] attributes:titleAttributes]];
            EZTableViewTextRow *bodyRow = [[EZTableViewTextRow alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:child[@"answer"] attributes:bodyAttributes]];
            ExpandingTableViewSection *section = [[ExpandingTableViewSection alloc] initWithHeaderRow:headerRow bodyRows:@[bodyRow]];
            [self.dataSource addSection:section];
        } else {
            EZTableViewTextRow *headerRow = [[EZTableViewTextRow alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:child[@"title"] attributes:titleAttributes]];
            headerRow.didSelectRowBlock = ^{
                FAQViewController *faqViewController = [[FAQViewController alloc] initWithChildren:children];
                faqViewController.title = [child titleForChannel];
                [self.navigationController pushViewController:faqViewController animated:YES];
            };
            [self.dataSource addSection:[[EZDataSourceSection alloc] initWithItems:@[headerRow]]];
        }
    }
}

@end
