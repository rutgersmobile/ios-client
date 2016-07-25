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
#import "NSDictionary+DiningHall.h"

@interface RUDiningHallViewController ()
@property (nonatomic) NSDictionary *diningHall;
@property (nonatomic) NSString *serializedDiningHall;
@end

@implementation RUDiningHallViewController
-(instancetype)initWithSerializedDiningHall:(NSString *)serializedDiningHall title:(NSString *)title{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.serializedDiningHall = serializedDiningHall;
        self.title = title;
    }
    return self;
}

-(instancetype)initWithDiningHall:(NSDictionary *)diningHall{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.diningHall = diningHall;
        [self configureTitleWithDiningHall:diningHall];
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    if (self.diningHall) {
        self.dataSource = [[RUDiningHallDataSource alloc] initWithDiningHall:self.diningHall];
    } else if (self.serializedDiningHall) {
        self.dataSource = [[RUDiningHallDataSource alloc] initWithSerializedDiningHall:self.serializedDiningHall];
    }
}

-(void)configureTitleWithDiningHall:(NSDictionary *)diningHall {
    NSDate *date = [NSDate dateWithEpochTime:diningHall[@"date"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EEE MMM dd";
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    self.title = [NSString stringWithFormat:@"%@ (%@)", [diningHall diningHallShortName], dateString];
}

-(void)dataSource:(DataSource *)dataSource didLoadContentWithError:(NSError *)error {
    RUDiningHallDataSource *diningHallDataSource = (RUDiningHallDataSource *)dataSource;
    if (diningHallDataSource.diningHall) {
        [self configureTitleWithDiningHall:diningHallDataSource.diningHall];
        [self configureSegmentedControl];
    }
}

-(NSString *)sharingTitle{
    if (self.diningHall) {
        return [self.diningHall diningHallShortName];
    } else {
        return self.title;
    }
}

-(NSURL *)sharingURL{
    NSString *shortName;
    
    if (self.diningHall) {
        shortName = [self.diningHall diningHallShortName];
    } else {
        shortName = self.serializedDiningHall;
    }
    
    if (!shortName) return nil;

    shortName = [shortName lowercaseString];
    
    return [NSURL rutgersUrlWithPathComponents:@[@"food", shortName]];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![super tableView:tableView shouldHighlightRowAtIndexPath:indexPath]) return NO;
    return NO;
}
@end
