 //
//  RURecCenterViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/20/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURecCenterViewController.h"
#import "TableViewController_Private.h"
#import "RUPlace.h"
#import "RUMapsViewController.h"
#import "RURecCenterDataSource.h"
#import "DataTuple.h"

#import <NSString+HTML.h>
#import "NSAttributedString+FromHTML.h"

@interface RURecCenterViewController ()
@property (nonatomic) NSDictionary *recCenter;
@end

@implementation RURecCenterViewController
- (instancetype)initWithTitle:(NSString *)title recCenter:(NSDictionary *)recCenter
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = title;
        self.recCenter = recCenter;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.dataSource = [[RURecCenterDataSource alloc] initWithRecCenter:self.recCenter];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id item = [self.dataSource itemAtIndexPath:indexPath];
    if ([item isKindOfClass:[DataTuple class]]) {
        DataTuple *tuple = item;
        [self.navigationController pushViewController:[[RUMapsViewController alloc] initWithPlace:tuple.object] animated:YES];
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    id item = [self.dataSource itemAtIndexPath:indexPath];
    return [item isKindOfClass:[DataTuple class]];
}

@end
