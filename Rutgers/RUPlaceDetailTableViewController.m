//
//  RUPlaceDetailTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/28/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlaceDetailTableViewController.h"
#import "TTTAddressFormatter.h"

typedef NS_ENUM(NSInteger, BuildingDetailSectionType) {
    BDSectionTypeAddress,
    BDSectionTypeInfo,
    BDSectionTypeOffices,
    BDSectionTypeDescription
};

const NSString *TITLE = @"title";
const NSString *BUILDING_NUMBER = @"building_number";
const NSString *CAMPUS = @"campus_name";
const NSString *ADDRESS = @"address";
const NSString *OFFICES = @"offices";
const NSString *BUILDING_CODE = @"building_code";
const NSString *DESCRIPTION = @"description";

@interface RUPlaceDetailTableViewCell : UITableViewCell

@end

@implementation RUPlaceDetailTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    // ignore the style argument, use our own to override
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    return self;
}
@end

@interface RUPlaceDetailTableViewController ()
@property (nonatomic) NSDictionary *place;
@property (nonatomic) NSString *address;
@end

@implementation RUPlaceDetailTableViewController

-(id)initWithPlace:(NSDictionary *)place{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.place = place;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[RUPlaceDetailTableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.title = [self stringForKeyPath:TITLE];
    self.navigationItem.rightBarButtonItem = nil;
    
    /*
     if (!self.showsDeleteButton) {
     }*/
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
+(TTTAddressFormatter *)sharedFormatter{
    static TTTAddressFormatter *sharedFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFormatter = [[TTTAddressFormatter alloc] init];
    });
    return sharedFormatter;
}
-(NSString *)address{
    if (!_address) {
        NSDictionary *location = self.place[@"location"];
        if ([location isKindOfClass:[NSDictionary class]]) {
            if (![location[@"street"] isEqualToString:@""] || ![location[@"city"] isEqualToString:@""] || ![location[@"state"] isEqualToString:@""]) {
                self.address = [[[self class] sharedFormatter] stringFromAddressWithStreet:location[@"street"] locality:location[@"city"] region:location[@"state"] postalCode:location[@"postal_code"] country:location[@"country"]];
            }
        }
    }
    return _address;
}
-(NSString *)stringForKeyPath:(const NSString *)keypath{
    NSString *string = [self.place valueForKeyPath:[keypath copy]];
    if ([string isKindOfClass:[NSString class]] && ![string isEqualToString:@""]) {
        return string;
    }
    return nil;
}

