//
//  RUSOCCourseViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCCourseViewController.h"
#import "EZTableViewTextRow.h"
#import "EZTableViewSection.h"
#import "EZTableViewTextRow.h"
#import "RUSOCSectionRow.h"

@interface RUSOCCourseViewController ()
@property (nonatomic) NSDictionary *course;
@end

@implementation RUSOCCourseViewController
-(id)initWithCourse:(NSDictionary *)course{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.course = course;
        self.title = [NSString stringWithFormat:@"%@: %@",self.course[@"courseNumber"],[self.course[@"title"] capitalizedString]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *courseDescription = self.course[@"courseDescription"];
    if ([courseDescription isKindOfClass:[NSString class]]) {
        EZTableViewTextRow *row = [[EZTableViewTextRow alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:courseDescription attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}]];
        [self addSection:[[EZTableViewSection alloc] initWithSectionTitle:nil rows:@[row]]];
    }
    
    EZTableViewSection *sectionSection = [[EZTableViewSection alloc] init];
    NSArray *sections = self.course[@"sections"];
    for (NSDictionary *section in sections) {
        [sectionSection addRow:[[RUSOCSectionRow alloc] initWithSection:section]];
    }
    [self addSection:sectionSection];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
