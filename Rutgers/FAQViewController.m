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
            [self addSection:section];
        } else {
            EZTableViewTextRow *headerRow = [[EZTableViewTextRow alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:child[@"title"] attributes:titleAttributes]];
            headerRow.didSelectRowBlock = ^{
                FAQViewController *faqViewController = [[FAQViewController alloc] initWithChildren:children];
                faqViewController.title = [child titleForChannel];
                [self.navigationController pushViewController:faqViewController animated:YES];
            };
            [self addSection:[[EZTableViewSection alloc] initWithSectionTitle:nil rows:@[headerRow]]];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