#pragma mark - Table view data source
-(void)iterateSectionsWithBlock:(void(^)(BuildingDetailSectionType sectionType, NSInteger index))block{
    BOOL info = ([self stringForKeyPath:TITLE] ||[self stringForKeyPath:BUILDING_NUMBER] || [self stringForKeyPath:CAMPUS] || [self stringForKeyPath:BUILDING_CODE]);
    BOOL address = [self address] ? YES:NO;
    BOOL offices = self.place[OFFICES] ? YES:NO;
    BOOL description = [self stringForKeyPath:DESCRIPTION] ? YES:NO;
    NSArray *sectionsOn = @[@(address),@(info),@(offices),@(description)];
    NSInteger index = 0;
    for (int section = 0; section < [sectionsOn count];  section++) {
        NSNumber *sectionOn = sectionsOn[section];
        if ([sectionOn boolValue]) {
            block(section,index);
            index++;
        }
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    __block NSInteger number = 0;
    [self iterateSectionsWithBlock:^(BuildingDetailSectionType sectionType, NSInteger index) {
        number++;
    }];
    return number;
}
-(BuildingDetailSectionType)sectionTypeForSection:(NSInteger)section{
    __block BuildingDetailSectionType typeForSection = 0;
    [self iterateSectionsWithBlock:^(BuildingDetailSectionType sectionType, NSInteger index) {
        if (index == section) {
            typeForSection = sectionType;
        }
    }];
    return typeForSection;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    BuildingDetailSectionType sectionType = [self sectionTypeForSection:section];
    if (sectionType == BDSectionTypeOffices) {
        return [self.place[OFFICES] count];
    } else if (sectionType == BDSectionTypeInfo) {
        BOOL title = [self stringForKeyPath:TITLE] ? YES:NO;
        BOOL campus = [self stringForKeyPath:CAMPUS] ? YES:NO;
        BOOL buildingCode = [self stringForKeyPath:BUILDING_CODE] ? YES:NO;
        BOOL buildingNumber = [self stringForKeyPath:BUILDING_NUMBER] ? YES:NO;
        
        NSArray *rowsOn = @[@(title),@(campus),@(buildingCode),@(buildingNumber)];
        NSInteger counted = 0;
        for (int i = 0; i < [rowsOn count];  i++) {
            NSNumber *rowOn = rowsOn[i];
            if ([rowOn boolValue]) {
                counted++;
            }
        }
        return counted;
    }
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier:CellIdentifier];
    }
    BuildingDetailSectionType sectionType = [self sectionTypeForSection:indexPath.section];
    
    // Configure the cell...
    
    if (sectionType == BDSectionTypeOffices) {
        id itemForCell = self.place[OFFICES][indexPath.row];
        if ([itemForCell isKindOfClass:[NSString class]]){
            cell.textLabel.text = itemForCell;
            cell.detailTextLabel.text = nil;
            cell.textLabel.numberOfLines = 0;
            [cell.textLabel sizeToFit];
        } else {
            cell.textLabel.text = nil;
            cell.detailTextLabel.text = nil;
        }
    } else if (sectionType == BDSectionTypeInfo) {
        NSInteger row = indexPath.row;
        BOOL title = [self stringForKeyPath:TITLE] ? YES:NO;
        BOOL campus = [self stringForKeyPath:CAMPUS] ? YES:NO;
        BOOL buildingCode = [self stringForKeyPath:BUILDING_CODE] ? YES:NO;
        BOOL buildingNumber = [self stringForKeyPath:BUILDING_NUMBER] ? YES:NO;
        
        NSArray *rowsOn = @[@(title),@(campus),@(buildingCode),@(buildingNumber)];
        NSInteger counted = 0;
        for (int i = 0; i < [rowsOn count];  i++) {
            NSNumber *rowOn = rowsOn[i];
            if ([rowOn boolValue]) {
                if (counted == row) {
                    if (i == 0) {
                        cell.detailTextLabel.text = nil;
                        cell.textLabel.text = [self stringForKeyPath:TITLE];
                        cell.textLabel.numberOfLines = 0;
                        [cell.textLabel sizeToFit];
                    } else if (i == 1) {
                        cell.detailTextLabel.text = @"Campus";
                        cell.textLabel.text = [self stringForKeyPath:CAMPUS];
                    } else if (i == 2) {
                        cell.detailTextLabel.text = @"Building Code";
                        cell.textLabel.text = [self stringForKeyPath:BUILDING_CODE];
                    } else if (i == 3) {
                        cell.detailTextLabel.text = @"Building Number";
                        cell.textLabel.text = [self stringForKeyPath:BUILDING_NUMBER];
                    }
                    break;
                }
                counted++;
            }
        }
    } else if (sectionType == BDSectionTypeAddress) {
        NSInteger row = indexPath.row;
        if (row == 0) {
            cell.textLabel.text = [self address];
            cell.textLabel.numberOfLines = 0;
            [cell.textLabel sizeToFit];
            cell.detailTextLabel.text = nil;
        }
    } else if (sectionType == BDSectionTypeDescription) {
        NSInteger row = indexPath.row;
        if (row == 0) {
            cell.textLabel.text = [self stringForKeyPath:DESCRIPTION];
            cell.textLabel.numberOfLines = 0;
            [cell.textLabel sizeToFit];
            cell.detailTextLabel.text = nil;
        }
    } else {
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    BuildingDetailSectionType sectionType = [self sectionTypeForSection:indexPath.section];
    if (sectionType == BDSectionTypeAddress || sectionType == BDSectionTypeDescription || sectionType == BDSectionTypeOffices || (sectionType == BDSectionTypeInfo && indexPath.row == 0 && [self stringForKeyPath:TITLE])) {
        //UILabel *lblGetDynamicHeight = [[UILabel alloc] init];
        NSString *string;
        
        switch (sectionType) {
            case BDSectionTypeAddress:
                string = [self address];
                break;
            case BDSectionTypeDescription:
                string = [self stringForKeyPath:DESCRIPTION];
                break;
            case BDSectionTypeInfo:
                string = [self stringForKeyPath:TITLE];
                break;
            case BDSectionTypeOffices:
                string = self.place[OFFICES][indexPath.row];
                break;
            default:
                return 44.0;
                break;
        }
        
        NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:17] forKey: NSFontAttributeName];
        
        CGSize labelStringSize = [string boundingRectWithSize:CGSizeMake(290, 9999)
                                                      options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:stringAttributes context:nil].size;
        
        
        return  labelStringSize.height+24.0;
        
    } return 44.0;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    BuildingDetailSectionType sectionType = [self sectionTypeForSection:section];
    switch (sectionType) {
        case BDSectionTypeOffices:
            return @"Offices";
            break;
        case BDSectionTypeInfo:
            return @"Info";
            break;
        case BDSectionTypeAddress:
            return @"Address";
            break;
        case BDSectionTypeDescription:
            return @"Description";
            break;
        default:
            return nil;
            break;
    }
}
-(void)tableView:(UITableView*)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender{
    if (action == @selector(copy:)){
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text];
    }
}
-(BOOL)tableView:(UITableView*)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender{
    if (action == @selector(copy:)) return YES;
    return NO;
}
-(BOOL)tableView:(UITableView*)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath*)indexPath{
    return YES;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
