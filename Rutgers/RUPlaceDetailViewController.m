//
//  RUPlaceDetailTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/28/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlaceDetailViewController.h"
#import "RUPredictionsViewController.h"
#import "RUPlacesViewController.h"
#import "RUPlaceDetailDataSource.h"
#import "RUPlace.h"
#import "RUBusStop.h"
#import "NSURL+RUAdditions.h"
#import "Rutgers-Swift.h"

static NSString *const PlacesMapPopupKey = @"PlacesMapPopupKey"; // Key used to decide whether to show the pop up warning about maps not working well enough on ios 9.0 , 9.1 and 9.2

@interface RUPlaceDetailViewController ()
@property (nonatomic) RUPlace *place;
@property (nonatomic) NSString *serializedPlace;
@end

@implementation RUPlaceDetailViewController

-(instancetype)initWithPlace:(RUPlace *)place{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.place = place;
        self.title = place.title;
    }
    return self;
}

-(instancetype)initWithSerializedPlace:(NSString *)serializedPlace title:(NSString *)title{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.serializedPlace = serializedPlace;
        self.title = title;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    if (self.place) {
        self.dataSource = [[RUPlaceDetailDataSource alloc] initWithPlace:self.place];
    } else if (self.serializedPlace) {
        self.dataSource = [[RUPlaceDetailDataSource alloc] initWithSerializedPlace:self.serializedPlace];
    }

    if( ! [[ NSUserDefaults standardUserDefaults] boolForKey:PlacesMapPopupKey])
    {
        // HACK FOR MAP ISSUE ON 9.0 , 9.1 and 9.2
       // guard aganist craching on ios 7 as isOpertaingSyste.. only on ios 8 >
        if([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)] )
        {
            // check the version of the ios . If the version is 9.0 , 9.1 , 9.2 : We warn the user about the issue with the maps linkage
            if([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){9,0,0}] && ![[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){9,3,0}])
            {
               // NSLog(@"version > 9.0.0 && version < 9.3.0");
                UIAlertController * mapIssueAlert = [UIAlertController alertControllerWithTitle:@"Map Support" message:@"Due to an issue with some versions of iOS, maps may not display properly on your device. If this affects you, please open the Apple Maps app or upgrade to at least iOS version 9.3." preferredStyle:UIAlertControllerStyleAlert];

                CLLocationDegrees searchLat = self.place.coordinate.latitude;
                CLLocationDegrees searchLon = self.place.coordinate.longitude;
                NSString* appleMapsLink = [NSString stringWithFormat:@"http://maps.apple.com/?sll=%f,%f", searchLat, searchLon];

                UIAlertAction* openMaps = [UIAlertAction actionWithTitle:@"Open Apple Maps" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appleMapsLink]];
                }];
                
                [mapIssueAlert addAction:openMaps];

                UIAlertAction* ignoreAction = [UIAlertAction actionWithTitle:@"Ignore" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {}];
                [mapIssueAlert addAction:ignoreAction];

                UIAlertAction* ignorePermanentlyAction = [UIAlertAction actionWithTitle:@"Ignore Permanently" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action)
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PlacesMapPopupKey];
                }];
                [mapIssueAlert addAction:ignorePermanentlyAction];

                [self presentViewController:mapIssueAlert animated:YES completion:nil];
            }
        }     
    }
   
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [(RUPlaceDetailDataSource *)self.dataSource startUpdates];
}

-(void)viewWillDisappear:(BOOL)animated{
    [(RUPlaceDetailDataSource *)self.dataSource stopUpdates];
    [super viewWillDisappear:animated];
}


-(NSURL *)sharingURL{
    NSString *idString;
    if (self.place) {
        idString = self.place.uniqueID;
    } else {
        idString = self.serializedPlace;
    }
    if (!idString) return nil;
    
    return [NSURL rutgersUrlWithPathComponents:@[
                                                 @"places",
                                                 idString
                                                 ]];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id item = [self.dataSource itemAtIndexPath:indexPath];
    if ([item isKindOfClass:[RUPlace class]]) {
        [self.navigationController pushViewController:[[MapsViewController alloc] initWithPlace:item] animated:YES];
        //Mark: Used to be RUBusMultiStop
    } else if ([item isKindOfClass:[RUBusStop class]]) {
        [self.navigationController pushViewController:[[RUPredictionsViewController alloc] initWithItem:item] animated:YES];
    }
}

-(BOOL)showMenuForItem:(id)item{
    return [item isKindOfClass:[NSString class]];
}

-(BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath{
    id item = [self.dataSource itemAtIndexPath:indexPath];
    return [self showMenuForItem:item];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![super tableView:tableView shouldHighlightRowAtIndexPath:indexPath]) return NO;
    id item = [self.dataSource itemAtIndexPath:indexPath];
    return ![self showMenuForItem:item];
}

-(BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    id item = [self.dataSource itemAtIndexPath:indexPath];
    return action == @selector(copy:) && [self showMenuForItem:item];
}

-(void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    if (action != @selector(copy:)) return;
    NSString *item = [self.dataSource itemAtIndexPath:indexPath];
    [UIPasteboard generalPasteboard].string = item;
}

@end
