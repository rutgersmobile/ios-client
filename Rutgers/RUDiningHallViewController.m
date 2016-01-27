//
//  RUDiningHallViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUDiningHallViewController.h"
#import "RUDiningHallDataSource.h"
#import "NSDate+EpochTime.h"
#import "NSString+WordsInString.h"
#import "NSURL+RUAdditions.h"

@interface RUDiningHallViewController ()
@property (nonatomic) NSDictionary *diningHall;
@end

@implementation RUDiningHallViewController
-(instancetype)initWithDiningHall:(NSDictionary *)diningHall{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.diningHall = diningHall;
        
        NSDate *date = [NSDate dateWithEpochTime:diningHall[@"date"]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"EEE MMM dd";
        
        NSString *dateString = [dateFormatter stringFromDate:date];
        
        self.title = [NSString stringWithFormat:@"%@ (%@)", [self diningHallShortName], dateString];
    }
    return self;
}

-(NSString *)diningHallShortName{
    return [self.diningHall[@"location_name"] wordsInString].firstObject;
}

-(NSURL *)sharingURL{
    return [NSURL rutgersUrlWithPathComponents:@[@"food", [self diningHallShortName]]];
}

-(NSString *)handle{
    return @"food";
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.dataSource = [[RUDiningHallDataSource alloc] initWithDiningHall:self.diningHall];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![super tableView:tableView shouldHighlightRowAtIndexPath:indexPath]) return NO;
    return NO;
}
@end
