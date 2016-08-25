//
//  EZTableViewMapsSection.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "MiniMapDataSource.h"
#import "RUMapsTableViewCell.h"

@interface MiniMapDataSource ()
@property (nonatomic) RUPlace *place;
@end

@implementation MiniMapDataSource
-(instancetype)initWithPlace:(RUPlace *)place{
    self = [super init];
    if (self) {
        self.title = @"Maps";
        self.place = place;
    }
    return self;
}

-(NSInteger)numberOfItemsInSection:(NSInteger)section{
    return 1;
}

-(id)itemAtIndexPath:(NSIndexPath *)indexPath{
    return self.place;
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[RUMapsTableViewCell class] forCellReuseIdentifier:NSStringFromClass([RUMapsTableViewCell class])];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([RUMapsTableViewCell class]);
}

-(void)configureCell:(RUMapsTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.place = self.place;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [RUMapsTableViewCell rowHeight]+1;
}


@end
